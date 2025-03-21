class ReqIssuedSlipController < ApplicationController
  before_action :init_ris, only: :create
  before_action :validate_ris, only: :create
  before_action :reinit_ris, only: :update


  def index
    ris_items = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:key]
      # when searching for ris_number
      if params[:key].downcase == 'ris'
        query_results = ReqIssuedSlip.where('ris_number LIKE ?', "%#{params[:val]}%")
        .order(:ris_number)
      end

      # when searching for pow
      if params[:key].downcase == 'pow'
        project = Project.where("pow_number ilike ?", params[:val]).first
        query_results = project.req_issued_slips.order(:ris_number) if project
      end

      # when searching for department
      if params[:key].downcase == 'department' && params[:val].present?
        department = Department.find_by_abbrev(params[:val].upcase)
        department.projects.each { |p| query_results = p.req_issued_slips } if department
      end

      # when searching for warehouseman
      if params[:key].downcase == 'released by' && params[:val].present?
        warehouseman = Warehouseman.find_by_name(params[:val].upcase)
        query_results = warehouseman.req_issued_slips if warehouseman
      end

      # when searching for withdrawn_by
      if params[:key].downcase == 'withdrawn by'
        query_results = ReqIssuedSlip.where('withdrawn_by LIKE ?', "%#{params[:val].upcase}%")
      end

      # when searching for purpose
      if params[:key].downcase == 'purpose' && params[:val].present?
        projects = Project.where('purpose LIKE ?', "%#{params[:val].upcase}%")
                          .collect { |p| p.id }
        query_results = ReqIssuedSlip.where('project_id IN (?)', projects) if projects.present?
      end

    else
      # default collection
      query_results = ReqIssuedSlip.order(date_issued: :desc)
    end

    unless query_results
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, ris_items: [] }
      return
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    # respond data
    ris_items = query_results.collect do |ris|
                                {
                                  id: ris.id,
                                  date_issued: ris.date_issued,
                                  department: ris.project.department.abbrev,
                                  ris_number: ris.ris_number,
                                  pow_number: ris.project.pow_number.present? ? ris.project.pow_number : "",
                                  pr_number: ris.project.pr_number,
                                  released_by: ris.warehouseman.name,
                                  withdrawn_by: ris.withdrawn_by.present? ? ris.withdrawn_by.split(',').first.strip : '',
                                  purpose: ris.project.purpose
                                }
                              end

    render json: Paginator.pagination_attributes(query_results).merge!(ris_items: ris_items)
  end


  def create
    render json: { id: @ris.id }, status: 200 if @ris.save && create_items
  end


  def show
    ris = ReqIssuedSlip.find(params[:id])
    render json: build_ris(ris), status: 200 if ris.present?
  end


  def download_ris_pdf
    ris = ReqIssuedSlip.find(params[:id])
    pdf = ReqIssuedSlipReportPdf.new(build_ris(ris))
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def edit
    ris = ReqIssuedSlip.find(params[:id])
    if ris

      render json: {
                id: ris.id,
                department: ris.project.department.name,
                savings: ris.savings,
                ris_number: ris.ris_number,
                pr_number: ris.project.pr_number,
                pow_number: ris.project.pow_number,
                date_issued: ris.date_issued,
                warehouseman: ris.warehouseman.name,
                date_released: ris.date_released,
                purpose: ris.project.purpose,
                in_charge: ris.project.project_in_charge.name,
                approved_by: ris.approved_by,
                issued_by: ris.issued_by,
                withdrawn_by: ris.withdrawn_by,
                ris_items: ris.stocks.order(:item_number)
                                     .collect do |stock|
                                        {
                                          id: stock.id,
                                          item_id: stock.item_id,
                                          item_number: stock.item_number,
                                          source: get_source(stock),
                                          unit: stock.item_masterlist.unit.abbrev,
                                          name: stock.item_masterlist.name,
                                          quantity: stock.stock_in,
                                          cost: stock.cost,
                                          amount: stock.stock_in * stock.cost,
                                          remarks: stock.remarks,
                                          delete: 'no'
                                        }
                                      end
              }
    end
  end


  def update
    render json: true, status: 200 if @ris && update_items
  end


  def destroy
    xris = ReqIssuedSlip.find(params[:id])
    xris.destroy
    xris.project.update_column(:prs_number, "") if xris.project.prs_number.present?
    render json: true
  end


  def check_project_completion
    ris = ReqIssuedSlip.where(id: params[:id]).first
    if ris
      if ris.project.prs_number.present?
        render json: true
        return
      end
    end
    render json: false
  end


  def source_items
    has_references = params[:pr_number].present? # || params[:pow_number].present?
    unless has_references
      render json: [], status: 200
      return
    end

    project = Project.where(pr_number: params[:pr_number]).first

    if project
      stocks = project.stocks.where('purchase_order_id IS NOT NULL')
      items =  stocks.collect do |stock|
                {
                  source_stock_id: stock.id,
                  source: "PO ##{stock.purchase_order.po_number}",
                  item_number: stock.item_number,
                  item:
                  {
                    id: stock.item_id,
                    name: stock.item_masterlist.name,
                    unit: stock.item_masterlist.unit.abbrev
                  },
                  quantity: stock.stock_in.to_i - stock.stock_out.to_i,
                  cost: stock.cost
                }
              end
    end

    if items.present?
      render json: items, status: 200
    else
      render json: [], status: 200
    end
  end


  def source_savings_items
    has_references = params[:pr_number].present? # || params[:pow_number].present?
    unless has_references
      render json: [], status: 200
      return
    end

    project = Project.where(pr_number: params[:pr_number]).first

    if project
      stocks = project.stocks.where(savings: true)
      items =  stocks.collect do |stock|
                {
                  source_stock_id: stock.id,
                  #source: "RIS ##{stock.req_issued_slip.ris_number}",
                  source: "PRS ##{stock.req_issued_slip.project.prs_number}",
                  item_number: stock.item_number,
                  item:
                  {
                    id: stock.item_id,
                    name: stock.item_masterlist.name,
                    unit: stock.item_masterlist.unit.abbrev
                  },
                  quantity: stock.stock_in - stock.stock_out,
                  cost: stock.cost
                }
              end
    end

    if items.present?
      render json: items, status: 200
    else
      render json: [], status: 200
    end
  end

  def get_approvers
    render json: ReqIssuedSlip.select('DISTINCT approved_by').order(:approved_by).collect {|a| a.approved_by }
  end


  def get_issuers
    render json: ReqIssuedSlip.select('DISTINCT issued_by').order(:issued_by).collect {|i| i.issued_by }
  end


  def get_receivers
    render json: ReqIssuedSlip.select('DISTINCT withdrawn_by').order(:withdrawn_by).collect {|w| w.withdrawn_by }
  end


  private


  def ris_params
    @project = Project.where(pr_number: params[:pr_number], pow_number: params[:pow_number]).first
    params.permit(
            :savings,
            :date_issued,
            :ris_number,
            :pr_number,
            :pow_number,
            :date_released,
            :approved_by,
            :issued_by,
            :withdrawn_by,
            :genkey
          ).merge(
            ris_items: params[:ris_items],
            project: @project,
            warehouseman_id: get_warehouseman_id,
            user_id: current_user.id
          )
  end


  def init_ris
    @ris = ReqIssuedSlip.new(ris_params)
  end


  def reinit_ris
    @ris = ReqIssuedSlip.find(params[:id])
    render json: @ris.errors.first, status: 301 unless @ris.update_attributes(ris_params)
  end


  def validate_ris
    render json: @ris.errors.first, status: 301 if @ris.invalid?
  end


  def create_items
    params[:ris_items].each do |item|
      ris_item = Stock.new(
                  source_stock_id: item.last[:source_stock_id],
                  req_issued_slip: @ris,
                  project: @ris.project,
                  # savings: @ris.savings,
                  item_number: item.last[:item_number],
                  item_id: item.last[:item][:id],
                  cost: item.last[:cost],
                  stock_in: item.last[:quantity],
                  stock_bal: item.last[:quantity],
                  remarks: item.last[:remarks]
                )

      unless ris_item.save
        break
        return
      end

      # update source item stock out
      source_item = Stock.find(ris_item.source_stock_id)
      source_item.update_attribute(:stock_out, source_item.stock_out + ris_item.stock_in)
    end

    return true
  end


  def update_items
    if @ris.stocks.present? # check items are present.
      if @ris.savings != @ris.stocks.first.savings
        @ris.stocks.update_all(savings: params[:savings].to_b)
      end
    end

    params[:ris_items].each do |item|
      unless item.last[:id].present?
        stock_item = Stock.create(
                        source_stock_id: item.last[:source_stock_id],
                        req_issued_slip: @ris,
                        project: @ris.project,
                        # savings: params[:savings].to_b,
                        item_number: item.last[:item_number],
                        item_id: item.last[:item][:id],
                        cost: item.last[:cost],
                        stock_in: item.last[:quantity],
                        stock_bal: item.last[:quantity],
                        remarks: item.last[:remarks]
                      )
        # update source item stock out
        source_item = Stock.find(stock_item.source_stock_id)
        source_item.update_attribute(:stock_out, source_item.stock_out + stock_item.stock_in)
        next
      end

      stock_item = Stock.find(item.last[:id])

      if stock_item && item.last[:delete] == 'no'
        stock_item = stock_item.update(
                            project: @ris.project,
                            item_number: item.last[:item_number],
                          )
        next
      end

      if stock_item && item.last[:delete] == 'yes'
        # update source stock out. reclaim quantity.
        stock_source = Stock.where(id: stock_item.source_stock_id).first
        if stock_source
          stock_source.stock_out -= stock_item.stock_in
          stock_source.save
          # delete ris item.
          stock_item.destroy
        end
      end
    end

    return true
  end


  def get_source(stock)
    if Stock.find(stock.source_stock_id).purchase_order
      ref = "PO #{Stock.find(stock.source_stock_id).purchase_order.po_number}"
    end
    if Stock.find(stock.source_stock_id).req_issued_slip
      #ref= "RIS #{Stock.find(stock.source_stock_id).req_issued_slip.ris_number}"
      ref= "PRS #{Stock.find(stock.source_stock_id).req_issued_slip.project.prs_number}"
    end

    ref
  end


  def build_ris(ris)
    ris_content = Hash.new

    ris_content = {
      id: ris.id,
      department: ris.project.department.name,
      ris_number: ris.ris_number,
      pow_number: ris.project.pow_number.present? ? ris.project.pow_number : '',
      pr_number: ris.project.pr_number,
      savings: ris.savings,
      date_issued: DateTime.parse(ris.date_issued.to_s).strftime("%b %d, %Y"),
      released_by: ris.warehouseman.name,
      date_released: ris.date_released,
      purpose: ris.project.purpose,
      in_charge: ris.project.project_in_charge.name,
      in_charge_designation: ris.project.project_in_charge.designation,
      approved_by: ris.approved_by.split(',').take(ris.approved_by.split(',').size-1).join(', ').strip.upcase,
      approved_by_designation: ris.approved_by.split(',').size > 1 ? ris.approved_by.split(',').last.strip : '',
      issued_by: ris.issued_by.split(',').take(ris.issued_by.split(',').size-1).join(', ').strip.upcase,
      issued_by_designation: ris.issued_by.split(',').size > 1 ? ris.issued_by.split(',').last.strip : '',
      withdrawn_by: ris.withdrawn_by.present? ? ris.withdrawn_by.split(',').first.strip.upcase : '',
      withdrawn_by_designation: ris.withdrawn_by.split(',').size > 1 ? ris.withdrawn_by.split(',').last.strip : '',
      ris_items: [],
      user: current_user.name
    }

    ris.stocks.order(:item_number).each do |stock|
      if ris.savings
        next unless stock.stock_bal.to_i > 0
      end
      ris_content[:ris_items] << {
          poid: Stock.find(stock.source_stock_id).purchase_order_id,
          risid: Stock.find(stock.source_stock_id).req_issued_slip_id,
          source: get_source(stock),
          item_number: stock.item_number,
          unit: stock.item_masterlist.unit.abbrev,
          name: stock.item_masterlist.name,
          quantity: stock.stock_bal,
          balance: stock.savings ? stock.stock_in - stock.stock_out : nil,
          remarks: stock.remarks
        }
    end
    return ris_content
  end

end
