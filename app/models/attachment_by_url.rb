require 'uri'

class AttachmentByUrl < ActiveRecord::Base
  QUEUED      = 'queued'
  IN_PROGRESS = 'in_progress'
  CANCELED    = 'canceled'
  COMPLETED   = 'completed'
  FAILED      = 'failed'

  STATES = [QUEUED, IN_PROGRESS, CANCELED, COMPLETED, FAILED]

  belongs_to :author, class_name: 'User'
  belongs_to :attachment

  validates_presence_of :url, :state, :author
  validates_inclusion_of :state, in: STATES
  validate :validate_url_scheme, :validate_url_safety

  def validate_url_scheme
    uri = URI.parse(url)

    # allow only http and https
    raise 'error' unless /^https?$/ =~ uri.scheme
  rescue
    self.state = FAILED
    errors.add(:url, I18n.t(:message_invalid_url))
  end

  def validate_url_safety
    uri = URI.parse(url)

    raise 'host must be present' unless uri.host

    # deny private networks
    private_re = /(^0\.0\.0\.0)|(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
    raise 'deny private networks' if private_re =~ uri.host
  rescue
    self.state = FAILED
    errors.add :url, I18n.t(:message_invalid_url)
  end
end
