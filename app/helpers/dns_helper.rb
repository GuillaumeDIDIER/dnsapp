# encoding: utf-8
module DnsHelper

  def get_dns_from_ip(ip) 
    dns = DomainName.where :rdata => ip, :rdtype => "A"
    dns.first
  end

  def current_dns
    get_dns_from_ip current_ip
  end

  def trunc(string, num)
    if string.length > num
      string[0..(num-4)] + "..."
    else
      string
    end
  end

  def searching_for(params, initial_condition = "")
    ip_like = params[:ip] if params[:ip] != ""
    name_like = params[:name] if params[:name] != ""
    title = ""
    condition = [initial_condition]
    condition = ["#{initial_condition} and "] unless initial_condition == ""

    if !ip_like.nil?
      title = "Résultats pour ip ~ #{params[:ip]}"
      ip_like = "%#{ip_like}%"
    end
    if !name_like.nil?
      title += " et nom ~ #{params[:name]}"
      title = "Résultats pour nom ~ #{params[:name]}" if ip_like.nil?
      name_like = "%#{name_like}%"
    end

    if !ip_like.nil? && !name_like.nil?
      condition = [ "#{condition[0]}name like ? and rdata like ?", name_like, ip_like ]
    elsif !ip_like.nil?
      condition = [ "#{condition[0]}rdata like ?", ip_like ]
    elsif !name_like.nil?
      condition = [ "#{condition[0]}(name like ? or rdata like ?)", name_like, name_like ]
    else
      condition = [initial_condition]
    end

    title = nil if title == ""

    { :title => title, :conditions => condition }
  end

end
