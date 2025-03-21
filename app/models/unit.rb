class Unit < ActiveRecord::Base

  before_validation :uppercase_name


  validates :name,
    presence: { message: 'Please provide the Unit name.' },
    length:   { within: 3..20, message: 'Unit Name only accepts 3 to 20 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Unit found.' }

  validates :abbrev,
    presence: { message: 'Please provide the Unit Abbreviation.' },
    length:   { within: 2..10, message: 'Unit Abbreviation only accepts 2 to 10 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Unit Abbreviation found.' }


  private

  def uppercase_name
    self.name = name.upcase if name
  end
end
