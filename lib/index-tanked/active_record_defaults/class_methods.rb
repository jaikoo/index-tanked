module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def index_tank(options={}, &block)
        @index_tanked ||= ClassCompanion.new(self, options)
        @index_tanked.instance_exec &block
      end

      def search_index_tank(query, options={})
        SearchResult.new(index_tanked.add_fields_to_query(query), @index_tanked.index, self, options)
      end

      def add_all_to_index_tank(batch_size=1000)
        count = 0
        find_in_batches(:batch_size => batch_size) do |instances|
          documents = instances.map { |instance| instance.index_tanked.document_for_batch_addition }
          count += documents.size
          index_tanked.retry_on_error do
            index_tanked.index.batch_insert(documents)
          end
        end
        count
      end

    end
  end
end
