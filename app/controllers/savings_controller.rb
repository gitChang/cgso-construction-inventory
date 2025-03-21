class SavingsController < ApplicationController

  def per_project
    project_content = Hash.new
    project = Project.where(pow_number: params[:pow_number]).first
    if project.present?
      project_content[:pr_number] = project.pr_number
      project_content[:pow_number] = project.pow_number
      project_content[:prs_number] = project.prs_number
      project_content[:in_charge] = project.project_in_charge.name
      project_content[:purpose] = project.purpose

      project_content[:items] = project.stocks.where(savings: true).collect do |s|
                                  {
                                    item_number: s.item_number,
                                    rid: s.req_issued_slip.id,
                                    ris: "RIS ##{s.req_issued_slip.ris_number}",
                                    poid: s.stock.purchase_order_id,
                                    source_po: "PO ##{s.stock.purchase_order.po_number}",
                                    item_name: s.item_masterlist.name,
                                    cost: s.cost,
                                    quantity: s.stock_in,
                                    balance: s.stock_in - s.stock_out
                                  }
                                end
    else
      project_content = { items: [] }
    end

    render json: project_content
  end


  def per_item
    savings_items = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:item_id].present?
      item = ItemMasterlist.where(id: params[:item_id]).first
      query_results = item.stocks.where(savings: true).order(:item_id) if item
    else
      query_results = Stock.where(savings: true).order(:item_id)
    end

    unless query_results.present?
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, savings_items: [] }
      return
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    savings_items = query_results.collect do |s|
                      {
                        item_number: s.item_number,
                        item_name: s.item_masterlist.name,
                        owner: s.project.project_in_charge.name,
                        prs_number: s.project.prs_number,
                        pow_number: s.project.pow_number,
                        pr_number: s.project.pr_number,
                        poid: s.stock.purchase_order_id,
                        po_number: s.stock.purchase_order.po_number,
                        rid: s.req_issued_slip_id,
                        ris_number: s.req_issued_slip.ris_number,
                        cost: s.cost,
                        balance: s.stock_in - s.stock_out
                      }
                    end

    render json: Paginator.pagination_attributes(query_results).merge!(savings_items: savings_items)
  end


  def savings_report
    if params[:item_id]
      item = ItemMasterlist.where(id: params[:item_id]).first
      query_results = item.stocks.where(savings: true)
    else
      query_results = Stock.where(savings: true)
    end

    savings_items = query_results.collect do |s|
                      {
                        item_number: s.item_number,
                        item_name: s.item_masterlist.name,
                        owner: s.project.project_in_charge.name,
                        prs_number: s.project.prs_number,
                        pow_number: s.project.pow_number,
                        pr_number: s.project.pr_number,
                        poid: s.stock.purchase_order_id,
                        po_number: s.stock.purchase_order.po_number,
                        rid: s.req_issued_slip_id,
                        ris_number: s.req_issued_slip.ris_number,
                        cost: s.cost,
                        balance: s.stock_in - s.stock_out
                      }
                    end

    pdf = SavingsReportPdf.new(savings_items)
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end

end
