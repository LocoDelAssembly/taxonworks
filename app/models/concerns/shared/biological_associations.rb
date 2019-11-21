=begin
Shared code for extending data classes with an OriginRelationship

  How to use this concern:
    1) In BOTH related models, Include this concern (`include Shared::OriginRelationship`)
    2) In the "old" model call "is_origin_for" with valid class names, as strings, e.g.:
       `is_origin_for 'CollectionObject', 'CollectionObject::BiologicalCollectionObject'`
    3) has_many :derived_<foo> associations are created for each is_origin_for()

    !! You must redundantly provide STI subclasses and parent classes if you want to allow both.  Providing
       a superclass does *not* provide the subclasses.

=end
module Shared::BiologicalAssociations
  extend ActiveSupport::Concern

  included do
    related_class = self.name
    klass = related_class.tableize.singularize.safe_constantize

    has_many :biological_associations, as: :biological_association_subject, inverse_of: :biological_association_subject, dependent: :restrict_with_error
    has_many :related_biological_associations, as: :biological_association_object, inverse_of: :biological_association_object, class_name: 'BiologicalAssociation'

    define_singleton_method :with_biological_associations do
      joins("LEFT OUTER JOIN biological_associations tnr1 ON otus.id = tnr1.biological_association_subject_id AND tnr1.biological_association_object_type = '#{related_class }'"). # OTU
        joins("LEFT OUTER JOIN biological_associations tnr2 ON otus.id = tnr2.biological_association_object_id AND tnr2.biological_association_object_type = '#{related_class}'").
        where('tnr1.biological_association_object_id IS NOT NULL OR tnr2.biological_association_object_id IS NOT NULL')
    end

  end

  # @return [Array]
  #   all bilogical associations this Otu is part of
  # !! If self relationships are ever made possible this needs a DISTINCT clause
  def all_biological_associations
    BiologicalAssociation.find_by_sql(
      "SELECT biological_associations.*
        FROM biological_associations
        WHERE biological_associations.biological_association_subject_id = #{id} 
          AND biological_associations.biological_association_subject_type = '#{self.class.base_class.name}'
      UNION
      SELECT biological_associations.*
        FROM biological_associations
        WHERE biological_associations.biological_association_object_id = #{id}
          AND biological_associations.biological_association_object_type = '#{self.class.base_class.name}'")
  end

  # scope :with_biological_associations, -> {
  #   joins("LEFT OUTER JOIN biological_associations tnr1 ON otus.id = tnr1.biological_association_subject_id AND tnr1.biological_association_object_type = 'Otu'").
  #   joins("LEFT OUTER JOIN biological_associations tnr2 ON otus.id = tnr2.biological_association_object_id AND tnr2.biological_association_object_type = 'Otu'").
  #   where('tnr1.biological_association_object_id IS NOT NULL OR tnr2.biological_association_object_id IS NOT NULL')
  # }

#   attr_accessor :origin
#   accepts_nested_attributes_for :origin_relationships, reject_if: :reject_origin_relationships
#   before_validation :set_origin, if: -> {origin.present?}

#  end

  # def set_origin
  #   [origin].flatten.each do |object|
  #     related_origin_relationships.build(old_object: object)
#   end
# end

  module ClassMethods

    # @param relationship [Array, String]
    def with_biological_relationship_ids(biological_relationship_ids) 
      a = joins(:biological_associations).where(biological_associations: {biological_relationship_id: biological_relationship_ids})
      b = joins(:related_biological_associations).where(biological_associations: {biological_relationship_id: biological_relationship_ids})
      
      from("((#{a.to_sql}) UNION (#{b.to_sql})) as #{base_class.table_name}")
    end
  
    # @param biological_relationship_ids [Array]
# def self.with_biological_relationship_ids(biological_relationship_ids)
#   a = TaxonName.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
#   b = TaxonName.joins(:related_taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
#   TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
# end

    
    
    #   def is_origin_for(*args)
#     if args.length == 0
#       raise ArgumentError.new('is_origin_for must have an array full of valid target tables supplied!')
#     end

#     # @return [Array of Strings]
#     #   valid new_object Classes
#     define_method :valid_new_object_classes do
#       args
#     end

#     # @return [Array of Strings]
#     #   valid new_object Classes
#     define_singleton_method :valid_new_object_classes do
#       args
#     end

#     args.each do |a|
#       relationship = 'derived_' + a.demodulize.tableize
#       has_many relationship.to_sym, source_type: a, through: :origin_relationships, source: :new_object
#     end
#   end
  end

# # @return [Objects]
# #   an array of instances, the source of this object
# def old_objects
#   related_origin_relationships.collect{|a| a.old_object}
# end

# # @return [Objects]
# #   an array of instances
# def new_objects
#   origin_relationships.collect{|a| a.new_object}
# end

  private

# def reject_origin_relationships(attributes)
#   o = attributes['new_object']
#   if !defined? valid_new_object_classes
#     raise NoMethodError.new("#{self.class.name} missing module 'Shared::OriginRelationship' or \"is_origin_for()\" is not being called")
#   end

#   o.blank? || !valid_new_object_classes.include?(o.class.name)
# end
end
