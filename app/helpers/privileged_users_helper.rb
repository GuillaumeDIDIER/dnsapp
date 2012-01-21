# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods to handle privileged users.

module PrivilegedUsersHelper

  def current_privileged_user=(privileged_user)
    @current_privileged_user = privileged_user
  end

  def current_privileged_user
    @current_privileged_user ||= privileged_user_from_remember_token
  end

  def current_privileged_user?(privileged_user)
    privileged_user == current_privileged_user
  end

  def sign_in(privileged_user)
    session[:remember_token] = [privileged_user.id, privileged_user.salt]
    self.current_privileged_user = privileged_user
  end

  def sign_out
    reset_session
    self.current_privileged_user = nil
  end

  def signed_in?
    !current_privileged_user.nil?
  end

  def privileges
    current_privileged_user.privileges if signed_in?
  end

  private

    def privileged_user_from_remember_token
      Admin::PrivilegedUser.authenticate_with_salt(*remember_token)
    end

    def remember_token
      session[:remember_token] || [nil, nil]
    end

end
