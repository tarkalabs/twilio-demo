require 'twilio-ruby'

class TwilioService
  def rest_client(tsid = ENV['TWILIO_SID'], ttoken = ENV['TWILIO_TOKEN'])
    Twilio::REST::Client.new tsid, ttoken
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

  def create_application sid, token
    # https://www.twilio.com/docs/api/rest/applications
    client = Twilio::REST::Client.new sid, token
    app = client.account.applications.create(:friendly_name => "VoiceApp",
    :voice_url => "http://6d7af12f.ngrok.com/outboundcall",
    :voice_method => "POST") #TODO: Change to GET, necessary???
  end

  def create_twiml_app_for subaccount
    app = create_application(subaccount.sid, subaccount.auth_token)
  end

  def create_usage_trigger_on_price_for_calls sid, token, trigger_value
    # https://www.twilio.com/docs/api/rest/usage-triggers#list-post
    # https://www.twilio.com/docs/api/rest/usage-records#usage-categories
    client = rest_client(sid, token)
    trigger = client.account.usage.triggers.create(:trigger_value => trigger_value, # Could be like "1.30" or "+1.50",
    :trigger_by => "price",
    :usage_category => "totalprice", #"calls",
    :callback_url => "http://6d7af12f.ngrok.com/suspendaccount") #TODO: Have a controller-method to notify user of account suspended for voice
  end
end
