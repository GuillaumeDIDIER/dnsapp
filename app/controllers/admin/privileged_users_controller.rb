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

    Admin::PrivilegedUser.privileges_list.each do |p|
      @privileged_user[p] = params[:admin_privileged_user][p]
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
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    @title = "Modifier son profil"
  end

  def update
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
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
    # Un admin total ne peut pas se retirer le droit d'administration totale
    # Par contre il peut le faire pour les autres
    # Normalement, ça permet de garder au moins UN admin total
    keep_admin = true if current_privileged_user?(@privileged_user) && @privileged_user.admin == true

    Admin::PrivilegedUser.privileges_list.each do |p|
      @privileged_user[p] = params[:admin_privileged_user][p]
    end

    flash[:warning] = "Tu ne peux pas te retirer le droit d'administrateur total" if keep_admin && @privileged_user[:admin] == false
    @privileged_user[:admin] = true if keep_admin
    #Admin::PrivilegedUser.skip_callback(:save, :before, :encrypt_password)
    @privileged_user.dont_save_password
    @privileged_user.save(false)
    @privileged_user.do_save_password
    flash[:success] = "Privilèges Modifiés"
    redirect_to @privileged_user
  end

  def destroy
    @privileged_user = Admin::PrivilegedUser.find(params[:id])
    keep_admin = true if current_privileged_user?(@privileged_user) && @privileged_user.admin == true
    @privileged_user.destroy unless keep_admin
    flash[:success] = "Utilisateur détruit"
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
      if  privileges[:admin] != true
        flash[:error] = "Il faut être administrateur total pour accéder à cette ressource"
        redirect_to(root_path)
      end
    end

end
