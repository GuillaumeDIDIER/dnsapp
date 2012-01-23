class Admin::UnauthorizedName < ActiveRecord::Base

  attr_accessible :name, :comment

  validates :name, :presence => true,
                   :uniqueness => true

  def regex
    @regex ||= get_regex
  end

  private

    def get_regex
      begin
        r = eval self.name
        return r if r.class == Regexp
      rescue Exception
      end

      return nil
    end

end
