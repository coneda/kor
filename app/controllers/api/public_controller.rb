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
        :current_history => Entity.
          includes(:medium).
          find_all_by_id_keep_order(session[:current_history]).
          map{|e| e.serializable_hash :root => false, :include => :medium, :except => [:attachment]},
        :show_panel => session[:show_session_info],
        :clipboard => session[:clipboard] || []
      },
      :config => {
        :max_file_size => Kor.config['app.max_file_upload_size'].to_f
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
        :auth => current_user.full_auth,
        :locale => current_user.locale
      }

      result[:session][:flash] = {
        :notice => flash[:notice],
        :error => flash[:error]
      }
    end

    render :json => result.as_json
  end
  

  protected
  
    def require_user?
      false
    end
    
    def authorized?
      true
    end
    
end
