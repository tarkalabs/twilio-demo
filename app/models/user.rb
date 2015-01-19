class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Use after_commit instead of after_create
  # Reference: http://rails-bestpractices.com/posts/695-use-after_commit
  # References: http://www.codebeerstartups.com/2012/11/use-after_commit-instead-of-active-record-callbacks-to-avoid-unexpected-errors
  after_commit :create_twilio_subaccount, on: :create
  before_destroy :delete_twilio_subaccount

  def twilio_active?
    tactive == true  #to return false for nil when the user object is created for the 1st time
  end

  def twilio_suspended?
    not twilio_active?
  end

  def suspend_twilio_account
    self.update_attribute(:tactive, false)
    # Temporarily turning off account suspension
    # Resque.enqueue(TwilioServiceWorker, :suspend_subaccount, { id: self.id, tsid: self.tsid })
  end

  private
  def create_twilio_subaccount
    return if Rails.env.test?
    logger.info "create_twilio_subaccount callback invoked for id = #{self.id}"
    Resque.enqueue(TwilioServiceWorker, :create_subaccount, { id: self.id })
  end

  def delete_twilio_subaccount
    return if Rails.env.test?
    logger.info "delete_twilio_subaccount callback invoked for id = #{self.id}, sid = #{self.tsid}"
    Resque.enqueue(TwilioServiceWorker, :delete_subaccount, { id: self.id, tsid: self.tsid })
  end
end
