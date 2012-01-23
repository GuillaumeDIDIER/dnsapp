# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Usefull methods to handle users.

module UsersHelper

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= define_user
  end

  def current_user?(user)
    user == current_user
  end

  def current_ip
    current_user[:ip]
  end

  def current_zone
    current_user[:zone]
  end

  def current_domain_name
    get_domain_name_from_ip current_ip
  end

  private

    def define_user
      ip = request.remote_ip
      zone = find_zone ip

      return { :ip => ip, :zone => zone }
    end

    def get_domain_name_from_ip(ip)
      records = DnsRecord.where :rtype => "A", :data => ip
      records.first
    end

end
