# encoding: utf-8
class ReverseDomainNamesController < ApplicationController

  def index
    @title = "Liste des reverse DNS"

    #Si on cherche quelquechose en particulier
    hash = searching_for(params)
    @title = hash[:title] unless hash[:title].nil?
    @reverse_domain_names = ReverseDomainName.find(:all, :conditions => hash[:conditions])

    #On ne renvoie que la page concernée si la
    #vue est en html
    @reverse_domain_names = @reverse_domain_names.paginate :page => params[:page]
  end

  def show
    @reverse_domain_name = ReverseDomainName.find(params[:id])
    @title = @reverse_domain_name.name
  end

end
