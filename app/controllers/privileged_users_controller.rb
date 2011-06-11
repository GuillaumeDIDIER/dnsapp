class PrivilegedUsersController < ApplicationController
  
  #before_filter :authenticate
  #before_filter :correct_user, :only => [:show, :edit, :update]
  #before_filter :admin_user, :only => [:index, :new, :create, :destroy]

  def index
    @title = "Utilisateurs privilégiés"
    @privileged_users = PrivilegedUser.all
  end

  def show
    @privileged_user = PrivilegedUser.find(params[:id])
    @title = "Profil de : #{@privileged_user.name}"
  end

  def new
    @privileged_user = PrivilegedUser.new
    @title = "Nouvel utilisateur privilégié"
  end

  def create
    @privileged_user = PrivilegedUser(params[:privileged_user])
    if @privileged_user.save
      sign_in @privileged_user
      flash[:success] = "Utilisateur enregistré"
      redirect_to @privileged_user
    else
      @title = "Nouvel utilisateur privilégié"
      @privileged_user.password = ""
      @privileged_user.password_confirmation = ""
      render 'new'
    end
  end

end
