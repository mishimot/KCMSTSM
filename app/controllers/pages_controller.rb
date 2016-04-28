class PagesController < ApplicationController
  def home
	sql = "select participant from participant 
		where participant_id = (select participant_id from users 
		where participant_id='#{current_user.id}');"
	@participant = ActiveRecord::Base.connection.execute(sql).values[0]
  end
  
  def signup
  end
  
  def registered
	code = params[:code].gsub(/[^0-9A-Za-z]/, '').upcase
	first_name = params[:first_name].gsub(/[^0-9A-Za-z]/, '').upcase
	last_name = params[:last_name].gsub(/[^0-9A-Za-z]/, '').upcase
	email = params[:email].gsub(/[^0-9@-Za-z.]/, '')
	password = params[:password].gsub(/[^0-9A-Za-z]/, '')
	validate_password = params[:validate_password].gsub(/[^0-9A-Za-z]/, '')
	@message = ''
	
	#First check if the participant-usercode pairing exists at all by doing this count for the link between user_code and participant:
	sql = "select count(*) from user_code u, participant p 
		where u.participant_id=p.participant_id 
		and u.code = '#{code}'
		and p.last_name like '%#{last_name}%'
		and p.first_name = '#{first_name}';"
	x = ActiveRecord::Base.connection.execute(sql)
	
	#Next, check if the user already was created. We don’t want duplicate users for the same participant. We do this by counting how many users have that specific participant_id:
	sql2 = "select count(*) from users 
		where participant_id = 
		(select p.participant_id 
		from user_code u, participant p 
		where u.participant_id=p.participant_id 
		and u.code = '#{code}' 
		and p.last_name like '%#{last_name}%'
		and p.first_name = '#{first_name}');"
	y = ActiveRecord::Base.connection.execute(sql2)
	
	#Finally, we do a check for these values, which will decide if we insert into the users table.
	if x.values[0][0].to_i == 1 and y.values[0][0].to_i == 0 and password == validate_password
		password_salt = BCrypt::Engine.generate_salt
		password_hash = BCrypt::Engine.hash_secret(password,password_salt)
		sql3 = "insert into users (email, encrypted_password, created_at, updated_at, participant_id)
			values ('#{email}', '#{password_hash}', '#{Time.now}', '#{Time.now}',
			(select u.participant_id from user_code u where u.code = '#{code}'));"
		ActiveRecord::Base.connection.execute(sql3)
		@message = 'Account successfully created!'
	elsif password != validate_password
		@message = 'Passwords did not match'
	else
		@message = "Something broke...Contact the admin (x = #{x.values[0][0]}, y = #{y.values[0][0]})"
	end
	
  end

  def leaderlookup
  end

  def teammanagement
  end

  def teamtotals
  end
end
