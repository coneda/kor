class TransportController < ApplicationController
  skip_before_filter :maintenance, :authentication, :authorization
  before_filter :transport_auth
  
  def count
    klass = params[:class].constantize
    timestamp = Time.at params[:timestamp].to_i
    render :text => klass.count(:conditions => ['updated_at > ?', timestamp]).to_json
  end
  
  def show
    klass = params[:class].constantize
    inkl = params[:include].to_sym
    id = params[:id]
    render :text => klass.find(id, :include => inkl).to_json(:include => inkl)
  end
  
  def timestamps
    table = params[:table]
    result = ActiveRecord::Base.connection.execute("SELECT id, created_at, updated_at FROM #{table}")
    data = []
    while row = result.fetch_hash
      data << row
    end
    
    render :text => data.to_json
  end

  def entity_by_uuid
    entity = Entity.find_by_uuid(params[:uuid])
    if entity
      render :text => entity.to_json(:include => [:dataset, :properties, :synonyms])
    else
      render :nothing => true, :status => 404
    end
  end

  def relationships
    result = ActiveRecord::Base.connection.execute "
      SELECT r.id, r.from_id, r.to_id, fe.name, te.name
      FROM relationships r
        LEFT JOIN entities fe ON fe.id = r.from_id
        LEFT JOIN entities te ON te.id = r.to_id
    "
    data = []
    while row = result.fetch_hash
      data << row
    end

    render :text => data.to_json
  end
  
  def modifications
    klass = params[:class].constantize
    timestamp = Time.at params[:timestamp].to_i
    inkl = if params[:include]
      params[:include].map{|i| i.to_sym}
    else
      nil
    end
    render :text => klass.find(:all, :include => inkl, :conditions => ['updated_at > ? OR created_at > ?', timestamp, timestamp]).to_json(:include => inkl)
  end
  
  def images
    entities = Entity.find(:all, :conditions => ["id IN (?)", params[:entity_ids]], :include => :dataset).map do |entity|
      puts "IN"
      path = entity.dataset.file_path('original') || 'not_found'
      {:id => entity.id, :original_path => path}
    end
    render :text => entities.to_json
  end
  
  def ids
    table = params[:table]
    result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table}")
    data = []
    while row = result.fetch_hash
      data << row['id']
    end
    
    render :text => data.to_json
  end
  
  def tables
    table = params[:table]
    result = ActiveRecord::Base.connection.execute("SELECT * FROM #{table}")
    rows = []
    while r = result.fetch_hash
      rows << r
    end
    render :text => rows.to_json
  end
  
  private
    def transport_auth
      unless params[:key] == "8dfc21ea9c943e603a3d4dbd6149014d595ffa01"
        render :nothing => true, :status => 403
      end
    end
    
    def include_param
      params[:include] ? params[:include].map{|i| i.to_sym} : nil
    end
  
end
