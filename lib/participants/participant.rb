class Participant
  attr_accessor :name, :initials, :is_leader, :is_admin

  def initialize(current_user_id)
    participant_id = query_participant_id(current_user_id)
	  participant = query_participant(participant_id)

	  @name = participant[0]["first_name"].capitalize + " " + participant[0]["last_name"].capitalize
	  @initials = participant[0]["first_name"] + participant[0]["last_name"]
	  @is_leader = (participant[0]["is_leader"] == 't' ? true : false)
	  @is_admin = (participant[0]["is_admin"] == 't' ? true : false)
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
end
