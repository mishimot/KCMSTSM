class PagesController < ApplicationController
  def home
    if user_signed_in?
	  #saves the participant id for all later sql commands
	  sql = "select participant_id from users 
		where id=#{current_user.id};"
	  participant_id = ActiveRecord::Base.connection.execute(sql)
	  #Grabs the participant
	  sql2 = "select participant.* from participant 
		where participant_id=#{participant_id[0]["participant_id"]};"
	  participant = ActiveRecord::Base.connection.execute(sql2)
	  @participant_name = participant[0]["first_name"].capitalize + " " + participant[0]["last_name"].capitalize
	  @participant_initials = participant[0]["first_name"] + participant[0]["last_name"]
	  @is_leader = (participant[0]["is_leader"] == 't' ? true : false)
	  @is_admin = (participant[0]["is_admin"] == '1' ? true : false)
	  
	  #Grabs their donations
	  sql3 = ""
	  if @is_admin
		@donations = ActiveRecord::Base.connection.execute("select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id;")
		@participants = ActiveRecord::Base.connection.execute("select first_name, last_name, participant_id from participant where is_active = true")
	  elsif @is_leader
		@donations = ActiveRecord::Base.connection.execute("select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.team_id='#{participant[0]["team_id"]}';")
	  else
		@donations = ActiveRecord::Base.connection.execute("select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.participant_id=#{participant_id[0]["participant_id"]};")
	  end
	  
	  #Saving donations
	  if @is_admin and request.post?
		  participant_name = params[:participant_name].split(',')
		  participant_id2 = participant_name[1]
		  donor_first_name = params[:donor_first_name].upcase
		  donor_last_name = params[:donor_last_name].upcase
		  donation_value = params[:donation_value]
		  is_check = (params[:is_check] == '1' ? true : false)
		  check_number = params[:check_number]
		  recorder = params[:recorder]
		  if is_check
			  ActiveRecord::Base.connection.execute("insert into donation
				(last_name, first_name, donation_value, is_check, check_number, recorder, participant_id)
				values('#{donor_last_name}', '#{donor_first_name}', 
				#{donation_value}, #{is_check}, #{check_number}, 
				'#{recorder}', '#{participant_id2}');")
		  else
			  ActiveRecord::Base.connection.execute("insert into donation
				(last_name, first_name, donation_value, is_check, recorder, participant_id)
				values('#{donor_last_name}', '#{donor_first_name}', 
				#{donation_value}, #{is_check}, 
				'#{recorder}', '#{participant_id2}');")
		  end
		  redirect_to root_path
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
  
  def deletedonation
	donation_id = params[:donation]
	ActiveRecord::Base.connection.execute("delete from donation where donation_id=#{donation_id}")
	@message = 'Donation Deleted!'
  end

  def leaderlookup
  end

  def teammanagement
  end

  def teamtotals
  end
end
