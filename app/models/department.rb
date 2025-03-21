class Department < ActiveRecord::Base
  has_many :departments
  has_many :department_divisions
  has_many :users
  has_many :projects
  #has_many :project_in_charges

  before_validation :uppercase_name_and_abbrev

  validates :name,
    presence: { message: 'Please provide the Department name.' },
    length:   { within: 3..300, message: 'Department Name only accepts 10 to 300 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Department found.' }

  validates :abbrev,
    presence: { message: 'Please provide the Department short name.' },
    length:   { within: 3..300, message: 'Department short name only accepts 3 to 10 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Department short name found.' }

  private

  def uppercase_name_and_abbrev
    self.name = name.upcase if name
    self.abbrev = abbrev.upcase if abbrev
  end

end
