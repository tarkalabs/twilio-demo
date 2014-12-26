class HomeController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:outboundcall]

  def call
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_TOKEN']
    capability = Twilio::Util::Capability.new account_sid, auth_token
    capability.allow_client_outgoing ENV['TWILIO_CALL_APP_SID']
    @twilio_token = capability.generate # 5 seconds, reference: https://www.twilio.com/docs/client/capability-tokens#token-expiration
  end

  #This is callback service. Twilio calls this when the end-user makes a call from Twilio Web Client
  def outboundcall
    params = call_params
    # response_to_twilio_callback = TwilioCallTwiMLGeneratorService.new(params[:FromPhoneNumber], params[:ToPhoneNumber]).process
    # TODO: Check if the FromPhoneNumber is a verified Twilio PhoneNumber
    # TODO: How do we ensure that one end-user doesn't abuse other's users phone number??
    response_to_twilio_callback = generateTwiml(params[:FromPhoneNumber], params[:ToPhoneNumber])
    p response_to_twilio_callback
    render xml: response_to_twilio_callback
  end

  private
  def call_params
    params.permit!
  end

  # Example Response:
  # <?xml version="1.0" encoding="UTF-8"?>
  # <Response>
  # <Dial callerId="+15005550000">
  # <Number>+15005550001</Number>
  # </Dial>
  # </Response>
  def generateTwiml(from_phone_number, to_phone_number)
    Twilio::TwiML::Response.new do |r|
      r.Dial :callerId => from_phone_number do |d| # callerId is number from which call is made.
        d.Number(CGI::escapeHTML to_phone_number) # The number to call
      end
    end.text.strip
  end
end
