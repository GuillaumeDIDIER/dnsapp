# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Methods to help for zone-specific records

#Include modules that will help you find zones
require 'record_extensions/ZeModules.rb'

module ZonesHelper

  #Find zone from ip
  def find_zone(ip)
    return ZeHelper.zone if ZeHelper.check_ip? ip

    return ""
  end

  def reverse_host_and_zone_from_ip(ip)
    ip_tab = []
    ip.each('.') { |sub| ip_tab.insert(-1, sub.to_i) }
    rev_zone = "#{ip_tab[2]}.#{ip_tab[1]}.#{ip_tab[0]}.in-addr.arpa"

    return { :host => "#{ip_tab[3]}", :zone => rev_zone }
  end

  #Zone-specific routes to record
  def zone_dns_path_to(dns_record)
    if dns_record.rtype == 'A' and dns_record.zone == ZeHelper.zone
      return ze_dns_a_record_path(dns_record)
    end

    return root_path
  end

  def edit_zone_dns_path_to(dns_record)
    if dns_record.rtype == 'A' and dns_record.zone == ZeHelper.zone
      return edit_ze_dns_a_record_path(dns_record)
    end

    return root_path
  end

  def new_zone_dns_path_to(zone)
    if zone == ZeHelper.zone
      return new_ze_dns_a_record_path
    end

    return root_path
  end

end
