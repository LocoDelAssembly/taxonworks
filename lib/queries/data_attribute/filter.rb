module Queries
  module DataAttribute 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to DataAttribute
      attr_accessor :value, :controlled_vocabulary_term_id, :import_predicate, :type

      # @params params [ActionController::Parameters]
      def initialize(params)
        @value = params[:value]
        @controlled_vocabulary_term_id = [params[:controlled_vocabulary_term_id]].flatten.compact
        @import_predicate = params[:import_predicate]
        @type = params[:type]
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::DataAttribute),
          matching_type,
          matching_value,
          matching_import_predicate,
          matching_controlled_vocabulary_term_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_value
        value.blank? ? nil : table[:value].eq(value) 
      end

      # @return [Arel::Node, nil]
      def matching_import_predicate
        import_predicate.blank? ? nil : table[:import_predicate].eq(import_predicate) 
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type) 
      end

      # @return [Arel::Node, nil]
      def matching_controlled_vocabulary_term_id
        controlled_vocabulary_term_id.blank? ? nil : table[:controlled_vocabulary_term_id].eq_any(controlled_vocabulary_term_id) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::DataAttribute.where(and_clauses)
        else
          ::DataAttribute.none
        end
      end

      # @return [Arel::Table]
      def table
        ::DataAttribute.arel_table
      end
    end
  end
end