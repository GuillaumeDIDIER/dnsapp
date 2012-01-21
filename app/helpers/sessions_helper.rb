# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods to gracefully deny access to pages that requires authentication (privileged user).

module SessionsHelper

  #To deny access
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Il faut être connecté pour accéder à cette page"
  end

  #To redirect to requested page if any or to a default page (=profile).
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end

end
