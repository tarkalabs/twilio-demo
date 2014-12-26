class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :create_twilio_subaccount

  def create_twilio_subaccount
    return if Rails.env.test?
    Resque.enqueue(TwilioServiceWorker, :create_subaccount, self.id)
  end
end
