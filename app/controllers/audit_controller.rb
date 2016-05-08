require 'audits/audit'
require 'donations/donation'

class AuditController < ApplicationController
  def audit
	@is_admin = params[:is_admin]
    if user_signed_in? and @is_admin
	  @donation_id = params[:donation_id]
	  @auditor = params[:auditor]
	  @participants = ActiveRecord::Base.connection.execute("select first_name, last_name, participant_id from participant where is_active = true;")
	  donation = Donation.new(@donation_id)
	  
	  participant = ActiveRecord::Base.connection.execute("select first_name, last_name, participant_id from participant where participant_id=#{donation.participant_id};")
	  @name = participant[0]["first_name"] + " " + participant[0]["last_name"] + ", " + participant[0]["participant_id"]
	  @last_name = donation.last_name
	  @first_name = donation.first_name
	  @donation_value = donation.donation_value
	  @is_check = donation.is_check
	  @check_number = donation.check_number
	end
  end
  
  def submit_audit
	donor_first_name = params[:donor_first_name].upcase
	donor_last_name = params[:donor_last_name].upcase
	donation_value = params[:donation_value]
	is_check = (params[:is_check] == '1' ? true : false)
	check_number = params[:check_number]
	auditor_initials = params[:auditor_initials]
	@donation_id = params[:donation_id]

	donation = Donation.new(@donation_id)
	donation.update(@donation_id, donor_first_name, donor_last_name, donation_value,
	is_check, check_number)	
	audit = insert_audit(@donation_id, auditor_initials)
	redirect_to root_path
  end
  
  def insert_audit(donation_id, auditor_initials)
	  x = audit_count(donation_id)[0]["count"]
	  if x == 0
		query = "insert into audit(donation_id, audit_date, auditor) 
		values (#{donation_id}, '#{Time.now}', '#{auditor_initials}');"
		ActiveRecord::Base.connection.execute(query)
	  else
		query = "update audit set audit_date='#{Time.now}', auditor='#{auditor_initials}'
		where donation_id=#{donation_id};"
		ActiveRecord::Base.connection.execute(query)
	  end
  end
  
  def audit_count(donation_id)
	  query = "select count(*) from audit where donation_id='#{donation_id}';"
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
end
