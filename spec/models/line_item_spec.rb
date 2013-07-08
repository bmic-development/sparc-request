require 'spec_helper'

describe "Line Item" do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe 'applicable_rate' do
    it 'should raise an exception if it has a pricing setup but no pricing maps' do
      organization = FactoryGirl.create(:organization, :pricing_setup_count => 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)
      service = FactoryGirl.build(:service, :organization_id => organization.id, :pricing_map_count => 0)
      service.save!(validate: false)
      project = Project.create(FactoryGirl.attributes_for(:protocol), :validate => false)
      service_request = ServiceRequest.create(FactoryGirl.attributes_for(:service_request), protocol_id: project.id, :validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      lambda { line_item.applicable_rate }.should raise_exception(ArgumentError)
    end

    it 'should raise an exception if it has a pricing map but no pricing setups' do
      organization = FactoryGirl.create(:organization, :pricing_setup_count => 0)
      service = FactoryGirl.create(:service, :organization_id => organization.id, :pricing_map_count => 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today - 1)
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      service_request = ServiceRequest.create(FactoryGirl.attributes_for(:service_request), protocol_id: project.id, :validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      lambda { line_item.applicable_rate }.should raise_exception(ArgumentError)
    end

    it 'should call applicable_rate on the pricing map of a project with the applied percentage and rate type returned by the pricing setup' do
      # TODO: it's obvious by the complexity of this test that
      # applicable_rate() is doing too much, but I'm not sure how to
      # refactor it to be simpler.

      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.save(:validate => false)

      organization = FactoryGirl.create(:organization, :pricing_setup_count => 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)

      service = FactoryGirl.create(:service, :organization_id => organization.id, :pricing_map_count => 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)

      service_request = FactoryGirl.build(:service_request, protocol_id: project.id)
      service_request.save(:validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      line_item.service_request.protocol.stub(:funding_status).and_return('funded')
      line_item.service_request.protocol.stub(:funding_source).and_return('college')

      line_item.service.organization.pricing_setups[0].
        should_receive(:rate_type).
        with('college').
        and_return('federal')
      line_item.service.organization.pricing_setups[0].
        stub!(:applied_percentage).
        with('federal').
        and_return(0.42)

      service.pricing_maps[0] = double(:display_date => Date.today - 1)
      line_item.service.pricing_maps[0].
        should_receive(:applicable_rate).
        with('federal', 0.42)

      line_item.applicable_rate
    end
    
    it 'should call applicable_rate on the pricing map of a study with the applied percentage and rate type returned by the pricing setup' do
      # TODO: it's obvious by the complexity of this test that
      # applicable_rate() is doing too much, but I'm not sure how to
      # refactor it to be simpler.

      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.save(:validate => false)

      organization = FactoryGirl.create(:organization, :pricing_setup_count => 1)
      organization.pricing_setups[0].update_attributes(display_date: Date.today - 1)

      service = FactoryGirl.create(:service, :organization_id => organization.id, :pricing_map_count => 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)

      service_request = FactoryGirl.build(:service_request, protocol_id: study.id)
      service_request.save(:validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      line_item.service_request.protocol.stub(:funding_source_based_on_status).and_return('college')
      
      line_item.service.organization.pricing_setups[0].
        should_receive(:rate_type).
        with('college').
        and_return('federal')
      line_item.service.organization.pricing_setups[0].
        stub!(:applied_percentage).
        with('federal').
        and_return(0.42)

      service.pricing_maps[0] = double(:display_date => Date.today - 1)
      line_item.service.pricing_maps[0].
        should_receive(:applicable_rate).
        with('federal', 0.42)

      line_item.applicable_rate
    end
  end

  context "business methods" do

    describe "per_unit_cost" do

      before(:each) do
        line_item.stub!(:applicable_rate) { 100 }
      end

      it "should return the per unit cost for full quantity with no arguments" do
        line_item.per_unit_cost.should eq(100)
      end

      it "should return 0 if the quantity is 0" do
        line_item.quantity = 0
        line_item.per_unit_cost.should eq(0)
      end

      it "should return the per unit cost for a specific quantity from arguments" do
        line_item1 = line_item.dup
        line_item2 = line_item.dup
        line_item1.quantity = 5
        line_item1.per_unit_cost.should eq(line_item2.per_unit_cost(5))
      end
    end

    describe "units per package" do
       
      it "should select the correct pricing map based on display date" do
        pricing_map2.update_attributes(display_date: Time.now + 1.day)
        pricing_map.update_attributes(unit_factor: 5)
        pricing_map2.update_attributes(unit_factor: 10)
        line_item.units_per_package.should eq(5)
      end
    end

    describe "cost calculations" do

      before :each do
        pricing_map.update_attributes(unit_factor: 5)
        add_visits
      end

      context "direct costs for one time fee" do

        it "should return the correct direct cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          line_item.direct_costs_for_one_time_fee.should eq(2000)          
        end

        it "should return zero if quantity is nil" do
          line_item.update_attributes(quantity: nil)
          line_item.direct_costs_for_one_time_fee.should eq(0) 
        end
      end

      context "indirect cost rate" do

        it "should return the correct indirect cost rate related to the line item" do
          if USE_INDIRECT_COST
            line_item.indirect_cost_rate.should eq(2.0)
          else
            line_item.indirect_cost_rate.should eq(0)
          end
        end
      end

      context "indirect costs for one time fee" do

        it "should return the correct indirect cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          if USE_INDIRECT_COST
            line_item.indirect_costs_for_one_time_fee.should eq(400)
          else
            line_item.indirect_costs_for_one_time_fee.should eq(0)
          end
        end

        it "should return zero if the displayed pricing map is excluded from indirect costs" do
          pricing_map.update_attributes(is_one_time_fee: true, exclude_from_indirect_cost: true)
          line_item.indirect_costs_for_one_time_fee.should eq(0)
        end
      end
    end
  end
  context "methods" do
    before :each do
      add_visits
      build_clinical_data
    end
    describe "remove procedures" do
      it "should destroy all procedures linked to this line_item" do
        li_id = line_item2.id
        line_item2.destroy
        Procedure.find_by_line_item_id(li_id).should eq(nil)
      end
    end
  end
end
