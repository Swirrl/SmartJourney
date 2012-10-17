class User
  include Mongoid::Document

  attr_protected :roles, :roles_mask, :uri

  before_create :generate_uri
  after_create :create_rdf_user

  # ***************
  # Devise configuration:

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
        #  :trackable,
          :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

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
  validates :screen_name,
    :presence => true,
    :format => {:with => /\A[a-zA-Z0-9_\-]*\z/, :message => "can only contain letters, numbers, hyphens and underscores." },
    :length => { :in => 2..15 },
    :uniqueness => true

  validate :validate_zones

  field :uri, type: String
  index({ uri: 1 }, { unique: true })

  # receive emails for reports in zones I've selected.
  field :receive_zone_emails, type: Boolean, :default => false

  # receive emails for reports I've created
  field :receive_report_emails, type: Boolean, :default => false

  field :email_comments, type: Boolean, :default => false

  field :zone_uris, type: Array, :default => []

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

  # this isn't very efficient.
  def zones
    zone_uris.map{ |u| Zone.find(u) }
  end

  def zone_selected?(z)
    zones.include?(z.uri)
  end

  def in_zones?(zone)
    zone_uris.include?(zone.uri.to_s)
  end

  # all of this user's reports.
  def open_reports(limit=nil)
    query = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?report (<#{Report.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Report.graph_uri}> {
          ?report a <#{Report.rdf_type}> .

          # reported by me
          ?report <#{Report.creator_predicate.to_s}> <#{self.uri.to_s}> .

          ?report <#{Report.created_at_predicate.to_s}> ?created .
          ?report <#{Report.incident_predicate.to_s}> ?incident .
          ?incident <#{Incident.interval_predicate.to_s}> ?interval .

          ?interval <#{Interval.begins_at_predicate.to_s}> ?begins .
          OPTIONAL { ?interval <#{Interval.ends_at_predicate.to_s}> ?ends . }

          FILTER (
            # we don't care when it starts.

            # don't end or end in future.
            (
              (!bound( ?ends )) ||
              (?ends >= \"#{Time.now.iso8601()}\"^^xsd:dateTime)
            )
          ) .
        }
      }
      ORDER BY DESC(?created)"
    query += " LIMIT #{limit}" if limit

    Report.where(query, {uri_variable: 'report'})
  end

  protected

  def validate_zones

    begin
      #just call zones. this will error if one doesn't exist.
      zones
    rescue
      errors.add(:zones, 'contains an invalid entry')
    end

  end

  def generate_uri
    #only do on new ones and if the screen name is present.
    self.uri = "http://data.smartjourney.co.uk/id/user/#{self.screen_name}"
  end

  def create_rdf_user
    rdf_user = RdfUser.new(uri)
    rdf_user.label = self.screen_name
    rdf_user.save!
  end
end
