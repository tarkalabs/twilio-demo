require 'twilio-ruby'

class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:outboundcall, :suspendaccount]
  skip_before_filter :verify_authenticity_token, only: [:outboundcall, :suspendaccount]

  def call
    # account_sid = ENV['TWILIO_SID']
    # auth_token = ENV['TWILIO_TOKEN']
    # capability = Twilio::Util::Capability.new account_sid, auth_token
    # capability.allow_client_outgoing ENV['TWILIO_CALL_APP_SID']
    capability = Twilio::Util::Capability.new tsid, tauthtoken
    capability.allow_client_outgoing 'APc6169bac90c0012486b2cb07ed08e634' #tappsid
    @twilio_token = capability.generate # 5 seconds, reference: https://www.twilio.com/docs/client/capability-tokens#token-expiration
  end

  #This is callback service. Twilio calls this when the end-user makes a call from Twilio Web Client
  def outboundcall
    unless genuine_twilio_request?
      head :forbidden
      # render plain: ["Twilio Request Validation Failed."], status: :forbidden
      return
    end

    # response_to_twilio_callback = TwilioCallTwiMLGeneratorService.new(params[:FromPhoneNumber], params[:ToPhoneNumber]).process
    # TODO: Check if the FromPhoneNumber is a verified Twilio PhoneNumber
    # TODO: How do we ensure that one end-user doesn't abuse other's users phone number??
    response_to_twilio_callback = generateTwiml(params[:FromPhoneNumber], params[:ToPhoneNumber])
    p response_to_twilio_callback
    render xml: response_to_twilio_callback
  end

  def suspendaccount
    unless genuine_twilio_request?
      head :forbidden and return
    end

    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_TOKEN']
    subaccount_sid = params["AccountSid"]

    client = Twilio::REST::Client.new account_sid, auth_token
    subaccount = client.accounts.get(sid)
    subaccount.update(:status => "suspended")
    # subaccount.status

    # Since Rails 4, head is now preferred over render :nothing
    # render nothing: true, status: :ok, content_type: "text/html"
    head :ok #, content_type: "text/html"
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

  private
  def tsid
    current_user.tsid
  end

  def tauthtoken
    current_user.tauthtoken
  end

  def tappsid
    current_user.tappsid
  end

  def genuine_twilio_request?
    params = call_params

    # Ref: https://twilio-ruby.readthedocs.org/en/latest/usage/validation.html
    tsid = params['AccountSid']
    user = User.find_by_tsid(tsid)
    validator = Twilio::Util::RequestValidator.new user.tauthtoken
    # the callback URL you provided to Twilio
    url = request.original_url #"http://www.example.com/my/callback/url.xml"
    # the POST variables attached to the request (eg "From", "To")
    post_vars = request.post? ? request.POST : {}
    # X-Twilio-Signature header value #Ref: http://stackoverflow.com/questions/19972313/accessing-custom-header-variables-in-ruby-on-rails
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE'] || '' #"HpS7PBa1Agvt4OtO+wZp75IuQa0=" # will look something like that
    puts "url=#{url}\n post_vars=#{post_vars}\n signature=#{signature}"

    validator.validate(url, post_vars, signature)
  end
end
