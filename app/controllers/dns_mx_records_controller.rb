# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all type MX DNS Records.

class DnsMxRecordsController < DnsRecordsController

  private

    #Override: we only want MX records
    def set_conditions_and_title
      @conditions = ["rtype = 'MX'"]
      @title = "Tous les enregistrements de type MX"
    end

    #Override: we only want to do manipulate SOA records
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'MX'
        flash[:error] = "Le champ demandé n'est pas de type MX"
        redirect_to dns_mx_records_path
      end
    end

end
