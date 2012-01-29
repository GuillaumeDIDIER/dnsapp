# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>

require 'record_extensions/ZeModules.rb'

class Admin::Ze::DnsARecordsController < Ze::DnsARecordsController

  skip_before_filter :correct_user
  before_filter :has_zone_privileges

  def new
    @record = DnsRecord.new_a
    @title = "Nouvelle entrée DNS de type A"
  end

  def create
    @record = DnsRecord.new_a
    @record.extend ZeDnsRecord #Magic !
    @record.host = params[:dns_record][:host]
    @record.data = params[:dns_record][:data]

    unless ZeHelper.check_ip? @record.data
      flash[:error] = "Cette ip n'est pas dans la zone élèves"
      redirect_to admin_ze_dns_a_records_path and return
    end

    duplicates = DnsRecord.where :rtype => 'A', :data => @record.data
    if duplicates.count > 0
      flash[:error] = "Cette adresse ip est déjà associée à un nom"
      @record = duplicates.first
      redirect_to admin_ze_dns_a_record_path(@record) and return
    end

    unless @record.check_host
      render 'new' and return
    end

    if ZeHelper.overwrite_upper_domain? @record
      @record.errors[:host] = "existe déjà su le domaine polytechnique.fr"
      render 'new' and return
    end

    if @record.valid?
      ptr_record = ReverseDnsRecord.new_ptr
      hash = reverse_host_and_zone_from_ip @record.data
      ptr_record.host = hash[:host]
      ptr_record.zone = hash[:zone]
      ptr_record.data = "#{@record.host}.#{@record.zone}."
      ptr_record.save!

      @record.save!

      ZeHelper.increment_serial
      flash[:success] = "Nom enregistré"
      redirect_to admin_ze_dns_a_record_path(@record)
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
      redirect_to admin_ze_dns_a_record_path(@record) and return
    end

    unless ZeHelper.check_ip? @record.data
      flash[:error] = "Cette ip n'est pas dans la zone élèves"
      redirect_to admin_ze_dns_a_records_path and return
    end

    if old_data != @record.data
      duplicates = DnsRecord.where :rtype => 'A', :data => @record.data
      if duplicates.count > 0
        flash[:error] = "Cette adresse ip est déjà associée à un nom"
        @record = duplicates.first
        redirect_to admin_ze_dns_a_record_path(@record) and return
      end
    end

    unless @record.check_host
      render 'edit' and return
    end

    if ZeHelper.overwrite_upper_domain? @record
      @record.errors[:host] = "existe déjà su le domaine polytechnique.fr"
      render 'edit' and return
    end

    if @record.valid?
      hash = reverse_host_and_zone_from_ip old_data
      hash2 = reverse_host_and_zone_from_ip @record.data
      ptr_record = ReverseDnsRecord.where( :rtype => 'PTR', :host => hash[:host], :zone => hash[:zone] ).first
      ptr_record.auto_cast
      ptr_record.host = hash2[:host]
      ptr_record.zone = hash2[:zone]
      ptr_record.data = "#{@record.host}.#{@record.zone}."
      ptr_record.save!

      @record.save!

      ZeHelper.increment_serial
      flash[:success] = "Nom mis à jour"
      redirect_to admin_ze_dns_a_record_path(@record)
    else
      @title = "Modifier le nom"
      render 'edit'
    end
  end

  def destroy
    @record = DnsRecord.find(params[:id])
    hash = reverse_host_and_zone_from_ip @record.data
    ptr_record = ReverseDnsRecord.where( :rtype => 'PTR', :host => hash[:host], :zone => hash[:zone] ).first

    @record.destroy
    ptr_record.destroy

    ZeHelper.increment_serial
    flash[:success] = "Nom supprimé"
    redirect_to admin_ze_dns_a_records_path
  end

  private

    #Override: we only want to do manipulate A records
    #and zone must be fine too
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'A'
        flash[:error] = "Le champ demandé n'est pas de type A"
        redirect_to admin_ze_dns_a_records_path
      end
      if @record.zone != ZeHelper.zone
        flash[:error] = "Le champ demandé n'est pas dans la zone '#{ZeHelper.zone}'"
        redirect_to admin_ze_dns_a_records_path
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
