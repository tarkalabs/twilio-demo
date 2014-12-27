# A worker is just a class with two features.
# 1. It needs an instance variable called @queue that holds the name of the queue. This limits the queues that the worker handles.
# 2. It needs a class method called perform that takes the arguments that we passed to `enqueue`
class TwilioServiceWorker
  @queue = :twilio_queue

  def self.perform(action, hash)
    # To prevent stale connections in MySQL
    # Rails Doc says, "Verify active connections and remove and disconnect connections associated with stale threads."
    # ActiveRecord::Base.verify_active_connections!
    puts "action=#{action}, id=#{hash['id']}, sid=#{hash['sid']}"
    self.send action, hash
  end

  def self.create_subaccount hash
    id = hash['id']
    puts "create_subaccount invoked for id=#{id}"
    ts = TwilioService.new
    user = User.find id
    subaccount = ts.create_subaccount("#{user.id}_#{user.email}")
    #TODO: save subaccount.sid to against the user in table
    user.sid = subaccount.sid
    user.save!
    puts "A subaccount is successfully created at Twilio with friendly name = #{subaccount.friendly_name} and sid = #{subaccount.sid}"
  end

  def self.suspend_subaccount hash
    id = hash['id']
    ts = TwilioService.new
    user = User.find id
    subaccount = ts.suspend_subaccount("#{user.sid}")
    puts "A subaccount with sid #{user.sid} is temporarily suspended in Twilio."

  end

  def self.reactivate_subaccount hash
    id = hash['id']
    ts = TwilioService.new
    user = User.find id
    subaccount = ts.reactivate_subaccount("#{user.sid}")
    puts "A subaccount with sid #{user.sid} is reactivated in Twilio."
  end

  def self.delete_subaccount hash
    id = hash['id']
    sid = hash['sid']
    puts "delete_subaccount invoked for sid=#{sid}"
    ts = TwilioService.new
    subaccount = ts.delete_subaccount("#{sid}")
    puts "A subaccount with sid #{sid} is deleted in Twilio."
  end
end
