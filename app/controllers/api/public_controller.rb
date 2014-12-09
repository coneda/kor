class Api::PublicController < Api::ApiController
  
  def info
    result = {
      :info => {
        :version => Kor.version,
        :maintainer => "Coneda UG",
        :url => root_url
      },
      :stats => { 
        :entities => Entity.count,
        :kinds => Kind.count,
        :relations => Relation.count,
        :relationships => Relationship.count,
        :users => User.count,
      },
      :session => {
        :user => {},
        :history => session[:history],
        :current_history => Entity.includes(:medium).find_all_by_id_keep_order(session[:current_history]).map{|e| e.serializable_hash :root => false, :include => :medium},
        :show_panel => session[:show_session_info],
        :clipboard => session[:clipboard] || []
      },
      :translations => I18n.backend.send(:translations),
      :locale => I18n.locale
    }
    
    if current_user
      result[:session][:user] = {
        :display_name => current_user.display_name,
        :id => current_user.id,
        :name => current_user.name,
        :email => current_user.email,
        :credits => {
          :amount => current_user.credits,
          :in_a_row => Api::Engagement.in_a_row(current_user)
        },
        :credits => current_user.credits,
        :auth => current_user.full_auth,
        :locale => current_user.locale
      }

      result[:session][:flash] = {
        :notice => flash[:notice],
        :error => flash[:error]
      }
    end

    render :json => result
  end
  
  
  def login
    if @user = User.authenticate(params[:username], params[:password])
      session[:user_id] = @user.id
      session[:expires_at] = Kor.session_expiry_time
      @user.update_attributes(:last_login => Time.now)
      render :json => @user.to_json(:methods => [:credits]), :status => 200
    elsif session[:user_id]
      render_notice :already_authenticated
    else
      render_error :bad_credentials, 401
    end
  end
  
  def logout
    reset_session
    render_notice :logged_out
  end
  
  def log
    @data = params
    
    ['action', 'version', 'controller'].each do |i|
      @data.delete i
    end
    
    Rails.logger.info "-------- JS CONSOLE LOG:\n" + @data.inspect + "\n-------- END JS CONSOLE"
    render :nothing => true
  end
  

  protected
  
    def require_user?
      false
    end
    
    def authorized?
      true
    end
    
end
