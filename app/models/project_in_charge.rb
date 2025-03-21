class ProjectInCharge < ActiveRecord::Base

  has_many :projects
  #belongs_to :department

  NAME_REGEX   = /\A[a-zA-Z ,.-Ññ]+\z/
  UNAME_REGEX   = /\A[a-zA-Z_.]+\z/


  before_save :uppercase_name_designation


  #validates :department_id,
  #  presence: { message: 'Please specify Department.' },
  #  inclusion: { in: :department_ids }

  validates :name,
    presence: { message: 'Please provide the full name of the Project In-Charge' },
    format:   { with: NAME_REGEX, message: 'Name only allows alphabet characters.' },
    length:   { within: 2..50, message: 'Full name only accepts 2 to 50 alphabet characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Full Name found.' }

  validates :designation,
    presence: { message: 'Please provide the Designation.' },
    format:   { with: NAME_REGEX, message: 'Full Name only allows alphabet characters.' },
    length:   { within: 5..30, message: 'Designation only accepts 5 to 30 alphabet characters.' }


  private


  def department_ids
    Department.all.collect {|i| i.id }
  end


  def uppercase_name_designation
    self.name = name.upcase
    self.designation = designation.upcase
  end

end
