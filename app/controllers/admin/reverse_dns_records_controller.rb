# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Full manual control over Reverse DNS Records for admin users

class Admin::ReverseDnsRecordsController < ReverseDnsRecordsController

  before_filter :admin_user

  def create
    @record = ReverseDnsRecord.new_record(params[:reverse_dns_record])

    if @record.save
      flash[:success] = "Enregistrement Reverse DNS créé"
      redirect_to admin_reverse_dns_record_path(@record)
    else
      @title = "Nouvel enregistrement Reverse DNS"
      render 'new'
    end
  end

  def update
    @record = ReverseDnsRecord.find(params[:id])

    #We need to do it manually
    @record.host  = params[:reverse_dns_record][:host]
    @record.zone  = params[:reverse_dns_record][:zone]
    @record.rtype = params[:reverse_dns_record][:rtype]
    @record.data  = params[:reverse_dns_record][:data]
    @record.auto_cast
    @record.retrieve_attributes if @record.rtype == 'SOA'
    
    if @record.save
      flash[:success] = "Enregistrement Reverse DNS mis à jour."
      redirect_to admin_reverse_dns_record_path(@record)
    else
      @title = "Modifier #{@record.host}.#{@record.zone}"
      render 'edit'
    end
  end

  def destroy
    @record = ReverseDnsRecord.find(params[:id])

    @record.destroy
    flash[:success] = "Enregistrement Reverse DNS supprimé"
    redirect_to admin_reverse_dns_records_path
  end

  private

    def admin_user
      if  privileges[:admin] != true
        flash[:error] = "Il faut être administrateur total pour accéder à cette ressource"
        redirect_to(root_path)
      end
    end

end
