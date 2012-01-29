# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>

require 'record_extensions/ZeModules.rb'

class Admin::Ze::DnsCnameRecordsController < DnsCnameRecordsController

  before_filter :has_zone_privileges

  def new
    @record = DnsRecord.new_cname
    @title = "Nouvelle entrée DNS de type CNAME"
  end

  def create
    @record = DnsRecord.new_cname
    @record.extend ZeDnsRecord #Magic !
    @record.host = params[:dns_record][:host]
    @record.data = params[:dns_record][:data]

    destination = DnsRecord.where :host => @record.data, :zone => @record.zone
    unless destination.count > 0
      flash[:error] = "La cible n'existe pas"
      render 'new' and return
    end

    unless @record.check_host
      render 'new' and return
    end

    if ZeHelper.overwrite_upper_domain? @record
      @record.errors[:host] = "existe déjà su le domaine polytechnique.fr"
      render 'new' and return
    end

    if @record.valid?
      @record.save!

      ZeHelper.increment_serial
      flash[:success] = "Nom enregistré"
      redirect_to admin_ze_dns_cname_record_path(@record)
    else
      @title = "Nouvelle entrée DNS de type A"
      render 'new'
    end
  end

  def update
    @record = DnsRecord.find(params[:id])
    @record.auto_cast
    @record.extend ZeDnsRecord #Magic !
    old_hostname = @record.host
    old_data     = @record.data
    @record.host = params[:dns_record][:host]
    @record.data = params[:dns_record][:data]

    if old_hostname == @record.host and old_data == @record.data
      flash[:notice] = "Tu as rentré les même informations"
      redirect_to admin_ze_dns_cname_record_path(@record) and return
    end

    destination = DnsRecord.where :host => @record.data, :zone => @record.zone
    unless destination.count > 0
      flash[:error] = "La cible n'existe pas"
      render 'new' and return
    end

    unless @record.check_host
      render 'edit' and return
    end

    if ZeHelper.overwrite_upper_domain? @record
      @record.errors[:host] = "existe déjà su le domaine polytechnique.fr"
      render 'edit' and return
    end

    if @record.valid?
      @record.save!

      ZeHelper.increment_serial
      flash[:success] = "Nom mis à jour"
      redirect_to admin_ze_dns_cname_record_path(@record)
    else
      @title = "Modifier le nom"
      render 'edit'
    end
  end

  def destroy
    @record = DnsRecord.find(params[:id])

    @record.destroy

    ZeHelper.increment_serial
    flash[:success] = "Nom supprimé"
    redirect_to admin_ze_dns_cname_records_path
  end

  private

    #Override: we only want CNAME records in the good zone
    def set_conditions_and_title
      @conditions = ["zone = '#{ZeHelper.zone}' and rtype = 'CNAME'"]
      @title = "Tous les enregistrements de type CNAME"
    end

    #Override: we only want to do manipulate CNAME records
    #and zone must be fine too
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'CNAME'
        flash[:error] = "Le champ demandé n'est pas de type CNAME"
        redirect_to admin_ze_dns_cname_records_path
      end
      if @record.zone != ZeHelper.zone
        flash[:error] = "Le champ demandé n'est pas dans la zone '#{ZeHelper.zone}'"
        redirect_to iadmin_ze_dns_cname_records_path
      end
    end

    def has_zone_privileges
      zone = current_privileged_user.dns_zone.zone
      unless zone == ZeHelper.zone or privileges[:admin] == true
         flash[:error] = "Tu n'es administrateur de cette zone"
         redirect_to(root_path)
      end
    end

end
