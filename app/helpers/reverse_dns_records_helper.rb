# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods to find routes (non zone specific)

module ReverseDnsRecordsHelper

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
