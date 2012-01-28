# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods related to DNS Records and Reverse DNS Records
#Non zone-specific

module DnsRecordsHelper

  def translate_field(field_name)
    return "Le nom" if field_name.to_s == "host"
    return "La zone" if field_name.to_s == "zone"
    return "Le type" if field_name.to_s == "rtype"
    return "La cible" if field_name.to_s == "data"

    return field_name
  end

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

  #Find a non zone-specific route to record
  def reverse_dns_path_to(dns_record)
    if dns_record.rtype == 'SOA'
      return reverse_dns_soa_record_path(dns_record)
    elsif dns_record.rtype == 'NS'
      return reverse_dns_ns_record_path(dns_record)
    elsif dns_record.rtype == 'PTR'
      return reverse_dns_ptr_record_path(dns_record)
    end

    #Default can't do anything better
    return root_path
  end

end
