# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Model for zones that we are in charge of.

class Admin::Zone < ActiveRecord::Base

  attr_accessible :zone, :name

  validates :zone, :presence => true,
                   :uniqueness => true

end
