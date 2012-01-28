# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Full manual control over DNS Records for admin users

class Admin::DnsRecordsController < DnsRecordsController

  before_filter :admin_user

  def create
    @record = DnsRecord.new_record(params[:dns_record])

    if @record.save
      flash[:success] = "Enregistrement DNS créé"
      redirect_to admin_dns_record_path(@record)
    else
      @title = "Nouvel enregistrement DNS"
      render 'new'
    end
  end

  def update
    @record = DnsRecord.find(params[:id])

    #We need to do it manually
    @record.host  = params[:dns_record][:host]
    @record.zone  = params[:dns_record][:zone]
    @record.rtype = params[:dns_record][:rtype]
    @record.data  = params[:dns_record][:data]
    @record.auto_cast
    @record.retrieve_attributes if @record.rtype == 'SOA' or @record.rtype == 'MX'
    
    if @record.save
      flash[:success] = "Enregistrement DNS mis à jour."
      redirect_to admin_dns_record_path(@record)
    else
      @title = "Modifier #{@record.host}.#{@record.zone}"
      render 'edit'
    end
  end

  def destroy
    @record = DnsRecord.find(params[:id])

    @record.destroy
    flash[:success] = "Enregistrement DNS supprimé"
    redirect_to admin_dns_records_path
  end

  private

    def admin_user
      if  privileges[:admin] != true
        flash[:error] = "Il faut être administrateur total pour accéder à cette ressource"
        redirect_to(root_path)
      end
    end

end
