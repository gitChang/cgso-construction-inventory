class DepartmentDivision < ActiveRecord::Base
  belongs_to :department
  has_many :users
  has_many :purchase_orders
  has_many :req_issued_slips
end
