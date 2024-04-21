# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SENDER_ADDRESS', nil)
  layout 'mailer'
end
