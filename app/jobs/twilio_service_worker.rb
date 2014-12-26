# A worker is just a class with two features.
# 1. It needs an instance variable called @queue that holds the name of the queue. This limits the queues that the worker handles.
# 2. It needs a class method called perform that takes the arguments that we passed to `enqueue`
class TwilioServiceWorker
  @queue = :twilio_queue

  def self.perform(action, id)
    self.send action, id
  end

  def create_subaccount id
    puts "Job with #{id} is created."
  end
end
