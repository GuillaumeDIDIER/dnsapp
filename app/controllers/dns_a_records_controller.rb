# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all type A DNS Records.

class DnsARecordsController < DnsRecordsController

  private

    #Override: we only want A records
    def set_conditions_and_title
      @conditions = ["rtype = 'A'"]
      @title = "Tous les enregistrements de type A"
    end

    #Override: we only want to do manipulate A records
    def check_record
      @record = DnsRecord.find(params[:id])
      if @record.rtype != 'A'
        flash[:error] = "Le champ demandé n'est pas de type A"
        redirect_to dns_a_records_path
      end
    end

end
