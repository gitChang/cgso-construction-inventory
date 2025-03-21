class User < ActiveRecord::Base

  belongs_to :system_role


  authenticates_with_sorcery!

  attr_accessor :password_confirmation

  NAME_REGEX   = /\A[a-zA-Z .]+\z/
  UNAME_REGEX   = /\A[a-zA-Z_.]+\z/

  before_save :uppercase_name_and_designation


  validates :name,
    presence: { message: 'Please provide your Full Name.' },
    format:   { with: NAME_REGEX, message: 'Full Name only allows alphabet characters.' },
    length:   { within: 5..30, message: 'Full Name only accept 5 to 30 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Full Name found.' }

  validates :designation,
    presence: { message: 'Please provide your Designation.' },
    format:   { with: NAME_REGEX, message: 'Designation only allows alphabet characters.' },
    length:   { within: 5..50, message: 'Designation only accept 5 to 50 characters.' }

  validates :department_id,
    presence: { message: 'Please specify your Department.' },
    inclusion: { in: :department_ids, message: 'Department selected is invalid.' }

  validates :department_division_id,
    presence: { message: 'Please specify your Department Section.' },
    inclusion: { in: :department_division_ids, message: 'Department Section selected is invalid.' }

  validates :username,
      presence:   { message: 'Please provide your username.' },
      format:     { with: UNAME_REGEX, message: 'Username is only limited to alphabet characters, underscore and dot.' },
      length:     { within: 4..15, message: 'Account name should not be less that 4 characters and should not be more than 15 characters.' },
      uniqueness: { case_sensitive: false, message: 'The username is already in use. Please pick another one.' }

  validates :password,
      presence:     { message: 'Please provide your password.' },
      length:       { within: 4..12, message: 'Password should not be less that 4 characters and should not be more than 15 characters.' },
                    if: -> { new_record? || changes["password"] }

  validate  :compare_passwords, if: 'password.present?'

  validates :password,
      confirmation: { message: 'Please confirm your Password.' },
                    if: -> { new_record? || changes["password"] }

  validates :password_confirmation,
      presence: { message: 'Please confirm your Password.' },
      if: -> { new_record? || changes["password"] }

  validates :system_role_id,
    presence: { message: 'Please specify System Role.' },
    inclusion: { in: :system_role_ids, message: 'System Role selected is invalid.' }


  private

  def compare_passwords
    return unless password_confirmation.present?
    if password != password_confirmation
      errors.add(:password_confirmation, 'Your password does not match.')
    end
  end


  def uppercase_name_and_designation
    self.name = name.upcase
    self.designation = designation.upcase
  end


  def department_ids
    Department.all.collect {|d| d.id }
  end


  def department_division_ids
    DepartmentDivision.all.collect {|dv| dv.id }
  end


  def system_role_ids
    SystemRole.all.collect { |s| s.id }
  end

end
