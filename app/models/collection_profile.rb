class CollectionProfile < ActiveRecord::Base

  include Housekeeping
  include SoftValidation

  belongs_to :container
  belongs_to :otu

  validates_presence_of :conservation_status, message: 'Conservation status is not selected'
  validates_presence_of :processing_state, message: 'Processing state is not selected'
  validates_presence_of :container_condition, message: 'Container condition is not selected'
  validates_presence_of :condition_of_labels, message: 'Condition of labels is not selected'
  validates_presence_of :identification_level, message: 'Identification level is not selected'
  validates_presence_of :arrangement_level, message: 'Arrangement level is not selected'
  validates_presence_of :data_quality, message: 'Data quality is not selected'
  validates_presence_of :computerization_level, message: 'Computerization_level is not selected'

  before_validation :validate_number

  def validate_number
    if self.number_of_collection_objects.nil? && self.number_of_containers.nil?
      errors.add(:number_of_collection_objects, 'At least one number of specimens or number of containers should be specified') if self.parent_id.blank?
      errors.add(:number_of_containers, 'At least one number of specimens or number of containers should be specified') if self.parent_id.blank?
    end
  end
end
