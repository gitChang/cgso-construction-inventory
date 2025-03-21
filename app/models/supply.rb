class Supply < ActiveRecord::Base
  has_many :item_masterlists

  before_validation :uppercase_kind


  validates :kind,
    presence: { message: 'Please provide the Supply Type.' },
    length:   { within: 3..50, message: 'Supply Type only accepts 3 to 50 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Supply Type found.' }


  private


  def uppercase_kind
    self.kind = kind.upcase if kind
  end

end
