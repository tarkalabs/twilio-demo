require 'resque_web'
ResqueWeb::Engine.eager_load! if Rails.env.development?

Rails.application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }

  # Route constraint using the current user when using Devise or another warden based authentication system
  resque_web_constraint = lambda do |request|
    # current_user = request.env['warden'].user
    # current_user.present? && current_user.respond_to?(:is_admin?) && current_user.is_admin?
    # puts "request.env['warden'].authenticate? = #{request.env['warden'].authenticate?}"
    # request.env['warden'].authenticate?
    true
  end
  constraints resque_web_constraint do
    mount ResqueWeb::Engine => "/resque_web"
  end

  root 'home#call'
  get 'call' => 'home#call'

  get 'addphonenumber' => 'home#addphonenumber'
  post 'verifyphonenumber' => 'home#verifyphonenumber'
  post 'outboundcall' => 'home#outboundcall'
  post 'suspendaccount' => 'home#suspendaccount'
  post 'twilio/voice' => 'twilio#voice'
  get 'twilio/inbound' => 'twilio#inbound'
  post 'twilio/notify' => 'twilio#notify'

end
