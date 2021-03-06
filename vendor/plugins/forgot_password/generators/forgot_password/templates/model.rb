require 'digest/sha1'

class <%= class_name %> < ActiveRecord::Base
  belongs_to :<%= user_model_name %>
  attr_accessor :email
  validates_presence_of :email
  validates_format_of :email, :unless => Proc.new{|p|p.email.blank?}, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'is not a valid email address'
  validates_presence_of :<%= user_model_name %>, :unless => Proc.new{|p|p.errors.on(:email)}, :message => 'doesn\'t exist in the system.'
  validates_associated :<%= user_model_name %>

  protected
  def before_create
    self.reset_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join )
    self.expiration_date = 2.weeks.from_now
  end
end