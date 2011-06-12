class Admin::PrivilegedUsersController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :correct_user_or_admin, :only => :show
  before_filter :admin_user, :only => [:index, :new, :create, :destroy,
                                       :edit_privileges, :update_privileges]

  def index
    @title = "Utilisateurs privilégiés"
    @admin_privileged_users = Admin::PrivilegedUser.all
  end

  def show
    @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Profil de : #{@admin_privileged_user.name}"
  end

  def new
    @admin_privileged_user = Admin::PrivilegedUser.new
    @title = "Nouvel utilisateur privilégié"
  end

  def create
    @admin_privileged_user = Admin::PrivilegedUser.new(params[:privileged_user])

    Admin::PrivilegedUser.privileges_list.each do |p|
      @admin_privileged_user[p] = params[:privileged_user][p]
    end

    if @admin_privileged_user.save
      #sign_in @privileged_user
      flash[:success] = "Utilisateur enregistré"
      redirect_to @admin_privileged_user
    else
      @title = "Nouvel utilisateur privilégié"
      @admin_privileged_user.password = ""
      @admin_privileged_user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Modifier son profil"
  end

  def update
    @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
    if @admin_privileged_user.update_attributes(params[:privileged_user])
      flash[:success] = "Profil mis à jour."
      redirect_to @admin_privileged_user
    else
      @title = "Modifier son profil"
      render 'edit'
    end
  end

  def edit_privileges
    @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Modifier les privilèges de #{@admin_privileged_user.name}"
  end

  def update_privileges
    @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
    # Un admin total ne peut pas se retirer le droit d'administration totale
    # Par contre il peut le faire pour les autres
    # Normalement, ça permet de garder au moins UN admin total
    keep_admin = true if current_privileged_user?(@admin_privileged_user) && @admin_privileged_user.admin == true

    Admin::PrivilegedUser.privileges_list.each do |p|
      @admin_privileged_user.update_attribute(p, params[:admin_privileged_user][p])
    end

    @admin_privileged_user.update_attribute(:admin, true) if keep_admin

    flash[:success] = "Privilèges Modifiés"
    redirect_to @admin_privileged_user
  end

  def destroy
    Admin::PrivilegedUser.find(params[:id]).destroy
    flash[:success] = "Utilisateur détruit"
    redirect_to admin_privileged_users_path
  end

  private

    def authenticate
      deny_access unless has_privileges? 
    end

    def correct_user
      @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
      redirect_to(root_path) unless current_privileged_user?(@admin_privileged_user)
    end

    def correct_user_or_admin
      if !privileges[:admin]
        @admin_privileged_user = Admin::PrivilegedUser.find(params[:id])
        redirect_to(root_path) unless current_privileged_user?(@admin_privileged_user)
      end
    end

    def admin_user
      redirect_to(root_path) unless privileges[:admin] == true
    end

end
