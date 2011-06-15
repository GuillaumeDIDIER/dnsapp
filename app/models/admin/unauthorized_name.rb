class Admin::UnauthorizedName < ActiveRecord::Base

  attr_accessible :name, :comment

  validates :name, :presence => true,
                   :uniqueness => true

end
