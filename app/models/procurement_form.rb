class ProcurementForm < ActiveRecord::Base
  has_many :purchase_orders
  has_many :req_issued_slips
  has_many :stocks
end
