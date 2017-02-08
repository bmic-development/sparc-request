class StudyPhase < ActiveRecord::Base
  has_and_belongs_to_many :protocols
  attr_accessible :order, :phase, :version

  scope :v1, -> { where(version: 1)  }  
end
