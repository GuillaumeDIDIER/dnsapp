# encoding: utf-8
include RegexHelper
class DomainNamesController < ApplicationController
  before_filter :correct_user, :only => [:edit, :update, :destroy]

  def index
    #On obtient le format de la requête
    format = request.format.symbol
    #system "perl reload_named.pl"
    #system "perl reload_named.pl"
    @title = "Toutes les DNS"
    @domain_names = DomainName.all
    #On ne renvoie que le début si la
    #vue est en html
    @domain_names = DomainName.paginate :page => params[:page] if format == :html
  end

  def show
    @domain_name = DomainName.find(params[:id])
    @title = "Profil : #{@domain_name.name.match(short_name_from_name_regex)}"
  end

  def new
    @domain_name = DomainName.new
    @title = "Donner un nom à #{current_ip}"
  end

  def create
    @domain_name = DomainName.new_dns params[:domain_name][:short_name], verify_ip(current_ip)
    double = DomainName.where :rdata => @domain_name.rdata
    if double.count > 0
      flash[:error] = "Ton ip est déjà associée à un nom"
      @domain_name = double.first
      redirect_to @domain_name and return
    end
    if @domain_name.valid?
      save_dns_and_rdns @domain_name
      increment_serial
      add_xnet_client @domain_name.short_name, current_ip
      flash[:success] = "Nom enregistré"
      redirect_to @domain_name
    else
      @title = "Donner un nom à #{current_ip}"
      render 'new'
    end
  end

  def edit
    @domain_name = DomainName.find(params[:id])
    @title = "Modifier le nom"
  end

  def update
    @domain_name = DomainName.find(params[:id])
    last_name = @domain_name.name
    last_short_name = last_name.match(short_name_from_name_regex)[0]
    @domain_name.short_name = params[:domain_name][:short_name]
    update_attr @domain_name
    if last_short_name == @domain_name.short_name
      flash.now[:error] = "Tu as rentré le même nom"
      @title = "Modifier le nom"
      render 'edit' and return
    end
    if @domain_name.valid?
      update_dns_and_rdns @domain_name, last_name
      increment_serial
      add_xnet_client @domain_name.short_name, current_ip
      delete_xnet_client last_short_name
      flash[:success] = "Nom mis à jour"
      redirect_to @domain_name
    else
      @title = "Modifier le nom"
      render 'edit'
    end
  end

  def destroy
    @domain_name = DomainName.find(params[:id])
    short_name = @domain_name.get_short_name.to_s
    delete_dns_and_rdns @domain_name
    increment_serial
    delete_xnet_client short_name
    flash[:success] = "Nom supprimé"
    redirect_to root_path
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

    def correct_user
      ip = DomainName.find(params[:id]).rdata
      redirect_to(root_path) unless ip == current_ip
    end

end
