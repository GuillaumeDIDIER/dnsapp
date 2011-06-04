module SessionsHelper

  #!! admin_user not yet implemented
  def sign_in(admin_user)
    if admin_user.nil?
      current_ip = verify_ip get_ip
      if current_ip.nil?
        self.current_user = nil
      else
        session[:remember_token] = { :ip => current_ip }
        self.current_user = { :ip => current_ip }
      end
    end
  end

  def sign_out
    reset_session
    self.current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end

  def deny_access
    store_location
    redirect_to dns_path, :notice => "Il faut être connecté pour accéder à cette page"
  end

  def current_user?(user)
    user[:ip] == current_user[:ip]
  end

  def current_ip
    request.remote_ip
  end

  private

    def verify_ip(ip)
      #Règles de vérification d'adresse ip
      #Retourne nil si l'ip est mauvaise
      ip
    end

    def user_from_remember_token
      token = remember_token
      if token.nil?
        sign_in nil
	self.current_user
      else
        { :ip => remember_token[:ip] }
      end
    end

    def remember_token
      session[:remember_token] || {}
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end

end
