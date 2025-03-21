class Warehouseman < ActiveRecord::Base
  has_many :req_issued_slips
end
