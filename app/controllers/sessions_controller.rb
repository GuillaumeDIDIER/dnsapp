class SessionsController < ApplicationController

  def new
    @title = "Se connecter"
  end

  def create
    #A changer : un utilisateur pourra se logger en admin
    user = nil
    sign_in user
    redirect_to root_path
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
