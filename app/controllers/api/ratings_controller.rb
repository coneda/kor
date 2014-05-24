module Api
  class RatingsController < ApiController

    skip_before_filter :api_auth, :only => :summary
  
    def index
      @ratings = Rating.all
      respond_with(@ratings)
    end
    
    def show
      @rating = Rating.find(params[:id])
      respond_with(@rating)
    end
    
    def new
      @rating = Rating.next_entity(params[:namespace])
      @entity = @rating.entity
      
      if @entity.is_a? Entity
        redirect_to api_entity_path(@entity, :rating_id => @rating.id)
      else
        render :json => @entity
      end
    end
    
    def create
      if session[:in_a_row] == nil || session[:in_a_row] > 1000
        session[:in_a_row] = 0
      end
      session[:in_a_row] += 1
    
      @rating = Rating.where(:state => 'open').find(params[:rating_id])
      @rating.state = 'done'
      @rating.assign_attributes params[:rating]
      @rating.user_id = current_user.id
      
      if @rating.save
        @engagement = reward(:on => @rating, :in_a_row => session[:in_a_row])
        render :json => @engagement.to_json(:methods => [:user_credits, :in_a_row]), :status => 201
      else
        respond_with(@rating)
      end
    end
    
    def destroy
      @rating = Rating.find(params[:id])
      @rating.destroy
      respond_with(@rating)
    end
    
    def summary
      @ratings = Api::Rating.includes(:entity).where("ratings.state = 'done' AND entities.collection_id IN (18, 19)").all.group_by do |x|
        x.entity_id
      end

      @max = @ratings.values.map{|ds| ds.size}.max
    end
    
    def unconclusive
      @ratings = Api::Rating.includes(:entity).where("ratings.state = 'done' AND entities.collection_id IN (18, 19)").all.group_by do |x|
        x.entity_id
      end

      @max = @ratings.values.map{|ds| ds.size}.max
    end
    

    protected

      def require_user?
        return false if action_name == "summary"
        true
      end
    
      def authorized?
        case action_name
          when 'index', 'show', 'destroy' then current_user.rating_admin?
          when 'new', 'create' then true
          when "summary", "unconclusive" then true
          else
            raise "no authorization rules for action #{action_name}"
        end
      end
    
  end
end
