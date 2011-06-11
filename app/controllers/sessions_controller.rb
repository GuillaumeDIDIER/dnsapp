# encoding: utf-8
class SessionsController < ApplicationController

  def new
    @title = "Se connecter"
  end

  def create
    #A changer : un utilisateur pourra se logger en admin
    #user = nil
    #sign_in user
    privileged_user = PrivilegedUser.authenticate(params[:session][:name],
                                                  params[:session][:password])
    if privileged_user.nil?
      flash.now[:error] = "Echec de l'authentification"
      @title = "Se connecter"
      render 'new'
    else
      sign_in privileged_user
      redirect_back_or privileged_user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
