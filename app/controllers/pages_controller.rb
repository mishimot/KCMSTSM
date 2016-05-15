require 'participants/participant'
require 'audits/audit'

class PagesController < ApplicationController
  def home
    if user_signed_in?
      current_participant = Participant.new(current_user.id)

	  @participant_id = current_participant.id
      @participant_name = current_participant.name
      @participant_initials = current_participant.initials
      @is_leader = current_participant.is_leader
      @is_admin = current_participant.is_admin
	  @participant_team = current_participant.team
	  @donations = current_participant.donations
	  @sum_donations = current_participant.sum_donations
	  @audit = nil
	  
	  @participants = ActiveRecord::Base.connection.execute("select first_name, last_name, participant_id from participant where is_active = true;")
	  
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
	ActiveRecord::Base.connection.execute("delete from audit where donation_id=#{donation_id}")
	ActiveRecord::Base.connection.execute("delete from donation where donation_id=#{donation_id}")
	@message = 'Donation Deleted!'
  end

  def leaderlookup
	
  end

  def teammanagement
    if user_signed_in?
	  current_participant = Participant.new(current_user.id)
	  is_leader = current_participant.is_leader
      is_admin = current_participant.is_admin
	  participant_team = current_participant.team
	  @TOTAL_COST = 1750
	  if is_leader
		@team_country = ActiveRecord::Base.connection.execute("select team_country from team where team_id='#{participant_team}';")[0]["team_country"]
		@team_member_donations = ActiveRecord::Base.connection.execute("select p.first_name, p.last_name, p.is_leader, sum(donation_value)
		from participant p inner join donation d on d.participant_id=p.participant_id 
		where p.is_active=true and p.team_id='#{participant_team}' group by p.participant_id
		order by p.participant_id;")
	  elsif is_admin
		team_id = params[:id]
		@team_country = ActiveRecord::Base.connection.execute("select team_country from team where team_id='#{team_id}';")[0]["team_country"]
		@team_member_donations = ActiveRecord::Base.connection.execute("select p.first_name, p.last_name, p.is_leader, sum(donation_value)
		from participant p inner join donation d on d.participant_id=p.participant_id 
		where p.is_active=true and p.team_id='#{team_id}' group by p.participant_id
		order by p.participant_id;")
	  end
	end
  end

  def teamtotals
	if user_signed_in?
		current_participant = Participant.new(current_user.id)
		is_admin = current_participant.is_admin
		if is_admin
			@team_donations = ActiveRecord::Base.connection.execute("select t.team_country, t.team_id, sum(donation_value) from participant p
				inner join donation d on d.participant_id=p.participant_id
				inner join team t on t.team_id=p.team_id and p.is_active
				group by t.team_country, t.team_id
				order by t.team_country;")
			@total_amount = Participant.new(current_user.id).sum_donations
		end
	end
  end
end
