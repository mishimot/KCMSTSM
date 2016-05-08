require 'participants/participant'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  
  def is_leader?
	current_participant = Participant.new(current_user.id)
	return current_participant.is_leader
  end

end
