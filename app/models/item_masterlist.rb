class ItemMasterlist < ActiveRecord::Base
  has_many :purchase_orders
  has_many :req_issued_slips
  has_many :stocks, foreign_key: 'item_id'

  belongs_to :unit
  belongs_to :supply

  before_validation :uppercase_name


  validates :name,
    presence: { message: 'Please provide item description.' },
    length:   { within: 5..2000, message: 'Item description only accepts 5 to 2000 characters.' },
    uniqueness: { case_sensitive: false, message: 'Duplicate item found.', on: :create }

  validate :check_dup_in_parameterize_name, on: :create

  validates :unit_id,
    presence: { message: 'Please assign a unit for this item.' },
    inclusion: { in: :unit_ids, message: 'The selected unit is invalid.' }

  validates :supply_id,
    presence: { message: 'Please assign the type of supply for this item.' },
    inclusion: { in: :supply_ids, message: 'Invalid type of supply.' }


  private


    def check_dup_in_parameterize_name
      dup_in_parameterize = ItemMasterlist.where(name_parameterize: name.parameterize).first
      errors.add(:name, 'Duplicate item found.') if dup_in_parameterize
    end

    def uppercase_name
      self.name = name.squish.upcase if name
    end


    def unit_ids
      Unit.all.collect { |u| u.id }
    end


    def supply_ids
      Supply.all.collect { |s| s.id }
    end
end
