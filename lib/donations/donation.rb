class Donation
  attr_accessor :last_name, :first_name, :participant_id, :donation_value, :is_check, :check_number

  def initialize(donation_id)
	  donation = query_donation(donation_id)

	  @last_name = donation[0]["last_name"].capitalize
	  @first_name = donation[0]["first_name"].capitalize
	  @participant_id = donation[0]["participant_id"]
	  @donation_value = donation[0]["donation_value"]
	  @is_check = donation[0]["is_check"] == 't' ? true : false
	  @check_number = donation[0]["check_number"]
	  
  end
  
  def query_donation(donation_id)
	  query = "select donation.* from donation where donation_id='#{donation_id}';"
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
  
  def update(donation_id, donor_first_name, donor_last_name, donation_value, is_check, check_number)
	  if is_check
		  query = "update donation set first_name='#{donor_first_name}', last_name='#{donor_last_name}',
		  donation_value=#{donation_value}, is_check=TRUE, check_number=#{check_number}
		  where donation_id = #{donation_id};"
	  else 
		  query = "update donation set first_name='#{donor_first_name}', last_name='#{donor_last_name}',
		  donation_value=#{donation_value}, is_check=FALSE, check_number=NULL
		  where donation_id = #{donation_id};"
	  end
	  return ActiveRecord::Base.connection.execute(query)
  end
end
