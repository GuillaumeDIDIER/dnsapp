# encoding: utf-8
class DnsController < ApplicationController
  
  def index
    @title = "All Dns"
    @dns = Dns.all
  end

  def show
    @dns = Dns.find(params[:id])
    @title = @dns.name
  end

end
