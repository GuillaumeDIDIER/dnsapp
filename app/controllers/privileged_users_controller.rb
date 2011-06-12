class PrivilegedUsersController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :correct_user_or_admin, :only => :show
  before_filter :admin_user, :only => [:index, :new, :create, :destroy,
                                       :edit_privileges, :update_privileges]

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
    @privileged_user = PrivilegedUser.new(params[:privileged_user])

    PrivilegedUser.privileges_list.each do |p|
      @privileged_user[p] = params[:privileged_user][p]
    end

    if @privileged_user.save
      #sign_in @privileged_user
      flash[:success] = "Utilisateur enregistré"
      redirect_to @privileged_user
    else
      @title = "Nouvel utilisateur privilégié"
      @privileged_user.password = ""
      @privileged_user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    @privileged_user = PrivilegedUser.find(params[:id])
    @title = "Modifier son profil"
  end

  def update
    @privileged_user = PrivilegedUser.find(params[:id])
    if @privileged_user.update_attributes(params[:privileged_user])
      flash[:success] = "Profil mis à jour."
      redirect_to @privileged_user
    else
      @title = "Modifier son profil"
      render 'edit'
    end
  end

  def edit_privileges
    @privileged_user = PrivilegedUser.find(params[:id])
    @title = "Modifier les privilèges de #{@privileged_user.name}"
  end

  def update_privileges
    @privileged_user = PrivilegedUser.find(params[:id])
    # Un admin total ne peut pas se retirer le droit d'administration totale
    # Par contre il peut le faire pour les autres
    # Normalement, ça permet de garder au moins UN admin total
    keep_admin = true if current_privileged_user?(@privileged_user) && @privileged_user.admin == true

    PrivilegedUser.privileges_list.each do |p|
      @privileged_user.update_attribute(p, params[:privileged_user][p])
    end

    @privileged_user.update_attribute(:admin, true) if keep_admin

    flash[:success] = "Privilèges Modifiés"
    redirect_to @privileged_user
  end

  def destroy
    PrivilegedUser.find(params[:id]).destroy
    flash[:success] = "Utilisateur détruit"
    redirect_to privileged_users_path
  end

  private

    def authenticate
      deny_access unless has_privileges? 
    end

    def correct_user
      @privileged_user = PrivilegedUser.find(params[:id])
      redirect_to(root_path) unless current_privileged_user?(@privileged_user)
    end

    def correct_user_or_admin
      if !privileges[:admin]
        @privileged_user = PrivilegedUser.find(params[:id])
        redirect_to(root_path) unless current_privileged_user?(@privileged_user)
      end
    end

    def admin_user
      redirect_to(root_path) unless privileges[:admin] == true
    end

end
