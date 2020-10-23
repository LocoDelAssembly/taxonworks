module Queries
  module TaxonNameRelationship
    class Filter < Queries::Query

      # @param taxon_name_id [Integer, nil]
      attr_accessor :taxon_name_id

      # @param as_object [Boolean, nil]
      #   if taxon_name_id and true then treat as subject
      attr_accessor :as_object

      # @param as_subject [Boolean, nil]
      #   if taxon_name_id and true then treat as subject
      attr_accessor :as_subject

      # @param taxon_name_relationship_type [String, Array, nil]
      #   the full class name like 'TaxonNameRelationship::..etc.', or an Array of them 
      attr_accessor :taxon_name_relationship_type

      # @param taxon_name_relationship_set [String, Array, nil]
      #   one or more of:
      #     'status',
      #     'synonym',
      #     'classification'
      # See corresponding constants in config/intialize/constants/taxon_name_relationships.rb
      attr_accessor :taxon_name_relationship_set

      # @param params [Params]
      def initialize(params)
        @taxon_name_id = params[:taxon_name_id]

        @as_object = (params[:as_object]&.downcase == 'true' ? true : false) if !params[:as_object].nil?
        @as_subject = (params[:as_subject]&.downcase == 'true' ? true : false) if !params[:as_subject].nil?

        @taxon_name_relationship_type = [params[:taxon_name_relationship_type]].flatten.compact
        @taxon_name_relationship_set = [params[:taxon_name_relationship_set]].flatten.compact

        @project_id = params[:project_id]
      end

      # @return [Arel::Table]
      def table
        ::TaxonNameRelationship.arel_table
      end

      # @return [Array]
      def relationship_types
        return [] unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        t = []
        # TODO of_types =>
        taxon_name_relationship_set.each do |i|
          t += STATUS_TAXON_NAME_RELATIONSHIP_NAMES if i == 'status'
          t += TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM if i == 'synonym'
          t += TAXON_NAME_RELATIONSHIP_NAMES_CLASSIFICATION if i == 'classification'
        end
        t
      end

      def taxon_name_relationship_set_facet
        return nil unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        table[:type].eq_any(relationship_types)
      end

      def taxon_name_relationship_type_facet
        return nil unless taxon_name_relationship_type && taxon_name_relationship_type.any?
        table[:type].eq_any(taxon_name_relationship_type)
      end

      # @return [ActiveRecord::Relation, nil]
      def as_subject_facet
        return nil unless taxon_name_id && as_subject
        table[:subject_taxon_name_id].eq(taxon_name_id)
      end

      # @return [ActiveRecord::Relation, nil]
      def as_object_facet
        return nil unless taxon_name_id && as_object
        table[:object_taxon_name_id].eq(taxon_name_id)
      end

      def as_either_facet
        return nil unless taxon_name_id && as_object.nil? && as_subject.nil?
        table[:subject_taxon_name_id].eq(taxon_name_id)
          .or(table[:object_taxon_name_id].eq(taxon_name_id))
      end

      def and_clauses
        clauses = []

        clauses += [
          taxon_name_relationship_type_facet,
          taxon_name_relationship_set_facet,
          as_subject_facet,
          as_object_facet,
          as_either_facet
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end     

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        # b = merge_clauses

        q = nil 
        if a
          q = ::TaxonNameRelationship.where(a)
        else
          q = ::TaxonNameRelationship.all
        end

        q = q.where(project_id: project_id) if project_id
        q
      end

      protected
    end

  end
end
