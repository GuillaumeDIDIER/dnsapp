# encoding: utf-8
class Admin::ZonesController < ApplicationController

  before_filter :has_admin_privileges

  def index
    @title = "Toutes les zones"
    @zones = Admin::Zone.all
  end

  def show
    @zone = Admin::Zone.find(params[:id])
    @title = "Zone : #{@zone.name}"
  end

  def new
    @zone = Admin::Zone.new
    @title = "Nouvelle zone"
  end

  def create
    @zone = Admin::Zone.new(params[:admin_zone])
    if @zone.save
      flash[:success] = "Zone enregistrée"
      redirect_to @zone
    else
      @title = "Nouvelle zone"
      render 'new'
    end
  end

  def edit
    @zone = Admin::Zone.find(params[:id])
    @title = "Modifier : #{@zone.name}"
  end

   def update
     @zone = Admin::Zone.find(params[:id])
     if @zone.update_attributes(params[:admin_zone])
       flash[:success] = "Zone mise à jour"
       redirect_to @zone
     else
       @title = "Modifier : #{@zone.name}"
       render 'new'
     end
   end

   def destroy
     @zone = Admin::Zone.find(params[:id])
     @zone.destroy
     flash[:success] = "Zone supprimée"
     redirect_to admin_zones_path
   end

  private

    def has_admin_privileges
      if signed_in?
        if privileges[:admin] != true
          flash[:error] = "Tu n'as pas les droits sur cette ressource"
          redirect_to root_path
        end
      else
        deny_access
      end
    end

end
