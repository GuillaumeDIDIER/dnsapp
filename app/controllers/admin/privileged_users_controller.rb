# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Privileged Users controller

class Admin::PrivilegedUsersController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :correct_user_or_admin, :only => :show
  before_filter :admin_user, :only => [:index, :new, :create, :destroy,
                                       :edit_privileges, :update_privileges]

  def index
    @title = "Utilisateurs privilégiés"
    @privileged_users = Admin::PrivilegedUser.all
  end

  def show
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Profil de : #{@privileged_user.name}"
  end

  def new
    @privileged_user = Admin::PrivilegedUser.new
    @title = "Nouvel utilisateur privilégié"
  end

  def create
    @privileged_user = Admin::PrivilegedUser.new(params[:admin_privileged_user])

    if @privileged_user.save
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
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Modifier son profil"
  end

  def update
    @privileged_user = Admin::PrivilegedUser.find(params[:id])

    #This method is safe: user is not able to change is privileges
    if @privileged_user.update_attributes(params[:admin_privileged_user])
      flash[:success] = "Profil mis à jour."
      redirect_to @privileged_user
    else
      @title = "Modifier son profil"
      @privileged_user.password = ""
      @privileged_user.password_confirmation = ""
      render 'edit'
    end
  end

  def edit_privileges
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Modifier les privilèges de #{@privileged_user.name}"
  end

  def update_privileges
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    #A privileged user who has admin rights is not able to remove
    #this right from himself/herself. It is possible to do so for other users though.
    #The purpose of this policy is to always have at least
    #one (1) privileged user with admin rights.
    keep_admin = true if current_privileged_user?(@privileged_user) && @privileged_user.admin == true
    flash[:warning] = "Tu ne peux pas te retirer le droit d'administrateur total" if keep_admin && params[:admin_privileged_user][:admin] = false
    params[:admin_privileged_user][:admin] = true if keep_admin

    #User with admin rights doesn't need this
    params[:admin_privileged_user][:dns_zone_id] = 0 if params[:admin_privileged_user][:admin] = true

    #Update privileges, and make sure password is not overwriten
    @privileged_user.dont_save_password
    @privileged_user.update_attribute( :admin, params[:admin_privileged_user][:admin] )
    @privileged_user.update_attribute( :dns_zone_id, params[:admin_privileged_user][:dns_zone_id] )
    @privileged_user.update_attribute( :unauthorized_names, params[:admin_privileged_user][:unauthorized_names] )
    @privileged_user.do_save_password

    flash[:success] = "Privilèges Modifiés"
    redirect_to @privileged_user
  end

  def destroy
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    keep_admin = true if current_privileged_user?(@privileged_user) && @privileged_user.admin == true
    @privileged_user.destroy unless keep_admin
    flash[:success] = "Utilisateur supprimé"
    redirect_to admin_privileged_users_path
  end

  private

    def authenticate
      deny_access unless signed_in? 
    end

    def correct_user
      @privileged_user = Admin::PrivilegedUser.find(params[:id])
      redirect_to(root_path) unless current_privileged_user?(@privileged_user)
    end

    def correct_user_or_admin
      if !privileges[:admin]
        @privileged_user = Admin::PrivilegedUser.find(params[:id])
        redirect_to(root_path) unless current_privileged_user?(@privileged_user)
      end
    end

    def admin_user
      if privileges[:admin] != true
        flash[:error] = "Il faut être administrateur total pour accéder à cette ressource"
        redirect_to(root_path)
      end
    end

end
