# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#This controller lets people in "eleves.polytechnique.fr" zone
#modify their hostname.

require 'record_extensions/ZeModules.rb'

class Ze::DnsARecordsController < DnsARecordsController

  before_filter :correct_user, :only => [:edit, :update, :destroy]

  def new
    @record = DnsRecord.new_a
    @title = "Donner un nom à #{current_ip}"
  end

  def create
    @record = DnsRecord.new_a
    @record.extend ZeDnsRecord #Magic !
    @record.host = params[:dns_record][:host]
    @record.data = current_ip

    unless ZeHelper.check_ip? @record.data
      flash[:error] = "Ton ip n'est pas dans la zone élèves"
      redirect_to root_path and return
    end

    if @record.valid?
      ptr_record = ReverseDnsRecord.new_ptr
      hash = reverse_host_and_zone_from_ip current_ip
      ptr_record.host = hash[:host]
      ptr_record.zone = hash[:zone]
      ptr_record.data = "#{@record.host}.#{@record.zone}."
      ptr_record.save!

      @record.save

      ZeHelper.increment_serial
      flash[:success] = "Nom enregistré"
      redirect_to ze_dns_a_record_path(@record)
    else
      @title = "Donner un nom à #{current_ip}"
      render 'new'
    end
  end

  def edit
    @record = DnsRecord.find(params[:id])
    @title = "Modifier le nom"
  end

  def update
    @record = DnsRecord.find(params[:id])
    @record.auto_cast
    @record.extend ZeDnsRecord #Magic !
    @record.host = params[:dns_record][:host]
    @record.data = current_ip

    if @record.valid?
      hash = reverse_host_and_zone_from_ip current_ip
      ptr_record = ReverseDnsRecord.where( :rtype => 'PTR', :host => hash[:host], :zone => hash[:zone] ).first
      ptr_record.auto_cast
      ptr_record.data = "#{@record.host}.#{@record.zone}."
      ptr_record.save!

      @record.save

      ZeHelper.increment_serial
      flash[:success] = "Nom mis à jour"
      redirect_to ze_dns_a_record_path(@record)
    else
      @title = "Modifier le nom"
      render 'edit'
    end
  end

  def destroy
    @record = DnsRecord.find(params[:id])
    hash = reverse_host_and_zone_from_ip current_ip
    ptr_record = ReverseDnsRecord.where( :rtype => 'PTR', :host => hash[:host], :zone => hash[:zone] ).first

    @record.destroy
    ptr_record.destroy

    ZeHelper.increment_serial
    flash[:success] = "Nom mis à jour"
    redirect_to dns_records_path
  end

  private

    #Override: we only want A records in the good zone
    def set_conditions_and_title
      @conditions = ["zone = '#{ZeHelper.zone}' and rtype = 'A'"]
      @title = "Tous les enregistrements de type A"
    end

    #Override: we only want to do manipulate A records
    #and zone must be fine too
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'A'
        flash[:error] = "Le champ demandé n'est pas de type A"
        redirect_to ze_dns_a_records_path
      end
      if @record.zone != ZeHelper.zone
        flash[:error] = "Le champ demandé n'est pas dans la zone '#{ZeHelper.zone}'"
        redirect_to ze_dns_a_records_path
      end
    end

    def correct_user
      ip = DnsRecord.find(params[:id]).data
      redirect_to(root_path) unless ip == current_ip
    end

end
