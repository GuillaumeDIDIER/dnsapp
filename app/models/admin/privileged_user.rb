class Admin::PrivilegedUser < ActiveRecord::Base

  attr_accessor :password, :save_password
  attr_accessible :name, :password, :password_confirmation

  validates :name, :presence => true,
                   :length => { :maximum => 50 },
		   :uniqueness => true
  validates :password, :presence => true,
                       :confirmation => true,
		       :length => { :within => 6..40 }

  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(name, submitted_password)
    privileged_user = find_by_name(name)
    return nil if privileged_user.nil?
    return privileged_user if privileged_user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, submitted_salt)
    privileged_user = find_by_id(id)
    (privileged_user && privileged_user.salt == submitted_salt) ? privileged_user : nil
  end

  def self.privileges_list
    [:admin, :dns, :alias, :unauthorized_names]
  end

  def privileges
    privileges = {}
    Admin::PrivilegedUser.privileges_list.each do |p|
      privileges[p] = self[p]
    end
    privileges
  end

  def dont_save_password
    self.save_password = false
  end

  def do_save_password
    self.save_password = nil
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password) unless save_password == false
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

end
