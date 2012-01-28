class Admin::Zone < ActiveRecord::Base

  attr_accessible :zone, :name

  validates :zone, :presence => true,
                   :uniqueness => true

end
