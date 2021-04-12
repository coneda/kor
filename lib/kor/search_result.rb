class Kor::SearchResult
  def initialize(attrs = {})
    assign attrs
  end

  def self.empty
    new(
      total: 0,
      uuids: [],
      ids: [],
      raw_records: [],
      page: 1,
      per_page: 10
    )
  end

  attr_writer :records, :total, :page, :per_page, :ids, :uuids

  def assign(attrs = {})
    attrs.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def page
    @page || 1
  end

  def per_page
    @per_page || 20
  end

  def uuids
    @uuids || []
  end

  def ids
    @ids || []
  end

  def total
    @total || 0
  end

  def records
    @records ||= begin
      if @ids.present?
        Entity.where(id: @ids).to_a.sort do |x, y|
          @ids.index(x.id) <=> @ids.index(y.id)
        end
      elsif @uuids.present?
        Entity.where(uuid: @uuids).to_a.sort do |x, y|
          @uuids.index(x.uuid) <=> @uuids.index(y.uuid)
        end
      else
        []
      end
    end
  end

  # attr_writer :uuids, :ids, :records, :total, :page, :per_page, :raw_records

  # def total_pages
  #   @total_pages ||= (total / per_page) + 1
  # end

  # def raw_records
  #   @raw_records || []
  # end

  # def assign_attributes(attrs)
  #   attrs.each do |key, value|
  #     send "#{key}=", value
  #   end
  # end
end
