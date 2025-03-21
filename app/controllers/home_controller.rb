class HomeController < ApplicationController

  def index
    counts = {
      po_count: PurchaseOrder.all.count,
      ris_count: ReqIssuedSlip.all.count,
      items_count: ItemMasterlist.all.count,
      users_count: User.all.count
    }

    render json: counts, status: 200 if counts
  end
end
