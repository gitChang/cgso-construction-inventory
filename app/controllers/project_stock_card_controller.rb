class ProjectStockCardController < ApplicationController

  def index
    projects = []
    PurchaseOrder.select('DISTINCT pr_number, pow_number, purpose').each do |project|
      projects << {
                    pr_number: project.pr_number,
                    pow_number: project.pow_number,
                    #project_incharge: ReqIssuedSlip.where(pow_number: project.pow_number).first.requested_by,
                    purpose: project.purpose
                  }
    end

    render json: projects
  end


  def show
    po = PurchaseOrder.find_by_pow_number(params[:pow_number])

    project = {
      stock_card_date: Time.now.strftime('%A, %B %d, %Y'),
      name_of_project: po ? po.purpose : nil,
      pow_number: params[:pow_number],
      in_charge: ReqIssuedSlip.where(pow_number: po.pow_number).first.requested_by,
      items: []
    }

    Stock.where(pow_number: params[:pow_number], procurement_form_name_id: ProcurementForm.find_by_effect('OUT').id)
         .collect do |stock|
            project[:items] << {
                                  date_received: get_record(stock.procurement_form_name_id, stock.procurement_form_index_id).date_issued,
                                  po_number: get_reference(Stock.find(stock.source_stock_id).procurement_form_name_id, Stock.find(stock.source_stock_id).procurement_form_index_id),
                                  item_number: stock.item_number,
                                  item_name: stock.item_masterlist.name,
                                  receipt_quantity: Stock.find(stock.source_stock_id).stock_in,
                                  unit: ItemMasterlist.find(stock.item_id).unit.abbrev,
                                  unit_cost: Stock.find(stock.source_stock_id).cost,
                                  issued_quantity: stock.stock_in,
                                  date_issued: get_record(stock.procurement_form_name_id, stock.procurement_form_index_id).date_issued,
                                  withdrawn_by: get_record(stock.procurement_form_name_id, stock.procurement_form_index_id).withdrawn_by,
                                  ris_number: get_reference(stock.procurement_form_name_id, stock.procurement_form_index_id)
                                }
    end

    render json: project
  end

end
