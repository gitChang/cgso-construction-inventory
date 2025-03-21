class UserActionsLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :purchase_order
  belongs_to :req_issued_slip
end
