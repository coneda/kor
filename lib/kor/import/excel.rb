Bundler.require :import_export

class Kor::Import::Excel < Kor::Export::Excel

  def initialize(source_dir, options = {})
    @source_dir = source_dir
    @options = options.reverse_merge(
      ignore_stale: false,
      username: "admin",
      obey_permissions: false,
      simulate: false,
      verbose: true,
      ignore_validations: false
    )
    @options[:verbose] = true if @options[:simulate]
    @user = User.find_by_name!(@options[:username])
  end

  attr_accessor :file
  attr_accessor :row
  attr_accessor :entity

  def run
    if @options[:simulate]
      log "SIMULATION"
    end

    if @options[:ignore_stale]
      ActiveRecord::Base.lock_optimistically = false
    end

    Dir["#{@source_dir}/*.xls"].each do |file|
      book = Spreadsheet.open file, "rb"
      self.file = file.split('/').last
      sheet = book.worksheet 0

      sheet.each_with_index 1 do |row, i|
        self.row = i + 2

        uuid = row[1]
        self.entity = if uuid
          Entity.where(:uuid => uuid).first
        else
          Entity.new :creator => @user, :updater => @user
        end

        if entity
          if row[2].present?
            log "file #{file}, row #{i + 2} destroying entity id #{row[0]}"
            entity.destroy unless @options[:simulate]
          else
            synonyms = json_parse(row[13], [])
            dataset = json_parse(row[16], {})
            properties = json_parse(row[17], [])
            datings = synchronize_datings(entity, json_parse(row[15], []))

            if synonyms.nil? || dataset.nil? || properties.nil?
              log "error parsing json"
              next
            end

            serialized_changes = (
              entity.new_record? ||
              entity.synonyms != synonyms ||
              entity.dataset != dataset ||
              entity.properties != properties
            )

            entity.assign_attributes(
              name: row[3],
              distinct_name: row[4],
              no_name_statement: row[5],
              collection_id: row[6],
              subtype: row[12],
              comment: row[14],
              datings: datings,
              synonyms: synonyms,
              dataset: dataset,
              properties: properties,
              updater: @user,
              kind_id: row[8],
              lock_version: row[18]
            )

            # binding.pry

            if entity.changed? || serialized_changes || entity.datings.any?{|d| d.changed?}
              if entity.valid?
                if @options[:obey_permissions]
                  if entity.new_record?
                    if allowed_to?(:create, entity.collection_id)
                      log "saving: #{entity.changes.inspect}"
                      entity.save unless @options[:simulate]
                    else
                      log "permission denied to create entity"
                    end
                  else
                    if entity.collection_id_changed?
                      if allowed_to?(:delete, entity.collection_id_was) && allowed_to?(:create, entity.collection_id)
                        log "saving: #{entity.changes.inspect}"
                        entity.save unless @options[:simulate]
                      else
                        log "permission denied to move entity"
                      end
                    else
                      if allowed_to?(:edit, entity.collection_id)
                        log "saving: #{entity.changes.inspect}"
                        entity.save unless @options[:simulate]
                      else
                        log "permission denied to edit entity"
                      end
                    end
                  end
                else
                  log "saving: #{entity.changes.inspect}"
                  entity.save unless @options[:simulate]
                end
              else
                if @options[:ignore_validations]
                  log "invalid but saving anyhow: #{entity.errors.full_messages.inspect}"
                  entity.save(:validate => false) unless @options[:simulate]
                else
                  log "invalid: #{entity.errors.full_messages.inspect}"
                end
              end
            else
              log "no changes -> ignoring"
            end
          end
        else
          log "not found"
        end
      end
    end
  end

  def json_parse(string, default = nil)
    JSON.parse(string)
  rescue => e
    log "couldn't parse '#{string}'"
    raise "an error ocurred, see above"
  end

  def log(message)
    if @options[:verbose]
      entity_desc = if entity && !entity.new_record?
        "entity id #{entity.id}"
      elsif row && row[1].present?
        "unknown entity"
      else
        "new entity"
      end
      puts "file #{file}, row #{row}, #{entity_desc}: #{message}"
    end
  end

  def allowed_to?(policy = :edit, collection_id = nil)
    collections = Collection.where(:id => collection_id).to_a
    ::Kor::Auth.allowed_to? @user, policy, collections
  end

  def synchronize_datings(entity, dating_attributes)
    results = entity.datings.to_a

    dating_attributes.each do |da|
      if da["id"]
        if existing = results.to_a.find{|d| d.id == da["id"]}
          existing.assign_attributes(da)
          log "EntityDating id #{da['id']} found ... updating to: #{existing.inspect}"
        else
          log "EntityDating id #{da['id']} doesn't exist, skipping datings"
        end
      else
        results += [EntityDating.new(da)]
      end
    end

    results = results.select do |dating|
      dating_attributes.find{|da| da['id'] == dating.id}
    end

    results
  end

end