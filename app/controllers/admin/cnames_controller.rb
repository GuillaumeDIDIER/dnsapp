# encoding: utf-8
# On hérite pour avoir les même méthodes privées
# Il doit aussi il y avoir un moyen de rendre ça
# plus DRY (don't repeat yourself)
class Admin::CnamesController < DomainNamesController

  skip_before_filter :correct_user
  before_filter :has_alias_privileges
  before_filter :is_alias, :only => [:show, :edit, :update, :destroy]

  def index
    @title = "Toutes les DNS de type Cname"

    #Si on cherche quelquechose en particulier
    hash = searching_for(params, "rdtype = 'Cname'")
    @title = hash[:title] unless hash[:title].nil?
    @cnames = DomainName.find(:all, :conditions => hash[:conditions])

    #On ne renvoie que la page concernée si la
    #vue est en html
    @cnames = @cnames.paginate :page => params[:page]
  end

  def show
    @cname = DomainName.find(params[:id])
    @title = "Profil : #{@cname.get_short_name}"
  end

  def new
    @cname = DomainName.new
    @title = "Créer un nouvel alias"
  end

  def create
    @cname = DomainName.new_alias params[:domain_name][:short_name], params[:domain_name][:short_dest]
    if @cname.nil?
      flash.now[:error] = "La destination n'existe pas"
      @cname = DomainName.new
      @cname.short_name = params[:domain_name][:short_name]
      @cname.short_dest = params[:domain_name][:short_dest]
      @title = "Créer un nouvel alias"
      render 'new' and return
    end
    if @cname.valid?
      @cname.save
      increment_serial
      dest = DomainName.find_by_name @cname.rdata.chop
      add_xnet_client @cname.short_name, dest.rdata
      flash[:success] = "Alias enregistré"
      redirect_to admin_cname_path(@cname)
    else
      @title = "Créer un nouvel alias"
      render 'new'
    end
  end

  def edit
    @cname = DomainName.find(params[:id])
    @title = "Modifier #{@cname.name}"
  end

  def update
    @cname = DomainName.find(params[:id])
    last_name = @cname.name
    last_short_name = last_name.match(DomainName.short_name_from_name_regex)[0]
    @cname.short_name = params[:domain_name][:short_name]
    @cname.get_name_from_short_name
    @cname.short_dest = params[:domain_name][:short_dest]
    @cname.update_dest
    if @cname.rdata.nil?
      flash.now[:error] = "La destination n'existe pas"
      @cname = DomainName.find(params[:id])
      @cname.short_name = params[:domain_name][:short_name]
      @cname.short_dest = params[:domain_name][:short_dest]
      @title = "Modifier #{@cname.name}"
      render 'edit' and return
    end
    if @cname.valid?
      @cname.save
      increment_serial
      update_username_xnet_client last_short_name, @cname.short_name
      dest = DomainName.find_by_name @cname.rdata.chop
      update_ip_xnet_client @cname.short_name, dest.rdata
      flash[:success] = "Alias mis à jour"
      redirect_to admin_cname_path(@cname)
    else
      @title = "Modifier #{@cname.name}"
      render 'edit'
    end
  end

  def destroy
    @cname = DomainName.find(params[:id])
    short_name = @cname.get_short_name.to_s
    @cname.destroy
    increment_serial
    delete_xnet_client short_name
    flash[:success] = "Alias supprimé"
    redirect_to admin_cnames_path
  end

  private
  
    def has_alias_privileges
      deny_access unless has_privileges?
      if privileges[:alias].nil? || privileges[:alias] == 0
        flash[:error] = "Tu n'as pas les droits sur cette ressource"
        redirect_to root_path
      end
    end

    def is_alias
      redirect_to admin_cnames_path unless DomainName.find(params[:id]).rdtype.downcase == "cname"
    end

end
