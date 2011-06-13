# encoding: utf-8
include RegexHelper
class Admin::DomainNamesController < DomainNamesController

  before_filter :has_dns_privileges

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

  private

    def has_dns_privileges
      deny_access unless has_privileges? 
      if privileges[:dns].nil? || privileges[:dns] == 0
        flash[:error] = "Tu n'as pas les droits sur cette ressource"
        redirect_to root_path
      end
    end

end
