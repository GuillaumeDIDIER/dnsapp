module SessionsHelper

  #!! admin_user not yet implemented
  def sign_in(admin_user)
    if admin_user.nil?
      user_ip = verify_ip current_ip
      if user_ip.nil?
        self.current_user = nil
      else
        #session[:remember_token] = { :ip => user_ip }
        self.current_user = { :ip => user_ip }
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

  def verify_ip(ip)
    #Règles de vérification d'adresse ip
    #Retourne nil si l'ip est mauvaise
    ip_tab = []
    ip.each('.') { |sub| ip_tab.insert(-1, sub.to_i) }
    valid = true
    valid = false unless ip_tab.count == 4
    valid = false unless ip_tab[0] == 129
    valid = false unless ip_tab[1] == 104
    valid = false unless (0..255).member? ip_tab[2]
    valid = false unless (0..255).member? ip_tab[3]
    ip if valid
    #nil
    #ip == "129.104.218.43" ? ip : nil
  end

  private

    def user_from_remember_token
      token = remember_token
      if token.nil?
        sign_in nil
	#self.current_user = nil
	#self.current_user
      else
        #{ :ip => remember_token[:ip] }
      end
    end

    def remember_token
      session[:remember_token] || nil
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end

end
