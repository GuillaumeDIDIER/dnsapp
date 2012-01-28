# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all type CNAME DNS Records.

class DnsCnameRecordsController < DnsRecordsController

  private

    #Override: we only want CNAME records
    def set_conditions_and_title
      @conditions = ["rtype = 'CNAME'"]
      @title = "Tous les enregistrements de type CNAME"
    end

    #Override: we only want to do manipulate CNAME records
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'CNAME'
        flash[:error] = "Le champ demandé n'est pas de type CNAME"
        redirect_to dns_cname_records_path
      end
    end

end
