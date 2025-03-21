class Stock < ActiveRecord::Base

  belongs_to :project
  belongs_to :item_masterlist, foreign_key: 'item_id'
  belongs_to :purchase_order
  belongs_to :req_issued_slip

  belongs_to :stock, foreign_key: 'source_stock_id'
  has_many :stocks, foreign_key: 'source_stock_id'


  NUMBER_REGEX   = /\A[0-9.,]+\z/

  #attr_accessor :source_stock_id <--- puta!! mao ni cause pirmi nil ang source_stock_id
  attr_accessor :pr_number


  validates :item_number,
    presence: { message: 'Please provide the Item Number.' },
    format:   { with: /\A[0-9]+\z/, message: 'Item Number only allows numbers.' }

  validate :check_dup_item_number

  validates :item_id,
    presence: { message: 'Please provide the Item.' }

  validates :stock_in,
    presence: { message: 'Please provide the Quantity.' },
    format:   { with: NUMBER_REGEX, message: 'Quantity only allows numbers and dot.' },
    numericality: { greater_than: 0.0, message: 'Quantity entered is invalid.' }

  validates :cost,
    presence: { message: 'Please provide the Cost.' },
    format:   { with: NUMBER_REGEX, message: 'Cost only allows numbers and dot.' }

  validate :sufficient_stock_balance


  def sufficient_stock_balance
    if source_stock_id
      if (Stock.find(source_stock_id).stock_in - Stock.find(source_stock_id).stock_out) < stock_in
        errors.add(:stock_in, 'Insufficient stock balance.')
      end
    end
  end


  def check_dup_item_number
    if pr_number
      count_dup = Project.find_by_pr_number(pr_number).stocks.where(item_number: item_number).count
      if count_dup > 0
        errors.add(:item_number, "HOY, BARAK! A duplicate Item Number ( #{item_number} ) has been Found. Check Project PO's List.")
      end
    end
  end

end
