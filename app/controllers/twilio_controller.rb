require 'twilio-ruby'

class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'Hey there. Congrats on integrating Twilio into your Rails 4 app.', :voice => 'alice'
         r.Play 'http://linode.rabasa.com/cantina.mp3'
  	end

  	render_twiml response
  end

  def inbound
    render text: '<Response><Message>Touchdown, Bo Jackson!</Message></Response>'
  end

  def notify
    client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
    message = client.account.messages.create(
                from: ENV['TWILIO_PHONE_NUMBER'],
                to: ENV['TWILIO_VERIFIED_PHONE_NUMBER'],
                body: 'Learning to send SMS you are.')
    render plain: message.status
  end
end
