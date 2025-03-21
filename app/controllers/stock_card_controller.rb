class StockCardController < ApplicationController

  def show
    item = ItemMasterlist.where(id: params[:id]).first

    if item
      stock_card = {
        incoming: [],
        incoming_total_quantity: 0.00,
        incoming_total_cost: 0.00,
        outgoing: [],
        outgoing_total_quantity: 0.00,
        outgoing_total_cost: 0.00,
      }

      # INCOMING

      # PO
      items = Stock.where('item_id = ? and purchase_order_id IS NOT NULL', params[:id]).order('purchase_order_id')

      items.each do |item|
        stock_card[:incoming_total_quantity] += item.stock_in
        stock_card[:incoming_total_cost] += item.cost * item.stock_in

        stock_card[:incoming] << {
          item_id: item.item_id,
          supplier: item.purchase_order.supplier.name,
          owner: item.purchase_order.project.project_in_charge.name,
          purpose: item.purchase_order.project.purpose,
          pr_number: item.purchase_order.project.pr_number,
          date_received: item.purchase_order.date_of_delivery,
          poid: item.purchase_order_id,
          po_number: item.purchase_order.po_number,
          qty_in: item.stock_in,
          cost: item.cost,
          balance: item.stock_in - item.stock_out
        }
      end

      # SORT
      stock_card[:incoming] = stock_card[:incoming].sort_by{ |e| e[:date_received]}

      # OUTGOING
      items = Stock.where('req_issued_slip_id IS NOT NULL and item_id = ?', params[:id]).order("req_issued_slip_id")

      items.each do |item|
        stock_card[:outgoing_total_quantity] += item.stock_in
        stock_card[:outgoing_total_cost] += item.cost * item.stock_in

        stock_card[:outgoing] << {
          item_id: item.item_id,
          pow_number: item.req_issued_slip.project.pow_number,
          pr_number: item.req_issued_slip.project.pr_number,
          ris_date: item.req_issued_slip.date_issued,
          risid: item.req_issued_slip_id,
          ris_number: item.req_issued_slip.ris_number,
          qty_out: item.stock_in,
          cost: item.cost,
          withdrawn_by: item.req_issued_slip.withdrawn_by
        }
      end

      # SORT
      stock_card[:outgoing] = stock_card[:outgoing].sort_by{|e| e[:ris_date]}

      render json: stock_card
      return
    end

    render json: []
  end


  def filter_incomings
    stock_card = {
      incoming: [],
      incoming_total_quantity: 0.00,
      incoming_total_cost: 0.00,
      outgoing: [],
      outgoing_total_quantity: 0.00,
      outgoing_total_cost: 0.00,
    }

    # INCOMING
    items = Stock.where("item_id = ?", params[:item_id])
                 .where("purchase_order_id IS NOT NULL")
                 .order('purchase_order_id')

    items.each do |item|
      # IF FILTERED PO YEAR
      if params[:po_year]
        next if item.purchase_order.po_number.split("-")[0].to_i + 2000 != params[:po_year].to_i
      end

      # IF FILTERED IN-CHARGE
      if params[:in_charge]
        next if item.purchase_order.project.project_in_charge.name.upcase != params[:in_charge].upcase
      end

      # IF FILTERED DATE RECEIVED
      if params[:date_received]
        next unless Date.strptime(params[:date_received], "%m/%d/%Y").to_date == item.purchase_order.date_of_delivery
      end

      stock_card[:incoming_total_quantity] += item.stock_in
      stock_card[:incoming_total_cost] += item.cost * item.stock_in

      stock_card[:incoming] << {
        item_id: item.item_id,
        supplier: item.purchase_order.supplier.name,
        owner: item.purchase_order.project.project_in_charge.name,
        purpose: item.purchase_order.project.purpose,
        pr_number: item.purchase_order.project.pr_number,
        date_received: item.purchase_order.date_of_delivery,
        poid: item.purchase_order_id,
        po_number: item.purchase_order.po_number,
        qty_in: item.stock_in,
        cost: item.cost,
        balance: item.stock_in - item.stock_out
      }
    end

    items = Stock.where("item_id = ?", params[:item_id])
                 .where("req_issued_slip_id IS NOT NULL")
                 .order("req_issued_slip_id")

    items.each do |item|
      # IF FILTERED PO YEAR
      if params[:po_year]
        next if item.stock.purchase_order.po_number.split("-")[0].to_i + 2000 != params[:po_year].to_i
      end

      # IF FILTERED IN-CHARGE
      if params[:in_charge]
        next if item.stock.purchase_order.project.project_in_charge.name.upcase != params[:in_charge].upcase
      end

      # IF FILTERED DATE RECEIVED
      if params[:date_received]
        next unless Date.strptime(params[:date_received], "%m/%d/%Y").to_date == item.stock.purchase_order.date_of_delivery
      end

      stock_card[:outgoing_total_quantity] += item.stock_in
      stock_card[:outgoing_total_cost] += item.cost * item.stock_in

      stock_card[:outgoing] << {
        item_id: item.item_id,
        pow_number: item.req_issued_slip.project.pow_number,
        pr_number: item.req_issued_slip.project.pr_number,
        ris_date: item.req_issued_slip.date_issued,
        risid: item.req_issued_slip_id,
        ris_number: item.req_issued_slip.ris_number,
        qty_out: item.stock_in,
        cost: item.cost,
        withdrawn_by: item.req_issued_slip.withdrawn_by
      }
    end

    render json: stock_card
  end

end
