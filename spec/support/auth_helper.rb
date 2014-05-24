module AuthHelper
  
  def fake_authentication(options = {})
    options.reverse_merge!(:persist => false)
    
    if options[:persist]
      test_data_for_auth
      options[:user] ||= User.admin
    end
    
    options[:user] ||= User.make_unsaved(:admin)
    
    session[:user_id] = options[:user].id
    session[:expires_at] = Kor.session_expiry_time
  end
  
end
