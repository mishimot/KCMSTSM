class PagesController < ApplicationController
  def home
  end
  
  def signup
  end
  
  def registered
	@username = params[:username]
	@password = params[:password]
  end

  def leaderlookup
  end

  def teammanagement
  end

  def teamtotals
  end
end
