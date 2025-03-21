class Supplier < ActiveRecord::Base
  has_many :purchase_orders
  has_many :item_masterlists

  before_validation :uppercase_name_address


  validates :name,
    presence: { message: 'Please provide the Supplier Name.' },
    length:   { within: 3..100, message: 'Supplier Name only accepts 3 to 100 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate Supplier name found.' }

  validates :address,
    presence: { message: 'Please provide Supplier Address.' },
    length:   { within: 5..200, message: 'Supplier Address only accepts 5 to 200 characters.' }


  private

    def uppercase_name_address
      self.name = name.upcase if name
      self.address = address.upcase if address
    end
end
