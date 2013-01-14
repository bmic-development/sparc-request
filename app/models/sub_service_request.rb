class SubServiceRequest < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  after_save :update_past_status

  belongs_to :owner, :class_name => 'Identity', :foreign_key => "owner_id"
  belongs_to :service_request
  belongs_to :organization
  has_many :past_statuses, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :notes, :dependent => :destroy 
  has_one :subsidy, :dependent => :destroy

  # These two ids together form a unique id for the sub service request
  attr_accessible :service_request_id
  attr_accessible :ssr_id

  attr_accessible :organization_id
  attr_accessible :owner_id
  attr_accessible :status_date
  attr_accessible :status
  attr_accessible :consult_arranged_date
  attr_accessible :nursing_nutrition_approved
  attr_accessible :lab_approved
  attr_accessible :imaging_approved
  attr_accessible :requester_contacted_date
  attr_accessible :subsidy_attributes

  accepts_nested_attributes_for :subsidy

  def one_time_fee_line_items
    self.line_items.select {|li| li.service.is_one_time_fee?}
  end

  def per_patient_per_visit_line_items
    self.line_items.select {|li| !li.service.is_one_time_fee?}    
  end
  
  def has_one_time_fee_services?
    one_time_fee_line_items.count > 0
  end

  def has_per_patient_per_visit_services?
    per_patient_per_visit_line_items.count > 0
  end

  # Returns the total direct costs of the sub-service-request
  def direct_cost_total
    total = 0.0

    self.line_items.each do |li|
      if li.service.is_one_time_fee?
        total += li.direct_costs_for_one_time_fee
      else
        total += li.direct_costs_for_visit_based_service
      end
    end

    return total
  end

  # Returns the total indirect costs of the sub-service-request
  def indirect_cost_total
    total = 0.0

    self.line_items.each do |li|
      if li.service.is_one_time_fee?
        total += li.indirect_costs_for_one_time_fee
      else
        total += li.indirect_costs_for_visit_based_service
      end
    end

    return total
  end

  # Returns the grant total cost of the sub-service-request
  def grand_total
    self.direct_cost_total + self.indirect_cost_total
  end

  def subsidy_percentage
    funded_amount = self.direct_cost_total - self.subsidy.pi_contribution.to_f

    ((funded_amount.to_f / self.direct_cost_total.to_f).round(2) * 100).to_i
  end

  # Returns a list of candidate services for a given ssr (used in fulfillment)
  def candidate_services
    services = []
    if self.organization.process_ssrs
      services = self.organization.all_child_services.select {|x| x.is_available?}

    else
      begin
        services = self.organization.process_ssrs_parent.all_child_services.select {|x| x.is_available}
      rescue
        services = self.organization.all_child_services.select {|x| x.is_available?}
      end
    end 

    services
  end

  def add_line_item service
    if self.line_items.map {|li| li.service.id}.include? service.id
      raise ArgumentError, "Service #{service.id} is already on service request #{self.service_request.id} "
    else
      line_item = self.line_items.create(service_id: service.id, service_request_id: self.service_request.id, ssr_id: self.ssr_id)
      unless service.is_one_time_fee? 
        self.service_request.visit_count.times do 
           line_item.visits.create(line_item_id: line_item.id)
        end
      end
    end

    line_item
  end

  def update_line_item line_item, args
    if self.line_items.map {|li| li.id}.include? line_item.id
      line_item.update_attributes!(args)
    else
      raise ArgumentError, "Line item #{line_item.id} does not exist for sub service request #{self.id} "
    end

    line_item
  end

  # SO MANY IFS
  def subsidy_organization
    if self.organization.subsidy_map
      if self.organization.subsidy_map.max_dollar_cap and self.organization.subsidy_map.max_dollar_cap > 0
        return self.organization
      elsif self.organization.subsidy_map.max_percentage and self.organization.subsidy_map.max_percentage > 0
        return self.organization
      else
        self.organization.parents.each do |parent|
          if parent.type == "Institution"
            return parent
          else
            if parent.subsidy_map.max_dollar_cap and parent.subsidy_map.max_dollar_cap > 0
              return parent
            elsif parent.subsidy_map.max_percentage and parent.subsidy_map.max_percentage > 0
              return parent
            end
          end
        end
      end
    end
  end

  def eligible_for_subsidy?
    eligible = true
    eligible = false if self.subsidy_organization.funding_source_excluded_from_subsidy?(self.service_request.protocol.try(:funding_source_based_on_status))
    eligible = false unless self.subsidy_organization.eligible_for_subsidy?
    
    eligible
  end
  ###############################################################################
  ######################## FULFILLMENT RELATED METHODS ##########################
  ###############################################################################

  ########################
  ## SSR STATUS METHODS ##
  ########################
  def ctrc?
    self.organization.id == 14
  end

  def can_be_edited?
    ['draft', 'submitted', nil].include?(self.status) ? true : false
  end

  def candidate_statuses
    candidates = ["draft", "submitted", "in process", "complete"]
    #candidates.unshift("submitted") if self.can_be_edited?
    #candidates.unshift("draft") if self.can_be_edited?
    candidates << "ctrc review" if self.ctrc?
    candidates << "ctrc approved" if self.ctrc?
    candidates << "awaiting pi approval"
    candidates << "on hold"

    candidates
  end

  def status= status
    @prev_status = self.status || 'draft'
    super(status)
  end

  def update_past_status
    old_status = self.past_statuses.last
    if @prev_status and (not old_status or old_status.status != @prev_status)
      self.past_statuses.create(:status => @prev_status, :date => Time.now)
    end
  end

  ###################
  ## SSR OWNERSHIP ##
  ###################
  def candidate_owners
    candidates = []
    self.organization.all_service_providers.each do |sp|
      candidates << sp.identity
    end
    if self.owner
      candidates << self.owner unless candidates.detect {|x| x.id == self.owner_id}
    end

    candidates
  end

end
