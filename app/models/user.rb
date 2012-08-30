class User
  include Mongoid::Document

  attr_protected :roles

  before_validation :generate_uri

  # ***************
  # Devise configuration:

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
        #  :recoverable,
          :rememberable,
        #  :trackable,
          :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password

  ## Recoverable
  #field :reset_password_token,   :type => String
  #field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  #field :sign_in_count,      :type => Integer, :default => 0
  #field :current_sign_in_at, :type => Time
  #field :last_sign_in_at,    :type => Time
  #field :current_sign_in_ip, :type => String
  #field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  # *********************
  # fields defined by us:

  field :screen_name, type: String
  validates_presence_of :screen_name

  field :uri, type: String
  validates_presence_of :uri

  field :roles_mask, type: Integer # this will contain a bitwise mask of the users roles.

  # *********************
  # Roles stuff

  # don't change the order of this: just add to the end (or it will screw up the existing bitmasks!)
  ROLES = %w[super_user]

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def add_role(role)
    self.roles = (self.roles + [role.to_s])
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    roles.include? role.to_s
  end

  protected

  def generate_uri
    self.uri = "http://#{PublishMyData.local_domain}/id/users/#{self.screen_name}" if self.new_record? #only do on new ones.
  end
end
