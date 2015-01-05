module Rack
  class TwilioWebhookAuthentication
    def getAuthToken account_sid
      return '' if account_sid.nil?
      user = User.find_by_tsid(account_sid)
      puts "--------------- #{user.tauthtoken} --------------"
      user.tauthtoken
    end
  end
end
