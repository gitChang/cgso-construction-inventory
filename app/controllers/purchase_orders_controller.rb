class PurchaseOrdersController < ApplicationController
  before_action :init_po, only: :create
  before_action :validate_po, only: :create
  before_action :reinit_po, only: :update


  def index
    po_items = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:key]
      # when searching for po_number
      if params[:key].downcase == 'po'
        query_results = PurchaseOrder.where('po_number LIKE ?', "%#{params[:val]}%")
      end

      # when searching for pow
      if params[:key].downcase == 'pow'
        project = Project.find_by_pow_number(params[:val].downcase)
        query_results = project.purchase_orders if project
      end

      # when searching for department
      if params[:key].downcase == 'department' && params[:val].present?
        department = Department.find_by_name(params[:val].upcase)
        department.projects.each { |p| query_results = p.purchase_orders } if department
      end

      # when searching for supplier
      if params[:key].downcase == 'supplier' && params[:val].present?
        supplier = Supplier.find_by_name(params[:val].upcase)
        query_results = supplier.purchase_orders if supplier
      end

      # when searching for inspector
      if params[:key].downcase == 'inspector' && params[:val].present?
        inspector = Inspector.find_by_name(params[:val].upcase)
        query_results = inspector.purchase_orders if inspector
      end

      # when searching for purpose
      if params[:key].downcase == 'purpose' && params[:val].present?
        projects = Project.where('purpose LIKE ?', "%#{params[:val].upcase}%")
                          .collect { |p| p.id }
        query_results = PurchaseOrder.where('project_id IN (?)', projects) if projects.present?
      end

    else
      # default collection
      query_results = PurchaseOrder.order(date_issued: :desc)
    end

    unless query_results
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, po_items: [] }
      return
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    po_items = query_results.collect do |po|
                              {
                                id: po.id,
                                date_issued: po.date_issued,
                                department: po.project.department.name,
                                po_number: po.po_number,
                                pow_number: po.project.pow_number.present? ? po.project.pow_number : "",
                                supplier: po.supplier.name,
                                inspector: po.inspector.name,
                                purpose: po.project.purpose
                              }
                            end
    render json: Paginator.pagination_attributes(query_results).merge!(po_items: po_items)
  end


  def create
    render json: { id: @po.id }, status: 200 if @po.save && create_items
  end


  def show
    po = PurchaseOrder.find(params[:id])
    render json: build_po(po), status: 200 if po.present?
  end


  def download_po_pdf
    po = PurchaseOrder.find(params[:id])
    pdf = PurchaseOrderReportPdf.new(build_po(po))
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def edit
    po = PurchaseOrder.find(params[:id])
    if po
      render json: {
        department: po.project.department.name,
        pr_number: po.project.pr_number,
        pow_number: po.project.pow_number,
        po_number: po.po_number,
        date_issued: po.date_issued,
        iar_number: po.iar_number,
        date_of_delivery: po.date_of_delivery,
        complete: po.complete,
        inspector: po.inspector.name,
        supplier: po.supplier.name,
        mode_of_procurement: po.mode_of_procurement.mode,
        remarks: po.remarks,
        po_items: po.stocks.collect { |item| {
                                                id: item.id,
                                                item_id: item.item_id,
                                                item_number: item.item_number,
                                                quantity: item.stock_in,
                                                unit: item.item_masterlist.unit.abbrev,
                                                name: item.item_masterlist.name,
                                                cost: item.cost,
                                                amount: item.stock_in * item.cost,
                                                remarks: item.remarks,
                                                delete: 'no',
                                                edited: 'no'
                                              }
                                            }
      }
    end
  end


  def update
    render json: true, status: 200 if @po && update_items
  end


  def po_stack_card
    po = PurchaseOrder.find(params[:poid])
    po_sc = { po_number: po.po_number, pr_number: po.project.pr_number, stocks: [] }
    tmp_stock_in = nil

    po.stocks.order(:item_number).each do |in_stock|
      po_sc[:stocks] << {
        po_stock: in_stock.item_masterlist.name,
        item_number: in_stock.item_number,
        stock_in: in_stock.stock_in,
        stock_bal: nil,
        ris_stocks: []
      }
      tmp_stock_in = in_stock.stock_in

      in_stock.stocks.each do |out_stock|
        po_sc[:stocks].last[:ris_stocks] << {
          ris_number: out_stock.req_issued_slip.ris_number,
          stock_out: out_stock.stock_in,
          withdrawn_by: out_stock.req_issued_slip.withdrawn_by,
        }
        tmp_stock_in -= out_stock.stock_in
      end
      po_sc[:stocks].last[:stock_bal] = tmp_stock_in
    end

    render json: po_sc
  end


  def cert_of_delivery
    project = Project.where(pr_number: params[:pr_number]).first
    project_data = {
      pow_number: project.pow_number,
      cert_number: project.cert_number.present? ? project.cert_number : autonumber_cert,
      in_charge: project.project_in_charge.name,
      purpose: project.purpose.remove('.'),
      issued_date: "#{Time.now.day.ordinalize} of #{Date.today.strftime("%B")}, #{Time.now.year}",
      pos: []
    }
    if project
      project.purchase_orders.order(:po_number).each_with_index do |po|
        project_data[:pos] << {
          po_number: po.po_number,
          po_date: "%02d/%02d/%04d" % [po.date_issued.month,po.date_issued.day,po.date_issued.year],
          supplier: po.supplier.name,
          amount: get_amount_po(po)
        }

        render json: project_data
        return
      end
      render json: {}
    end
  end


  def download_cert_of_delivery_report_pdf
    project = Project.where(pr_number: params[:pr_number]).first
    project_data = {
      pow_number: project.pow_number,
      cert_number: project.cert_number.present? ? project.cert_number : autonumber_cert,
      in_charge: project.project_in_charge.name,
      purpose: project.purpose.remove('.'),
      issued_date: "#{Time.now.day.ordinalize} of #{Date.today.strftime("%B")}, #{Time.now.year}",
      pos: []
    }

    project.purchase_orders.order(:po_number).each do |po|
      project_data[:pos] << {
        po_number: po.po_number,
        po_date: "%02d/%02d/%04d" % [po.date_issued.month,po.date_issued.day,po.date_issued.year],
        supplier: po.supplier.name,
        amount: get_amount_po(po)
      }
    end

    pdf = CertOfDeliveryReportPdf.new(project_data)
    project.update_attribute(:cert_number, autonumber_cert) unless project.cert_number.present?
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def check_project_completion
    po = PurchaseOrder.where(id: params[:id]).first
    if po
      if po.project.prs_number.present?
        render json: true
        return
      end
    end
    render json: false
  end



  private


  def autonumber_cert
    month_number = Time.now.month
    series = 1

    last_cert = Project.where("cert_number <> ''").collect{|c| c.cert_number}.sort.last
    if last_cert
      series = last_cert.split('-')[0].to_i + 1
      unless last_cert.split('-')[1].to_i == month_number
        series = 1
      end
    end

    year_number = Time.now.year - 2000

    "%04d-%02d-%02d" % [series,month_number,year_number]
  end


  def build_po(po)
    po_content = {
      prs_number: po.project.prs_number,
      id: po.id,
      department: po.project.department.name,
      supplier: po.supplier.name,
      address: po.supplier.address,
      date_issued: po.date_issued,
      po_number: po.po_number,
      pr_number: po.project.pr_number,
      pow_number: po.project.pow_number,
      remarks: po.remarks,
      mode_of_procurement: po.mode_of_procurement.mode,
      purpose: po.project.purpose,
      inspector: po.inspector.name,
      completed_delivery: po.complete ? 'Completed' : 'Partial',
      date_of_delivery: po.date_of_delivery
    }

    po_content[:po_items] = po.stocks.order(:item_number)
                              .collect do |stock|
                                {
                                  item_number: stock.item_number,
                                  quantity: stock.stock_in,
                                  balance: stock.stock_bal,
                                  unit: stock.item_masterlist.unit.abbrev,
                                  name: stock.item_masterlist.name,
                                  cost: sprintf('%.2f', stock.cost),
                                  amount: sprintf('%.2f', stock.stock_in * stock.cost),
                                  remarks: stock.remarks
                                }
                              end
    return po_content
  end


  def po_params
    @project = Project.where(pr_number: params[:pr_number], pow_number: params[:pow_number]).first

    params.permit(
              :po_number,
              :date_issued,
              :pr_number,
              :pow_number,
              :iar_number,
              :date_of_delivery,
              :complete,
              :remarks,
              :genkey
          ).merge(
              po_items: params[:po_items],
              project: @project,
              supplier_id: get_supplier_id,
              inspector_id: get_inspector_id,
              mode_of_procurement_id: get_mode_of_proc_id,
              user_id: current_user.id
          )
  end


  def init_po
    @po = PurchaseOrder.new(po_params)
  end


  def reinit_po
    @po = PurchaseOrder.find(params[:id])
    render json: @po.errors.first, status: 301 unless @po.update_attributes(po_params)
  end


  def validate_po
    render json: @po.errors.first, status: 301 if @po.invalid?
  end


  def create_items
    params[:po_items].each do |item|
      item = Stock.create(
                purchase_order: @po,
                project: @project,
                item_number: item.last[:item_number],
                item_id: item.last[:item][:id],
                cost: item.last[:cost],
                stock_in: item.last[:quantity],
                stock_bal: item.last[:quantity],
                remarks: item.last[:remarks]
             )

      unless item
        break
        return
      end
    end

    return true
  end


  def update_items
    params[:po_items].each do |item|

      unless item.last[:id].present?
        Stock.create(
                purchase_order: @po,
                project: @project,
                item_number: item.last[:item_number],
                item_id: item.last[:item][:id],
                cost: item.last[:cost],
                stock_in: item.last[:quantity],
                stock_bal: item.last[:quantity],
                remarks: item.last[:remarks]
              )
        next
      end

      stock_item = Stock.find(item.last[:id])

      if stock_item && item.last[:delete] == 'no' && item.last[:edited] == 'no'
        stock_item = stock_item.update(
                        project: @project,
                        item_number: item.last[:item_number]
                      )
        next
      end

      if stock_item && item.last[:delete] == 'yes'
        stock_item.destroy
      end

      if stock_item && item.last[:delete] == 'no' && item.last[:edited] == 'yes'
        stock_item.update(
          item_number: item.last[:item_number],
          item_id: item.last[:item_id] || item.last[:item][:id],
          stock_in: item.last[:quantity],
          cost: item.last[:cost]
        )
      end
    end

    return true
  end

  def get_amount_po(po)
    amt = 0.00
    po.stocks.each { |stock| amt += stock.stock_in * stock.cost }
    return amt
  end

end
