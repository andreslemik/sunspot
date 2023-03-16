module Sunspot
  module Search
    class DateFacet
      def initialize(field, search, options)
        @field = field
        @search = search
        @options = options
      end

      def field_name
        @field.name
      end

      def rows
        @rows ||=
          begin
            data = @search.facet_response['facet_ranges'][@field.indexed_name]
            gap = (@options[:time_interval] || 86_400).to_i
            rows = []
            values = data['counts'].each_slice(2).map { |value| value }.to_h
            values.each_pair do |value, count|
              next unless value =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/

              start_time = @field.cast(value)
              end_time = start_time + gap
              rows << FacetRow.new(start_time..end_time, count, self)
            end
            if @options[:sort] == :count
              rows.sort! { |lrow, rrow| rrow.count <=> lrow.count }
            else
              rows.sort! { |lrow, rrow| lrow.value.first <=> rrow.value.first }
            end
            rows
          end
      end
    end
  end
end
