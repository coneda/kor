Bundler.require :import_export

class Kor::Export::Excel

  def initialize(target_dir, options = {})
    @target_dir = target_dir
    @options = options.reverse_merge(
      :batch_size => 10000
    )
  end

  def run
    system "mkdir -p #{@target_dir}"
    system "rm -f #{@target_dir}/entities.*.xls"

    entities
  end

  def scope
    Entity.
      includes(:kind).
      within_collections(@options[:collection_id]).
      only_kinds(@options[:kind_id])
  end

  def entities
    counter = 0
    scope.find_in_batches :batch_size => @options[:batch_size] do |entities|
      counter += 1

      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      columns.each_with_index do |column, i|
        if column[:ro]
          sheet.column(i).default_format = ro_format
        end
        sheet[0, i] = column[:name]
      end

      entities.each_with_index do |entity, i|
        sheet.update_row(i + 1,
          entity.id, entity.uuid,
          nil,
          entity.name, entity.distinct_name, entity.read_attribute(:no_name_statement),
          entity.collection_id, entity.collection.name,
          entity.kind_id, entity.kind.name,
          entity.created_at, entity.updated_at,
          entity.subtype,
          JSON.dump(entity.synonyms),
          entity.comment,
          JSON.dump(entity.datings.map{|d| d.serializable_hash_for_export}),
          JSON.dump(entity.dataset),
          JSON.dump(entity.properties),
          entity.lock_version
        )
      end
      
      book.write "#{@target_dir}/entities.#{counter.to_s.rjust 4, '0'}.xls"
    end
  end

  def ro_format
    @ro_format ||= Spreadsheet::Format.new :color => :orange
  end

  def columns
    @columns ||= [
      {:name => "id", :ro => true}, # 0
      {:name => "uuid", :ro => true},
      {:name => "delete"},
      {:name => "name"},
      {:name => "distinct_name"},
      {:name => "no_name_statement"}, # 5
      {:name => "collection_id"},
      {:name => "collection_name", :ro => true},
      {:name => "kind_id", :ro => true},
      {:name => "kind_name", :ro => true},
      {:name => "created_at", :ro => true}, # 10
      {:name => "updated_at", :ro => true},
      {:name => "subtype"},
      {:name => "synonyms"},
      {:name => "comment"},
      {:name => "datings"}, # 15
      {:name => "dataset"},
      {:name => "properties"},
      {:name => "lock_version", :ro => true},
    ]
  end

end