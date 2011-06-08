# encoding: utf-8
class ReverseDomainNamesController < ApplicationController

  def index
    @title = "Liste des reverse DNS"
    @reverse_domain_names = ReverseDomainName.all
  end

  def show
    @reverse_domain_name = ReverseDomainName.find(params[:id])
    @title = @reverse_domain_name.name
  end

end
