module DnsHelper

  def get_dns_from_ip(ip) 
    dns = DomainName.where :rdata => ip, :rdtype => "A"
    dns.first
  end

  def current_dns
    get_dns_from_ip current_ip
  end

end
