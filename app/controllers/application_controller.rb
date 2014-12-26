class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # The before_filter :authenticate_user! line ensures that current_user is never nil,
  # thus avoiding the fatal error: method called on nil object.
  # Ensures all actions invoke this (except those invoked with skip_before_filer)
  before_filter :authenticate_user!

end
