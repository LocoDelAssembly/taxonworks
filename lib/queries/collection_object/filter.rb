module Queries
  module CollectionObject
    # !! does not inherit from base query

    # TODO 
    # - use date processing?
    # - remove all prepended 'query'
    # - add tests(?) for unchecked params
    # - syncronize with GIS/GEO

    # Use DateConcern

    class Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Identifiers

      # TODO: look for name collisions with CE filter

      # @return [Boolen, nil]
      #  true - order by updated_at
      #  false, nil - do not apply ordering 
      attr_accessor :recent 

      # [Array]
      #   only return objects with this collecting event ID
      attr_accessor :collecting_event_ids

      # All params managed by CollectingEvent filter are available here as well
      attr_accessor :collecting_event_query

      # @return [Array, nil]
      #    a list of Otu ids, matches one ot one only
      attr_accessor :otu_ids

      # @return [Protonym.id, nil]
      #   return all collection objects determined as an Otu that is self or descendant linked
      #   to this TaxonName
      attr_accessor :ancestor_id

      # @return [Boolean, nil]
      #   nil =  Match against all ancestors, valid or invalid  
      #   true = Match against only valid ancestors
      #   false = Match against only invalid ancestors 
      attr_accessor :validity

      # @return [Boolean, nil]
      #   nil = TaxonDeterminations match regardless of current or historical
      #   true = TaxonDetermination must be .current
      #   false = TaxonDetermination must be .historical
      attr_accessor :current_determinations 

      # @return [True, nil]
      attr_accessor :on_loan

      # @return [True, nil]
      attr_accessor :loaned

      # @return [True, nil]
      attr_accessor :never_loaned

      # @return [Array]
      #   of biocuration_class ids
      attr_accessor :biocuration_class_ids

      # @return [Array]
      #   of biological_relationship_ids
      attr_accessor :biological_relationship_ids

      # @return [True, False, nil]
      #   true - index is built
      #   false - index is not built
      #   nil - not applied
      attr_accessor :dwc_indexed

      # @param [Hash] args are permitted params
      def initialize(params)
        params.reject!{ |_k, v| v.blank? } # dump all entries with empty values

        @recent = params[:recent].blank? ? false : true

        @collecting_event_ids = params[:collecting_event_id].blank? ? [] : params[:collecting_event_id]

        @otu_ids = params[:otu_ids] || []
        @otu_descendants = (params[:otu_descendants]&.downcase == 'true' ? true : false) if !params[:otu_descendants].nil?

        @ancestor_id = params[:ancestor_id]

        @current_determinations = (params[:current_determinations]&.downcase == 'true' ? true : false) if !params[:current_determinations].nil?
        @validity = (params[:validity]&.downcase == 'true' ? true : false) if !params[:validity].nil?

        @on_loan = (params[:on_loan]&.downcase == 'true' ? true : false) if !params[:on_loan].nil?
        @loaned = (params[:loaned]&.downcase == 'true' ? true : false) if !params[:loaned].nil?
        @never_loaned = (params[:never_loaned]&.downcase == 'true' ? true : false) if !params[:never_loaned].nil?

        @biocuration_class_ids = params[:biocuration_class_ids] || []

        @biological_relationship_ids = params[:biological_relationship_ids] || []

        @collecting_event_query = Queries::CollectingEvent::Filter.new(params)

        @dwc_indexed =  (params[:dwc_indexed]&.downcase == 'true' ? true : false) if !params[:dwc_indexed].nil?

        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::CollectionObject.arel_table
      end

      def base_query
        ::CollectionObject.select('*')
      end

      # @return [Arel::Table]
      def collecting_event_table 
        ::CollectingEvent.arel_table
      end

      # @return [Arel::Table]
      def otu_table 
        ::Otu.arel_table
      end

      # @return [Arel::Table]
      def taxon_determination_table 
        ::TaxonDetermination.arel_table
      end

      def biocuration_facet
        return nil if biocuration_class_ids.empty?
        ::CollectionObject::BiologicalCollectionObject.joins(:biocuration_classifications).where(biocuration_classifications: {biocuration_class_id: biocuration_class_ids}) 
      end

      def biological_relationship_ids_facet
        return nil if biological_relationship_ids.empty?
        ::CollectionObject.with_biological_relationship_ids(biological_relationship_ids)
      end

      def loaned_facet
        return nil unless loaned 
        ::CollectionObject.loaned
      end

      def never_loaned_facet
        return nil unless never_loaned 
        ::CollectionObject.never_loaned
      end

      def on_loan_facet
        return nil unless on_loan
        ::CollectionObject.on_loan
      end

      def dwc_indexed_facet 
        return nil if dwc_indexed.nil?
        dwc_indexed ?
          ::CollectionObject.dwc_indexed :
          ::CollectionObject.dwc_not_indexed
      end

    # @return Scope
      def collecting_event_ids_facet
        return nil if collecting_event_ids.empty?
        table[:collecting_event_id].eq_any(collecting_event_ids)
      end

      def collecting_event_merge_clauses
        c = []

        # Convert base and clauses to merge clauses
        collecting_event_query.base_merge_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).merge( i ) 
        end
        c
      end

      def collecting_event_and_clauses
        c = []

        # Convert base and clauses to merge clauses
        collecting_event_query.base_and_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).where( i ) 
        end
        c
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Array]
      def base_and_clauses
        clauses = []

        clauses += [
          collecting_event_ids_facet
        ]
        clauses.compact!
        clauses
      end


      def base_merge_clauses
        clauses = []
        clauses += collecting_event_merge_clauses + collecting_event_and_clauses

        clauses += [
          otus_facet,
          ancestors_facet,
          matching_keyword_ids,   # See Queries::Concerns::Tags
          created_modified_facet, # See Queries::Concerns::Users
          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
          loaned_facet,
          on_loan_facet,
          dwc_indexed_facet,
          never_loaned_facet,
          biocuration_facet,
          biological_relationship_ids_facet
        ]

        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses        
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        # q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::CollectionObject.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::CollectionObject.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

      # @return [Scope]
      def otus_facet
        return nil if otu_ids.empty?

        w = taxon_determination_table[:biological_collection_object_id].eq(table[:id])
          .and( taxon_determination_table[:otu_id].eq_any(otu_ids) )

        if current_determinations 
          w = w.and(taxon_determination_table[:position].eq(1))
        elsif current_determinations == false
          w = w.and(taxon_determination_table[:position].gt(1))
        end

        ::CollectionObject.where(
          ::TaxonDetermination.where(w).arel.exists
        )
      end

      def ancestors_facet
        return nil if ancestor_id.nil?
        h = Arel::Table.new(:taxon_name_hierarchies)
        t = ::TaxonName.arel_table

        q = table.join(taxon_determination_table, Arel::Nodes::InnerJoin).on(
          table[:id].eq(taxon_determination_table[:biological_collection_object_id])
        ).join(otu_table, Arel::Nodes::InnerJoin).on(
          taxon_determination_table[:otu_id].eq(otu_table[:id])
        ).join(t, Arel::Nodes::InnerJoin).on(
          otu_table[:taxon_name_id].eq(t[:id])
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:id].eq(h[:descendant_id])
        )

        z = h[:ancestor_id].eq(ancestor_id)

        if validity == true
          z = z.and(t[:cached_valid_taxon_name_id].eq(t[:id]))
        elsif validity == false
          z = z.and(t[:cached_valid_taxon_name_id].not_eq(t[:id]))
        end

        if current_determinations == true
          z = z.and(taxon_determination_table[:position].eq(1))
        elsif current_determinations == false
          z = z.and(taxon_determination_table[:position].gt(1))
        end

        ::CollectionObject.joins(q.join_sources).where(z)
      end

      # @return [Scope]
      def geographic_area_scope
        # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
        target_geographic_item_ids = []
        geographic_area_ids.each do |ga_id|
          target_geographic_item_ids.push(::GeographicArea.joins(:geographic_items)
            .find(ga_id)
            .default_geographic_item.id)
        end
        ::CollectionObject.joins(:geographic_items)
          .where(::GeographicItem.contained_by_where_sql(target_geographic_item_ids))
      end


    end

  end
end
