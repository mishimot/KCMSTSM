require 'audits/audit'
require 'donations/donation'

class AuditController < ApplicationController
  def audit
    if user_signed_in? and @is_admin
	  donation_id = params[:donation_id]
	  @auditor = params[:auditor]
	  donation = Donation.new(donation_id)
	
	  @last_name = donation.last_name
	  @first_name = donation.first_name
	  @donation_value = donation.donation_value
	  @is_check = donation.is_check
	  @check_number = donation.check_number
	  @participants = ActiveRecord::Base.connection.execute("select first_name, 
	  last_name, participant_id from participant where is_active = true;")
	  
	  if request.post?
		donor_first_name = params[:donor_first_name].upcase
		donor_last_name = params[:donor_last_name].upcase
		donation_value = params[:donation_value]
		is_check = (params[:is_check] == '1' ? true : false)
		check_number = params[:check_number]
		auditor_initials = params[:auditor_initials]
		donation.update(donor_first_name, donor_last_name, donation_value,
		is_check, check_number)	
		audit = insert_audit(donation_id, auditor)
		redirect_to root_path
	  end
	end
  end
  
  def insert_audit(donation_id, auditor)
	  x = audit_count(donation_id)[0]["count"]
	  if x == 0
		query = "insert into audit(donation_id, audit_date, auditor) 
		values (#{donation_id}, #{Time.now}, '#{auditor}');"
	  else
		query = "update audit set audit_date=#{Time.now}, auditor='#{auditor}'
		where donation_id=#{donation_id};"
	  end
	  
	  ActiveRecord::Base.connection.execute(query)
  end
end
