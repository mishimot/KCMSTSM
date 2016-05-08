class Participant
  attr_accessor :id, :name, :initials, :is_leader, :is_admin, :team, :donations, :sum_donations

  def initialize(current_user_id)
	  participant_id = query_participant_id(current_user_id)
	  participant = query_participant(participant_id)

	  @id = participant_id[0]["participant_id"]
	  @name = participant[0]["first_name"].capitalize + " " + participant[0]["last_name"].capitalize
	  @initials = participant[0]["first_name"] + participant[0]["last_name"]
	  @is_leader = (participant[0]["is_leader"] == 't' ? true : false)
	  @is_admin = (participant[0]["is_admin"] == 't' ? true : false)
	  @team = participant[0]["team_id"]
	  
	  @donations = query_donations(@id, @team, @is_admin, @is_leader)
	  temp_sum_donations = query_donations_sum(@id, @team, @is_admin, @is_leader)[0]["sum"]
	  @sum_donations = (temp_sum_donations == nil ? 0 : temp_sum_donations)
  end

  def query_participant_id(current_user_id)
	  query = "select participant_id from users 
    where id=#{current_user_id};"

	  return ActiveRecord::Base.connection.execute(query)
  end

  def query_participant(participant_id)
	  query = "select participant.* from participant 
		where participant_id=#{participant_id[0]["participant_id"]};"

	  return ActiveRecord::Base.connection.execute(query)
  end
  
  def query_donations(participant_id, participant_team, is_admin, is_leader)
	  #Grabs their donations
	  if is_admin
		query = "select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id;"	
	  elsif is_leader
		query = "select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.team_id='#{participant_team}';"
	  else
		query = "select d.*, p.first_name as participant_first_name, p.last_name as participant_last_name from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.participant_id=#{participant_id};"
	  end  
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
  
    def query_donations_sum(participant_id, participant_team, is_admin, is_leader)
	  #Grabs their donations
	  if is_admin
		query = "select sum(d.donation_value) from donation d;"
	  elsif is_leader
		query = "select sum(d.donation_value) from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.team_id='#{participant_team}';"
	  else
		query = "select sum(d.donation_value) from participant p
		  inner join donation d on d.participant_id=p.participant_id
		  where p.participant_id=#{participant_id};"
	  end  
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
end
