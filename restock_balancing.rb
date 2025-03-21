def stock_balancing
  items = ItemMasterlist.order(:name)

  items.each do |item|
  # reassign stock_in to stock_bal
  # for rebalancing.
    item.stocks.where("purchase_order_id IS NOT NULL").each do |source|
      source.update_column(:stock_out, 0)
      source.update_column(:stock_bal, source.stock_in)
    end
  end

  items.order(:name).each do |item|
  # now, update stock_bal column.
    item.stocks.where("purchase_order_id IS NOT NULL").each do |source|
      source.stocks.each do |depent|
        source.update_column(:stock_out, source.stock_out + depent.stock_in)
        source.update_column(:stock_bal, source.stock_bal - depent.stock_in)
      end
    end
  end
end