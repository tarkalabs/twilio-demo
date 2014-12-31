# A worker is just a class with two features.
# 1. It needs an instance variable called @queue that holds the name of the queue. This limits the queues that the worker handles.
# 2. It needs a class method called perform that takes the arguments that we passed to `enqueue`
class TwilioServiceWorker
  @queue = :twilio_queue

  def self.perform(action, hash)
    # To prevent stale connections in MySQL
    # Rails Doc says, "Verify active connections and remove and disconnect connections associated with stale threads."
    # ActiveRecord::Base.verify_active_connections!
    puts "action=#{action}, id=#{hash['id']}, tsid=#{hash['tsid']}"
    self.send action, hash
  end

  def self.create_subaccount hash
    id = hash['id']
    puts "create_subaccount invoked for id=#{id}"
    ts = TwilioService.new
    user = User.find id

    unless user.tsid != nil
      friendly_name = "#{user.id}_#{user.email}"
      subaccount = ts.create_subaccount(friendly_name)
      user.tsid = subaccount.sid
      user.tauthtoken = subaccount.auth_token
      user.tfriendlyname = friendly_name
      user.save!
      puts "A subaccount is successfully created at Twilio with friendly name = #{subaccount.friendly_name} and sid = #{subaccount.sid}"
    end

    unless user.tappsid != nil
      app = ts.create_application(user.tsid, user.tauthtoken)
      user.tappsid = app.sid
      user.save!
      puts "A TwiML App for the sub-account #{subaccount.friendly_name} is created"
    end

    trigger_value = "0.30"
    trigger = ts.create_usage_trigger_on_price_for_calls(subaccount.sid, subaccount.auth_token, trigger_value)
    # user.ttrigsid = trigger.sid
    # user.save!
  end

  def self.suspend_subaccount hash
    id = hash['id']
    ts = TwilioService.new
    user = User.find id
    subaccount = ts.suspend_subaccount("#{user.tsid}")
    # user.tactive = false
    puts "A subaccount with sid #{user.sid} is temporarily suspended in Twilio."
  end

  def self.reactivate_subaccount hash
    id = hash['id']
    ts = TwilioService.new
    user = User.find id
    subaccount = ts.reactivate_subaccount("#{user.tsid}")
    puts "A subaccount with sid #{user.tsid} is reactivated in Twilio."
  end

  def self.delete_subaccount hash
    id = hash['id']
    tsid = hash['tsid']
    puts "delete_subaccount invoked for tsid=#{tsid}"
    ts = TwilioService.new
    subaccount = ts.delete_subaccount("#{tsid}")
    puts "A subaccount with sid #{tsid} is deleted in Twilio."
  end
end
