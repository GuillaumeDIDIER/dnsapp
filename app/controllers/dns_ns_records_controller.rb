# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all type NS DNS Records.

class DnsNsRecordsController < DnsRecordsController

  private

    #Override: we only want NS records
    def set_conditions_and_title
      @conditions = ["rtype = 'NS'"]
      @title = "Tous les enregistrements de type NS"
    end

    #Override: we only want to do manipulate NS records
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'NS'
        flash[:error] = "Le champ demandé n'est pas de type NS"
        redirect_to dns_ns_records_path
      end
    end

end
