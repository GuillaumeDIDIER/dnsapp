# encoding: utf-8
include RegexHelper
class DomainNamesController < ApplicationController
  before_filter :correct_user, :only => [:edit, :update]

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
	double = []
    if double.count > 0
      flash[:error] = "Ton ip est déjà associée à un nom"
      @domain_name = double.first
      redirect_to @domain_name and return
    end
    if @domain_name.valid?
      save_dns_and_rdns @domain_name
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
    name_regex = /\A[a-z](?:-?[a-z0-9])+/i
    last_short_name = last_name.match(name_regex)[0]
    @domain_name.short_name = params[:domain_name][:short_name]
    update_attr @domain_name
    if last_short_name == @domain_name.short_name
      flash.now[:error] = "Tu as rentré le même nom"
      @title = "Modifier le nom"
      render 'edit' and return
    end
    if @domain_name.valid?
      update_dns_and_rdns @domain_name, last_name
      flash[:success] = "Nom mis à jour"
      redirect_to @domain_name
    else
      @title = "Modifier le nom"
      render 'edit'
    end
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

    def correct_user
      ip = DomainName.find(params[:id]).rdata
      redirect_to(root_path) unless ip == current_ip
    end

end
