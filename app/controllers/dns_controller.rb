class DnsController < ApplicationController
  
  def index
    @dns = Dns.all
  end

end
