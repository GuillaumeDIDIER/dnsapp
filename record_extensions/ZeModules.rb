# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Modules that will be used to define the "eleves.polytechnique.fr" DNS zone.
#Note: 'Ze' is to be understood as 'Zone élèves'

#Static usefull methods
module ZeHelper

  def self.zone
    "eleves.polytechnique.fr"
  end

  #To check if ipv4 address is in this zone
  def self.check_ip?(ip)
    ip_tab = []
    ip.each('.') { |sub| ip_tab.insert(-1, sub.to_i) }
    valid = true
    valid = false unless ip_tab.count == 4
    rev_ip = "#{ip_tab[2]}.#{ip_tab[1]}.#{ip_tab[0]}.in-addr.arpa"
    valid = false unless self.is_in_zone? rev_ip
    valid = false unless (0..255).member? ip_tab[3]

    return valid
  end

  #Reverse Zone Check
  def self.is_in_zone?(rev_ip_domain)
    self.ip_zones.each do |zone|
      return true if rev_ip_domain == zone
    end

    return false
  end

  #Increment serial of soa records for this zone only
  def self.increment_serial
    soas = DnsRecord.where :rtype => 'SOA'
    soas.each do |soa|
      soa.auto_cast #Yay ultimate magic !
      soa.increment_serial if soa.zone == ZeHelper.zone
      soa.save
    end

    soas = ReverseDnsRecord.where :rtype => 'SOA'
    soas.each do |soa|
      soa.auto_cast #Yay some more magic !
      soa.increment_serial if ZeHelper.is_in_zone? soa.zone
      soa.save
    end
  end

  private

     def self.ip_zones
       #Bataclan
      ["201.104.129.in-addr.arpa",
       #BEM
       "203.104.129.in-addr.arpa",
       "204.104.129.in-addr.arpa",
       "205.104.129.in-addr.arpa",
       #Foch
       "212.104.129.in-addr.arpa",
       "213.104.129.in-addr.arpa",
       "214.104.129.in-addr.arpa",
       "215.104.129.in-addr.arpa",
       #Joffre
       "216.104.129.in-addr.arpa",
       "217.104.129.in-addr.arpa",
       "218.104.129.in-addr.arpa",
       "219.104.129.in-addr.arpa",
       #Maunoury
       "220.104.129.in-addr.arpa",
       "221.104.129.in-addr.arpa",
       "222.104.129.in-addr.arpa",
       "223.104.129.in-addr.arpa",
       #70 & 71
       "224.104.129.in-addr.arpa",
       #73 & 74
       "225.104.129.in-addr.arpa",
       #75 & 80
       "226.104.129.in-addr.arpa",
       #76 & 77
       "227.104.129.in-addr.arpa",
       #78 & 72
       "228.104.129.in-addr.arpa",
       #79
       "229.104.129.in-addr.arpa",
       #Fayolle
       "232.104.129.in-addr.arpa",
       "233.104.129.in-addr.arpa",
       "234.104.129.in-addr.arpa",
       "235.104.129.in-addr.arpa"]
    end

end

#DNS Records in this zone have zone fixed to "eleves.polytechnique.fr"
module ZeDnsRecord

  def self.extended(base)
    base.zone = ZeDnsRecord.zone

    #Forbid further modification on this field
    def base.zone=(zone)
    end
  end

  #Static access to this
  def self.zone
    ZeHelper.zone
  end

end

