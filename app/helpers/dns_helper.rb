module DnsHelper

  def get_dns_from_ip(ip) 
    dns = Dns.where :rdata => ip, :rdtype => "A"
    dns.first
    #Dns.find 42
  end

  def current_dns
    get_dns_from_ip current_ip
  end

end
