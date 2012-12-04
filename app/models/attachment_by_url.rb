class AttachmentByUrl < ActiveRecord::Base
  unloadable

  QUEUED = "queued"
  IN_PROGRESS = "in_progress"
  CANCELED = "canceled"
  COMPLETED = "completed"
  FAILED = "failed"

  STATES = [QUEUED, IN_PROGRESS, CANCELED, COMPLETED, FAILED]

  belongs_to :author, :class_name => "User"

  validates_presence_of :url, :state, :author
  validates_inclusion_of :state, :in => STATES
  validate :validate_url_scheme, :validate_url_safety

  def validate_url_scheme
    uri = URI.parse(url)

    # allow only http and https
    raise "error" unless /^https?$/ =~ uri.scheme
  rescue
    errors.add(:url, I18n.t(:message_invalid_url))
  end

  def validate_url_safety
    uri = URI.parse(url)

    # deny localhost
    raise "deny localhost" if /^localhost?$/ =~ uri.host

    # deny private networks
    if Regexp.new(uri.parser.pattern[:IPV4ADDR]) =~ uri.host
      private_re = /(^0\.0\.0\.0)|(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
      raise "deny private networks" if private_re =~ uri.host
    end
  rescue URI::InvalidURIError
    errors.add(:url, I18n.t(:message_invalid_url))
  rescue
    errors.add(:url, I18n.t(:message_url_is_not_safe))
  end
end
