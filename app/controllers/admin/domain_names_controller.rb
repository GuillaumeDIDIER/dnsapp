# encoding: utf-8
include RegexHelper
# On hérite pour avoir les même méthodes privées
# Il doit aussi il y avoir un moyen de rendre ça
# plus DRY (don't repeat yourself)
class Admin::DomainNamesController < DomainNamesController

  skip_before_filter :correct_user
  before_filter :has_dns_privileges
  before_filter :is_dns, :only => [:show, :edit, :update, :destroy]

  def index
    @title = "Toutes les DNS de type A"
    
    #Si on cherche quelquechose en particulier
    hash = searching_for(params, "rdtype = 'A'")
    @title = hash[:title] unless hash[:title].nil?
    @domain_names = DomainName.find(:all, :conditions => hash[:conditions])

    #On ne renvoie que la page concernée si la
    #vue est en html
    @domain_names = @domain_names.paginate :page => params[:page]
  end

  def new
    @domain_name = DomainName.new
    @title = "Créer une nouvelle entrée DNS"
  end

  def create
    @domain_name = DomainName.new_dns params[:domain_name][:short_name], verify_ip(params[:domain_name][:rdata])
    double = DomainName.where :rdata => @domain_name.rdata
    if double.count > 0
      flash[:error] = "Cette ip est déjà associée à un nom"
      @domain_name = double.first
      redirect_to admin_domain_name_path(@domain_name) and return
    end
    if @domain_name.valid?
      save_dns_and_rdns @domain_name
      increment_serial
      add_xnet_client @domain_name.short_name, @domain_name.rdata
      flash[:success] = "Nom enregistré"
      redirect_to admin_domain_name_path(@domain_name)
    else
      @title = "Créer une nouvelle entrée DNS"
      render 'new'
    end
  end

  def edit
    @domain_name = DomainName.find(params[:id])
    @title = "Modifier #{@domain_name.name}"
  end

  def update
    @domain_name = DomainName.find(params[:id])
    last_name = @domain_name.name
    last_short_name = last_name.match(short_name_from_name_regex)[0]
    @domain_name.short_name = params[:domain_name][:short_name]
    @domain_name.get_name_from_short_name
    @domain_name.rdata = verify_ip params[:domain_name][:rdata]
    if @domain_name.valid?
      update_dns_and_rdns @domain_name, last_name
      increment_serial
      if last_short_name == @domain_name.short_name
        update_ip_xnet_client(@domain_name.short_name, @domain_name.rdata)
      else
        delete_xnet_client last_short_name
        add_xnet_client @domain_name.short_name, @domain_name.rdata
      end
      flash[:success] = "Nom mis à jour"
      redirect_to admin_domain_name_path(@domain_name)
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
    redirect_to admin_domain_names_path
  end

  private

    def has_dns_privileges
      deny_access unless has_privileges? 
      if privileges[:dns].nil? || privileges[:dns] == 0
        flash[:error] = "Tu n'as pas les droits sur cette ressource"
        redirect_to root_path
      end
    end

    def is_dns
      redirect_to admin_domain_names_path unless DomainName.find(params[:id]).rdtype == "A"
    end

end
