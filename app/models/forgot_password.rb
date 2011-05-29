require 'digest/sha1'

class ForgotPassword < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  belongs_to :user
  attr_accessor :email
  validates_presence_of :email
#  validates_format_of :email, :unless => Proc.new{|p|p.email.blank?}, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'is not a valid email address'
  validates_presence_of :user, :unless => Proc.new{|p|p.errors.on(:email)}, :message => 'doesn\'t exist in the system.'
  validates_associated :user

  protected
  def before_create
    aplog.debug("START #{CLASS_NAME}#before_create")
    self.reset_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join )
    self.expiration_date = 2.weeks.from_now
    aplog.debug("END   #{CLASS_NAME}#before_create")
  end
end