class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Use after_commit instead of after_create
  # Reference: http://rails-bestpractices.com/posts/695-use-after_commit
  # References: http://www.codebeerstartups.com/2012/11/use-after_commit-instead-of-active-record-callbacks-to-avoid-unexpected-errors
  after_commit :create_twilio_subaccount, on: :create

  def create_twilio_subaccount
    return if Rails.env.test?
    Resque.enqueue(TwilioServiceWorker, :create_subaccount, self.id)
  end
end
