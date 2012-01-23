# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all type PTR Reverse DNS Records.

class ReverseDnsPtrRecordsController < ReverseDnsRecordsController

  private

    #Override: we only want SOA records
    def set_conditions_and_title
      @conditions = ["rtype = 'PTR'"]
      @title = "Tous les enregistrements de type SOA"
    end

    #Override: we only want to do manipulate SOA records
    def check_record
      @record = ReverseDnsRecord.find(params[:id])
      if @record.rtype != 'PTR'
        flash[:error] = "Le champ demandé n'est pas de type PTR"
        redirect_to reverse_dns_ptr_records_path
      end
    end

end
