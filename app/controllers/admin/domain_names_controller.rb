# encoding: utf-8
include RegexHelper
class Admin::DomainNamesController < ApplicationController

  before_filter :has_dns_privileges

  def index
    @title = "Toutes les DNS"
    @domain_names = DomainName.paginate :page => params[:page]
  end

  private

    def save_dns_and_rdns(domain_name)
      reverse_domain_name = ReverseDomainName.new_rdns domain_name.name, domain_name.rdata
      domain_name.save
      reverse_domain_name.save
    end

    def update_attr(domain_name)
      same_domain_name = DomainName.new_dns domain_name.short_name, verify_ip(domain_name.rdata)
      domain_name.name = same_domain_name.name
      domain_name.rdata = same_domain_name.rdata
    end

    def update_dns_and_rdns(domain_name, last_name)
      name = "#{last_name}."
      reverse_domain_name = (ReverseDomainName.where :rdata => name).first
      same_reverse_domain_name = ReverseDomainName.new_rdns domain_name.name, domain_name.rdata
      reverse_domain_name.name = same_reverse_domain_name.name
      reverse_domain_name.rdata = same_reverse_domain_name.rdata
      domain_name.save
      reverse_domain_name.save
    end

    def delete_dns_and_rdns(domain_name)
      name = "#{domain_name.name}."
      reverse_domain_name = (ReverseDomainName.where :rdata => name).first
      domain_name.destroy
      reverse_domain_name.destroy
    end

    def increment_serial
      dns = DomainName.where :rdtype => "SOA"
      soa_regex = /\A(.*) (\d+) (\d+) (\d+) (\d+) (\d+)\z/
      soa = dns.first.rdata.match(soa_regex)
      serial = soa[2].to_i + 1
      soa = "#{soa[1]} #{serial} #{soa[3]} #{soa[4]} #{soa[5]} #{soa[6]}"
      dns.each do |entry|
        entry.rdata = soa
	entry.save!
      end
      rdns = ReverseDomainName.where :rdtype => "SOA"
      rdns.each do |entry|
        entry.rdata = soa
        entry.save!
      end
    end

    def add_xnet_client(short_name, ip)
      client = Clients.new
      client.username = short_name
      client.lastip = ip
      client.status = 1
      client.save!
    end

    def delete_xnet_client(short_name)
      clients = Clients.where :username => short_name
      if clients.any?
        client = clients.first
        client.destroy
      end
    end

    def has_dns_privileges
      deny_access unless has_privileges? && privileges[:dns] && privileges[:dns] != 0
    end

end
