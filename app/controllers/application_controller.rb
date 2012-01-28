# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Modules that we can use in controllers in all application

class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include PrivilegedUsersHelper
  include SearchHelper
  include ZonesHelper
end
