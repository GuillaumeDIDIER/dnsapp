class PagesController < ApplicationController
  
  def home
    @title = "Accueil"
  end

  def contact
    @title = "Contact"
  end

  def help
    @title = "Aide"
  end

  def about_ip
    if params[:ip].nil?
      path = url_for( :controller => 'pages',
                    :action => 'about_ip',
                    :ip => current_ip,
                    :only_path => true )
      redirect_to path and return
    end

    @ip = params[:ip]
    @zone = find_zone @ip
    @name = get_domain_name_from_ip @ip
    @title = "À propos de #{params[:ip]}"
  end

end
