require 'twilio-ruby'

class HomeController < ApplicationController
  include Webhookable
  skip_before_filter :authenticate_user!, :only => [:outboundcall, :suspendaccount]
  skip_before_filter :verify_authenticity_token, only: [:outboundcall, :suspendaccount] #, :verifyphonenumber]

  def call
    if tsid && tauthtoken && current_user.twilio_active?
      @from_phone_number = getTwilioVerifiedPhoneNumber # You should ideally get this from User table
      capability = Twilio::Util::Capability.new tsid, tauthtoken
      capability.allow_client_outgoing tappsid
      @twilio_token = capability.generate 300 #150 # 30 seconds, reference: https://www.twilio.com/docs/client/capability-tokens#token-expiration
      # return
    end
    @error = 'The voice is currently disabled.' if current_user.twilio_suspended?
    @twilio_token ||= ''
    respond_to do |format|
      format.html
      format.json { render :json => {:error=> @error, :twilio_token => @twilio_token},
                           :status => status(@error) }
    end
  end

  def addphonenumber
  end

  def verifyphonenumber
    tc = Twilio::REST::Client.new tsid, tauthtoken
    caller_id = tc.outgoing_caller_ids.create(:phone_number => params[:PhoneNumber])
    respond_to do |format|
      format.json { render :json => {:verification_code => caller_id.validation_code},
                    :status => :ok }
    end
  end

  #This is callback service. Twilio calls this when the end-user makes a call from Twilio Web Client
  def outboundcall
    # This FromPhoneNumber should have been verified in the associated sub-account
    render_twiml generateTwiml(params[:FromPhoneNumber], params[:ToPhoneNumber])
  end

  def suspendaccount
    user = User.find_by_tsid(params["AccountSid"]);
    user.suspend_twilio_account

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
    end #.text.strip
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

  def status error
    error.blank? ? :ok : :unauthorized
  end

  def getTwilioClient
    Twilio::REST::Client.new tsid, tauthtoken
  end

  def getTwilioVerifiedPhoneNumber
    tc = getTwilioClient
    caller_id = tc.outgoing_caller_ids.list.first
    puts "-"*10 + " #{caller_id.try(:phone_number)} " + "-"*10
    caller_id.present? ? caller_id.phone_number : ''
  end
end
