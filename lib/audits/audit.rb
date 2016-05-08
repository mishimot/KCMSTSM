class Audit
  attr_accessor :audit_date, :auditor
  def initialize(donation_id)
	  audit = query_audit(donation_id)
	  @audit_date = audit.num_tuples.zero? ? "" : audit[0]["audit_date"]
	  @auditor = audit.num_tuples.zero? ? "" : audit[0]["auditor"]
	  
  end
  
  def query_audit(donation_id)
	  query = "select audit.* from audit where donation_id='#{donation_id}';"
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
  
  def audit_count(donation_id)
	  query = "select count(*) from audit where donation_id='#{donation_id}';"
	  
	  return ActiveRecord::Base.connection.execute(query)
  end
end
