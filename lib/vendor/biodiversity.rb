module TaxonWorks
  module Vendor

    # Wraps the biodiversity gem (https://github.com/GlobalNamesArchitecture/biodiversity)
    # Links parsed string results to Protonyms/Combinations in TaxonWorks
    module Biodiversity

      # !! Values aren't used right now
      RANK_MAP = {
        genus: :genus,
        subgenus: :infragenus,
        species: :species,
        subspecies: :infraspecies,
        variety: :infraspecies,
        form: :infraspecies
      }.freeze

      class Result
        # query string
        attr_accessor :name

        # how to match
        attr_accessor :mode

        # project to query against
        attr_accessor :project_id

        # one of :iczn, :icn, :icnb
        attr_accessor :nomenclature_code

        # the result of a ScientificNameParser parse
        attr_accessor :parse_result

        # a summarized result, used to render JSON
        #   {
        #     protonyms: { genus: [ @protonym1, ...], ... }
        #     parse: { genus:  'Aus', species: 'bus', ...}
        #   }
        # Hash of rank => [Protonyms] like { genus: [<#>, <#>] }
        attr_reader :result

        # @return [String] the bit after ` in `
        attr_reader :citation

        attr_reader :parseable

        # query_string:
        #
        # mode:
        #   ranked: return names at that queried rank only (e.g. only match a subgenus to rank subgenus
        #   groups: return names at Group level (species or genus), i.e. a subgenus name in query will match genus OR subgenus in database
        def initialize(query_string: nil, project_id: nil, code: :iczn, match_mode: :groups)
          @project_id = project_id
          @name = query_string
          @nomenclature_code = code
          @mode = match_mode

          parse if !query_string.blank?
        end

        # @return [@parse_result]
        #   a Biodiversity name parser result
        def parse
          n, @citation = preparse

          begin
            @parse_result ||= ScientificNameParser.new.parse(n)
          rescue NoMethodError => e
            case e.message
            when /canonical/
              @parseable = false 
            else
              raise
            end
          end

          @parse_result
        end

        # @return [Boolean]
        def parseable
          @parseable = parse_result[:scientificName][:parsed] if @parseable.nil?
          @parseable 
        end

        # @return [Array]
        #  TODO: deprecate
        def preparse
          name.split(' in ')
        end

        # @return [Hash]
        def detail
          if parseable 
            a = parse_result[:scientificName]
            a ||= parse_result[:uninomial]
            return a[:details].first if a[:details]                 
          end
          {}
        end

        # @return [String, nil]
        def genus
          (detail[:genus] && detail[:genus][:string]) || (detail[:uninomial] && detail[:uninomial][:string])
        end

        # @return [String, nil] 
        def subgenus
          detail[:infragenus] && detail[:infragenus][:string]
        end

        # @return [String, nil]
        def species
          detail[:species] && detail[:species][:string]
        end

        # @return [String, nil]
        def subspecies
          infraspecies('n/a')
        end

        # @return [String, nil]
        def variety
          infraspecies('var.')
        end

        # @return [String, nil]
        def form
          infraspecies('form')
        end

        # @return [String, nil]
        def infraspecies(biodiversity_rank)
          if m = detail[:infraspecies]
            m.each do |n|
              return n[:string] if n[:rank] == biodiversity_rank
            end
          end
          nil 
        end

        # @return [Symbol, nil] like `:genus`
        def finest_rank
          RANK_MAP.keys.reverse.each do |k|
            return k if send(k)
          end
          nil
        end

        # @return [Hash, nil]
        def authorship
          if d = detail[finest_rank]
            d[:basionymAuthorTeam]
          end
        end

        # @return [String, nil]
        def author
          if a = authorship
            Utilities::Strings.authorship_sentence(a[:author])
          else
            nil
          end
        end

        def author_year
          [author, year].compact.join(', ')
        end

        # @return [String, nil]
        def year
          if a = authorship
            return a[:year]
          end
          nil
        end

        # return only references to ambiguous protonyms
        #
        # Parse 'form' 
        # Parse 'parse 'Var" 

        # @return [Boolean]
        #   true if there for each parsed piece of there name there is 1 and only 1 result
        def is_unambiguous?
          RANK_MAP.each_key do |r|
            if !send(r).nil?
              return false unless !send(r).nil? && !unambiguous_at?(r).nil?
            end
          end
          true
        end

        # @return [Boolean]
        def is_authored?
          author_year.size > 0
        end

        # @return [Protonym, nil]
        #   true if there is a single matching result or nominotypical subs
        def unambiguous_at?(rank)
          return protonym_result[rank].first if protonym_result[rank].size == 1
          if protonym_result[rank].size == 2
            n1 = protonym_result[rank].first
            n2 = protonym_result[rank].last
            return n2 if n2.nominotypical_sub_of?(n1) 
            return n1 if n1.nominotypical_sub_of?(n2) 
          end
          nil 
        end

        # @return [ String, false ]
        #   rank is one of `genus`, `subgenus`, `species, `subspecies`, `variety`, `form`
        def string(rank = nil)
          send(rank)
        end

        # @return [Scope]
        def basic_scope(rank)
          Protonym.where(
            project_id: project_id,
            name: string(rank)
          )
        end

        # @return [Scope]
        def protonyms(rank)
          case mode
          when :ranked
            ranked_protonyms(rank)
          when :groups
            grouped_protonyms(rank)
          else
            Protonym.none
          end
        end

        # @return [Scope]
        #    Protonyms at a given rank
        def ranked_protonyms(rank)
          basic_scope(rank).where(rank_class: Ranks.lookup(nomenclature_code, rank))
        end

        # @return [Scope]
        #   Protonyms grouped by nomenclatural group, for a rank
        def grouped_protonyms(rank)
          s = case rank
              when :genus, :subgenus
                basic_scope(rank).is_genus_group
              when :species, :subspecies, :variety, :form
                basic_scope(rank).is_species_group
              else
                Protonym.none
              end

          (is_authored? && finest_rank == rank) ? scope_to_author_year(s) : s
        end

        # @return [Scope]
        #  if there is an exact author year match scope it to that match, otherwise
        #     ignore the author year
        def scope_to_author_year(scope)
          t = scope.where('(cached_author_year = ? OR cached_author_year = ?)', author_year, author_year.gsub(' & ', ' and '))
          t.count > 0 ? t : scope
        end

        # @return [Hash]
        #   we inspect this internally, so it has to be decoupled
        def protonym_result
          h = {}
          RANK_MAP.each_key do |r|
            h[r] = protonyms(r).to_a
          end
          h
        end

        # @return [Hash]
        def parse_values
          h = {
            author: author,
            year: year
          }
          RANK_MAP.each_key do |r|
            h[r] = send(r)
          end
          h
        end

        # @return [Hash]
        #   summary for rendering purposes
        def result
          @result ||= build_result
        end

        # @return [Hash]
        def build_result
          @result = {}
          @result[:protonyms] = protonym_result
          @result[:parse] = parse_values
          @result[:unambiguous] = is_unambiguous?
          @result[:existing_combination_id] = combination_exists?.try(:id)
          @result[:other_matches] = other_matches
          @result
        end

        # @return [Combination]
        #   ranks that are unambiguous have their Protonym set
        def combination
          c = Combination.new
          RANK_MAP.each_key do |r|
            c.send("#{r}=", unambiguous_at?(r))
          end
          c
        end

        # @return [Combination, false]
        #    the Combination, if it exists
        def combination_exists?
          if is_unambiguous?
            Combination.match_exists?(combination.protonym_ids_params) # TODO: pass name?
          else
            false
          end
        end

        def author_word_position 
          if a = parse_result[:scientificName] 
            if b = a[:positions]
              c = b.select{|k,v| v[0] == 'author_word'}.keys.min
              p = [name.length, c].compact.min 
            end
          end
        end

        def name_without_author_year
          name[0..author_word_position - 1].strip 
        end

        # @return [Hash]
        #   `:verbatim` - names that have verbatim supplied, these should be the only names NOT parsed that user is interested in
        #   `:subgenus` - names that exactly match a subgenus, these are potential new combinations as Genus alone 
        def other_matches
          h = { 
            verbatim: [],
            subgenus: []
          }

          h[:verbatim] = TaxonName.where(project_id: project_id, cached: name_without_author_year).
            where('verbatim_name is not null').order(:cached).all.to_a if parseable
          
          h[:subgenus] = Protonym.where(
            project_id: project_id, 
            name: genus, 
            rank_class: Ranks.lookup(nomenclature_code, :subgenus)
          ).all.to_a

          h
        end

      end
    end
  end
end

