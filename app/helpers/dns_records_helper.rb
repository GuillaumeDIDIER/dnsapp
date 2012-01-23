# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods related to DNS Records and Reverse DNS Records
#Non zone-specific

module DnsRecordsHelper

  #Find a non zone-specific route to record
  def dns_path_to(dns_record)
    if dns_record.rtype == 'SOA'
      return dns_soa_record_path(dns_record)
    elsif dns_record.rtype == 'NS'
      return dns_ns_record_path(dns_record)
    elsif dns_record.rtype == 'MX'
      return dns_mx_record_path(dns_record)
    elsif dns_record.rtype == 'A'
      return dns_a_record_path(dns_record)
    elsif dns_record.rtype == 'CNAME'
      return dns_cname_record_path(dns_record)
    end

    #Default can't do anything better
    return root_path
  end

end
