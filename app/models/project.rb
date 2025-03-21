class Project < ActiveRecord::Base

  has_many :purchase_orders
  has_many :req_issued_slips
  has_many :stocks

  belongs_to :department
  belongs_to :project_in_charge
  belongs_to :endorsement


  NUMBER_REGEX   = /\A[0-9_-]+\z/
  ALPHA_REGEX = /\A[a-zA-Z -]+\z/


  before_save :uppercase_purpose


  validates :department_id,
    presence: { message: 'Please specify the Department.' },
    inclusion: { in: :department_ids }

  validates :project_in_charge_id,
    presence: { message: 'Please provide the Project In-Charge.' },
    inclusion: { in: :project_in_charge_ids, message: 'The Project In-charge selected is invalid.' }

  validates :pr_number,
    presence: { message: 'Please provide the PR number.' },
    format:   { with: NUMBER_REGEX, message: 'PR number only allows numbers and dashes (-).' },
    uniqueness: { case_sensitive: false, message: 'Duplicate PR number found.' }

#  validates :pow_number,
#    presence: { message: 'Please provide the POW number.' },
#    format:   { with: NUMBER_REGEX, message: 'POW number only allows numbers and dashes (-).' },
#    uniqueness: { case_sensitive: false, message: 'Duplicate POW number found.' }

  validates :purpose,
    presence: { message: 'Please provide the Project Name.' }


  def uppercase_purpose
    self.purpose = purpose.upcase
  end


  def department_ids
    Department.all.collect {|i| i.id }
  end


  def project_in_charge_ids
    ProjectInCharge.all.collect { |p| p.id }
  end
end
