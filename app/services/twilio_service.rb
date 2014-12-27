require 'twilio-ruby'

class TwilioService
  def initialize
    @twilio_sid = ENV['TWILIO_SID']
    @twilio_token = ENV['TWILIO_TOKEN']
  end

  def rest_client
    @rest_client ||= Twilio::REST::Client.new @twilio_sid, @twilio_token
    return @rest_client
  end

  def create_subaccount friendly_name
    subaccount = rest_client.accounts.create(:friendly_name => friendly_name)
  end

  def suspend_subaccount sid
    subaccount = rest_client.accounts.get(sid)
    subaccount.update(:status => "suspended")
    subaccount.status
  end

  def reactivate_subaccount sid
    subaccount = rest_client.accounts.get(sid)
    subaccount.update(:status => "active")
    subaccount.status
  end

  def delete_subaccount sid
    subaccount = rest_client.accounts.get(sid)
    subaccount.update(:status => "closed")
    subaccount.status
  end
end
