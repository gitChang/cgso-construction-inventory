class ModeOfProcurement < ActiveRecord::Base
  has_many :purchase_orders
end
