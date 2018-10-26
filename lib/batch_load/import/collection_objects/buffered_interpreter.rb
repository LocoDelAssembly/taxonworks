module BatchLoad
  class Import::CollectionObjects::BufferedInterpreter < BatchLoad::Import

    attr_accessor :source_id, :source_name, :create_time

    # @param [Hash] args
    def initialize(**args)
      @collection_objects = {}
      @create_time = args.delete(:create_time)
      @source_id = args.delete(:source_id)
      if @source_id.present?
        @source_name = Source.find(@source_id).name
      else
        @source_name = ''
      end
      super(args)
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_collection_objects
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:specimen] = []
        parse_result.objects[:citation] = []
        @processed_rows[i] = parse_result

        c_e = row['collecting_event']
        det = row['determinations']
        o_l = row['other_labels']

        if c_e.blank? && det.blank? && o_l.blank?
          parse_result.parse_errors << 'No strings provided for any buffered data.'
          next
        end

        begin # processing
          s = Specimen.new(
              buffered_collecting_event: c_e,
              buffered_determinations: det,
              buffered_other_labels: o_l,
              created_at: create_time.blank? ? nil : create_time
          )
          parse_result.objects[:specimen].push(s)
          if source_id.present?
            c = Citation.new(source_id: source_id,
                             citation_object: s)
            parse_result.objects[:citation].push(c)
          end
        rescue => _e
          raise(_e)
        end
      end

      @total_lines = i
    end

    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end
