class PagesController < ApplicationController
  def home
    if user_signed_in?
	  #saves the participant id for all later sql commands
	  sql = "select participant_id from users 
		where id=#{current_user.id};"
	  participant_id = ActiveRecord::Base.connection.execute(sql).values[0][0]
	  #Grabs the participant
	  sql2 = "select participant from participant 
		where participant_id='#{participant_id}';"
	  participant = ActiveRecord::Base.connection.execute(sql2).values[0][0].split(',')
	  @participant_name = participant[2].capitalize + " " + participant[1].capitalize
	  @participant_initials = participant[2].capitalize[0] + " " + participant[1].capitalize[0]
	  @is_leader = participant[7]
	  @is_admin = participant[8]
	  
	  #Grabs their donations
	  sql3 = ""
	  if @is_admin
		sql3 = "select * from donation;"
		@participants = ActiveRecord::Base.connection.execute("select first_name, last_name from participants where is_active = true").values[0]
	  
	  elsif @is_leader
		sql3 = "select d from donation d 
		  inner join participant p 
		  on p.participant_id=d.participant_id
		  where p.team_id='#{participant[6]}';"
	  else
		sql3 = "select * from donation
		  where participant_id='#{participant_id}';"
	  end
	  
	  @donations = ActiveRecord::Base.connection.execute(sql3).values[0]
	  #Saving donations
	  if request.post?
		  date = params[:date]
		  participant_name = params[:participant_name]
		  donor_first_name = params[:donor_first_name]
		  donor_last_name = params[:donor_last_name]
		  donation_value = params[:donation_value]
		  is_check = params[:is_check]
		  check_number = params[:check_number]
		  recorder = params[:recorder]
		end
	end
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
		@message = "Something broke...Contact the admin (Debug x = #{x.values[0][0]}, y = #{y.values[0][0]})"
	end
	
  end

  def leaderlookup
  end

  def teammanagement
  end

  def teamtotals
  end
end
