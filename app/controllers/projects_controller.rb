class ProjectsController < ApplicationController

  before_action :init_project, only: :create
  before_action :validate_project, only: :create


  def index
    projects = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:key]
      # WHEN SEARCHING FOR PR_NUMBER
      if params[:key].downcase == 'pr'
        query_results = Project.order(:pr_number).where('pr_number LIKE ?', "%#{params[:val]}%")
      end

      # WHEN SEARCHING FOR POW_NUMBER
      if params[:key].downcase == 'pow'
        query_results = Project.order(:pow_number).where('pow_number LIKE ?', "%#{params[:val]}%")
      end

      # WHEN SEARCHING FOR DEPARTMENT
      if params[:key].downcase == 'department' && params[:val].present?
        department = Department.find_by_abbrev(params[:val].upcase)
        query_results = department.projects if department
      end

      # WHEN SEARCHING FOR IN-CHARGE
      if params[:key].downcase == 'in-charge' && params[:val].present?
        in_charge = ProjectInCharge.find_by_name(params[:val].upcase)
        query_results = in_charge.projects if in_charge
      end

      # WHEN SEARCHING FOR PROJECT NAME
      if params[:key].downcase == 'project'
        query_results = Project.where('purpose LIKE ?', "%#{params[:val].upcase}%")
      end

    else
      # DEFAULT COLLECTION
      query_results = Project.order(created_at: :desc)
    end

    unless query_results
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, projects: [] }
      return
    end

    unless params[:endorse].to_b && params[:endorsed_only].to_b
      query_results = query_results.paginate(page: page, per_page: 8)
    end

    if params[:endorse].to_b
      query_results = query_results.where(endorsed: false).paginate(page: page, per_page: 8)
    end

    if params[:endorsed_only].to_b
      query_results = query_results.where(endorsed: true).paginate(page: page, per_page: 8)
    end

    projects = query_results.collect do |p|
                  ris_id = p.req_issued_slips.where(savings: true).first ? p.req_issued_slips.where(savings: true).first.id : nil
                  ris_number = p.req_issued_slips.where(savings: true).first ? p.req_issued_slips.where(savings: true).first.ris_number : nil
                  tbal_n_tcost = get_project_total_bal_cost(p)
                               {
                                  id: p.id,
                                  pr_number: p.pr_number,
                                  pow_number: p.pow_number,
                                  prs_number: p.prs_number,
                                  ris_savings_id: ris_id,
                                  ris_savings_number: ris_number,
                                  department: p.department.abbrev,
                                  in_charge: p.project_in_charge.name,
                                  purpose: p.purpose,
                                  balance: tbal_n_tcost[:t_bal],
                                  total_cost: tbal_n_tcost[:t_cost]
                               }
                             end
    render json: Paginator.pagination_attributes(query_results).merge!(projects: projects)
  end


  def create
    render json: true, status: 200 if @project.save
  end


  def edit
    project = Project.find(params[:id])
    if project
      render json: {
                    pr_number: project.pr_number,
                    pow_number: project.pow_number,
                    department: project.department.abbrev,
                    in_charge: project.project_in_charge.name,
                    purpose: project.purpose
                  }
    else
      render json: {}, status: 404
    end
  end


  def update
    project = Project.find(params[:id])
    if project.update(
                  department_id: get_department_id,
                  project_in_charge_id: get_project_in_charge_id,
                  pr_number: params[:pr_number],
                  pow_number: params[:pow_number],
                  purpose: params[:purpose]
                )
      render json: true, status: 200
    else
      render json: project.errors.first, status: 301
    end
  end


  def get_project_detail
    project = Project.where('pr_number = ? OR pow_number = ?', params[:pr_number], params[:pow_number]).first

    if project
      render json: { pow_number: project.pow_number, pr_number: project.pr_number, purpose: project.purpose, department: project.department.name }, status: 200
      return
    end

    render json: [], status: 200
  end


  def get_in_charge
    project = Project.find_by_pr_number(params[:pr_number])

    if project
      render json: [project.project_in_charge.name], status: 200
      return
    end

    render json: [], status: 200
  end


  def stock_card
    project = Project.where('pr_number = ?', params[:pr_number]).first
    project_data = {
      name_of_project: project.purpose,
      pr_number: project.pr_number,
      pow_number: project.pow_number,
      in_charge: project.project_in_charge.name,
      total_quantity: 0,
      total_cost: 0.00,
      items: [],
    }

    project.stocks.where("purchase_order_id IS NOT NULL").order(:item_number).each do |stock|
      project_data[:items] << {
        date_received: stock.purchase_order.date_issued,
        poid: stock.purchase_order_id,
        item_id: stock.item_id,
        item_number: stock.item_number,
        item_name: stock.item_masterlist.name,
        unit: stock.item_masterlist.unit.abbrev.downcase,
        po_number: stock.purchase_order.po_number,
        received_quantity: stock.stock_in,
        unit_cost: stock.cost,
        total_cost: stock.stock_in * stock.cost
      }
      project_data[:total_quantity] += project_data[:items].last[:received_quantity]
      project_data[:total_cost] += project_data[:items].last[:total_cost]
    end

    render json: project_data
  end


  def download_stock_card_pdf
    project = Project.where(pr_number: params[:pr_number]).first
    project_data = build_stock_card(project)

    pdf = StockCardReportPdf.new(project_data)
    #send_data pdf.render, type: 'application/pdf', disposition: 'attachment', filename: "cgso-stock-card-report.pdf"
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def get_pow_data
    pow = Project.where(pow_number: params[:pow_number]).first

    unless pow.present?
      render json: {}, status: 301
      return
    end

    pow_data = {
      pow_number: pow.pow_number,
      purpose: pow.purpose,
      total_cost: get_project_total_bal_cost(pow)[:t_cost]
    }

    render json: pow_data
  end


  def gen_endorsement
    pdf = EndorsementReportPdf.new(params[:letter])
    File.delete('public/endorsement.pdf')
    pdf_new = File.new('public/endorsement.pdf', 'wb')
    pdf.render_file File.join(Rails.root, "public", "endorsement.pdf")

    params[:letter][:projects].each do |p|
      project = Project.where(pow_number: p.last[:pow_number]).first
      project.update_column(:endorsed, 'true'.to_b) if project.present?
    end

    render json: {}, status: 200
  end


  def save_prs
    project = Project.where('pr_number = ?', params[:pr_number]).first

    if create_ris_daemon(project)
      project.update_attribute(:prs_number, autonumber_prs)
      render json: true
    else
      render json: @ris_new.errors.first, status: 301
    end
  end


  def prs_content
    project = Project.where('pr_number = ?', params[:pr_number]).first
    materials = Array.new
    prs = {
            autonumber_prs: autonumber_prs,
            pow_number: project.pow_number,
            project_in_charge: project.project_in_charge.name,
            designation: project.project_in_charge.designation,
            materials: [],
            prs_number: project.prs_number
          }

    if project
      # PERFORM RESTOCK BALANCING PROJECT PO SOURCES.
      project_po = project.stocks.where('purchase_order_id IS NOT NULL')

      project_po.each do |source|
        # TMP RESET STOCK OUT
        tmp_source_stock_out = 0
        # INCREMENT TMP STOCK OUT WITH QTY. OF
        # DEPENDENT (RIS)
        source.stocks.each do |depent|
          tmp_source_stock_out += depent.stock_in
        end
        # ASSIGN NEW STOCK OUT QTY AND STOCK BAL.
        source.update_column(:stock_out, tmp_source_stock_out)
        source.update_column(:stock_bal, source.stock_in - tmp_source_stock_out)
      end

      if project.prs_number.present?
        materials = project.stocks.where(savings: true)
      else
        # FILTER STOCKS BAL. > 0
        project_po.each do |stock|
          next if stock.stock_bal <= 0
          materials << stock
        end
      end
      # ASSIGNING HASH LABELS FOR AJAX RESPONSE.
      materials.each do |m|
        prs[:materials] << {
                              stock_id: m.id,
                              quantity: m.stock_bal,
                              prs_quantity: m.prs_quantity.present? ? m.prs_quantity : nil,
                              unit: m.item_masterlist.unit.abbrev,
                              item_description: m.item_masterlist.name
                           }
      end
      render json: prs, status: 200
      return
    end

    render json: false
  end


  def prs_present
    project = Project.where('pr_number = ?', params[:pr_number]).first
    if project
      if project.prs_number.present?
        render json: true
        return
      end
    end
    render json: false
  end


  def download_prs_report_pdf
    project = Project.where('pr_number = ?', params[:pr_number]).first
    prs = {
            autonumber_prs: autonumber_prs,
            project_in_charge: project.project_in_charge.name,
            designation: project.project_in_charge.designation,
            materials: [],
            pow_number: project.pow_number,
            prs_number: project.prs_number
          }

    materials = project.stocks.where(savings: true)
    materials.each do |m|
      prs[:materials] << {
                            quantity: m.prs_quantity,
                            unit: m.item_masterlist.unit.abbrev,
                            item_description: m.item_masterlist.name
                         }
    end

    pdf = PrsReportPdf.new(prs)
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def po_collection
    project = {
      pr_number: nil,
      pow_number: nil,
      in_charge: nil,
      purpose: nil,
      pos: []
    }

    if params[:pr_number].present?
      proj = Project.where(pr_number: params[:pr_number]).first
      if proj
        project[:pr_number] = proj.pr_number
        project[:pow_number] = proj.pow_number
        project[:in_charge] = proj.project_in_charge.name
        project[:purpose] = proj.purpose
        project[:pos] = proj.purchase_orders
                        .collect do |po|
                        {
                          po_number: po.po_number,
                          poid: po.id,
                          date_received: po.date_of_delivery,
                          total_cost: calc_total_cost(po.stocks)
                        }
        end
      end
    end

    render json: project
  end


  def revert_endorsed_project
    project = Project.where(pow_number: params[:pow_number].strip).first
    if project
      project.update_column(:endorsed, "false".to_b)
      render json: true
      return
    end
    render json: false, status: 301
  end


  private


  def calc_total_cost(stocks)
    tcost = 0.00
    stocks.each do |s|
      tcost += s.cost * s.stock_in
    end
    return "%02d" % tcost
  end


  def autonumber
    return unless params[:date_issued].present?
    month_number = params[:date_issued].to_datetime.month # Time.now.month
    series = 1

    last_ris = ReqIssuedSlip.last
    if last_ris
      series = last_ris.ris_number.split('-')[1].to_i + 1
      unless last_ris.ris_number.split('-')[0].to_i == month_number
        series = 1
      end
    end

    year_number = params[:date_issued].to_datetime.year - 2000 # Time.now.year - 2000

    return "%02d-%04d-%02d" % [month_number,series,year_number]
  end


  def create_ris_daemon(project)
    @ris_new = ReqIssuedSlip.new(
                ris_number: autonumber,
                savings: true,
                date_issued: Time.now,
                pr_number: project.pr_number,
                pow_number: project.pow_number,
                date_released: Time.now,
                approved_by: 'ENGR. MARIO S. CAMPANER, ENGINEER IV',
                issued_by: 'JALMAIDA JAMIRI-MORALES, MPA, CITY GENERAL SERVICES OFFICER',
                withdrawn_by: project.project_in_charge.name,
                project: project,
                warehouseman_id: get_warehouseman_id('AUTO'),
                user_id: current_user.id
                )

    unless @ris_new.save
      return false
    end

    project.stocks.where('stock_bal > 0 AND purchase_order_id IS NOT NULL').each do |stock|
      ris_item = Stock.new(
                  source_stock_id: stock.id,
                  req_issued_slip: @ris_new,
                  project: project,
                  savings: true,
                  item_number: stock.item_number,
                  item_id: stock.item_id,
                  cost: stock.cost,
                  stock_in: stock.stock_bal,
                  stock_bal: stock.stock_bal,
                  remarks: stock.remarks,
                  prs_quantity: stock.stock_bal
                )

    ris_item.valid?

      unless ris_item.save
        break
        return
      end
    end
    return @ris_new.id
  end


  def build_stock_card(project)
    # RENDER NOTHING WHEN NO RIS (ISSUED) YET.
    #unless project.req_issued_slips.present?
    #  render json: {}, status: 301
    #  return
    #end

    stock_content = {
      stock_card_date: Time.now.strftime('%A, %B %d, %Y').upcase,
      name_of_project: project.purpose,
      pr_number: project.pr_number,
      pow_number: project.pow_number,
      in_charge: project.project_in_charge.name,
      total_number_received: 0.0,
      total_number_issued: 0.0,
      total_stock_balance: 0.0,
      total_cost: 0.0,
      average_cost_of_all_issuance: 0.0,
      average_cost_of_stock_balance: 0.0,
      items: [],
      prepared_by: current_user.name,
      prepared_by_designation: current_user.designation.titleize,
      reviewed_by: 'ROGER J. DOMPOL, MPA',
      reviewed_by_designation: 'Public Services Officer IV',
      approved_by: 'JALMAIDA JAMIRI-MORALES, MPA',
      approved_by_designation: 'General Services Officer'
    }

    if params[:po_number].present?
      # PROJECT FILTERED WITH THIS PO ONLY
      source_collection = project.purchase_orders.where(po_number: params[:po_number])
    else
      # GET ALL THE PROJECT PO's.
      source_collection = project.purchase_orders.order(:po_number)
    end

    source_collection.each do |po|
      po.stocks.each do |stock_po|

        # SET EMPTY ISSUANCE ROW WHEN NO ISSUANCE YET.
        unless stock_po.stocks.present?
          obj = Hash.new

          obj[:date_received] = stock_po.purchase_order.date_issued
          obj[:poid] = stock_po.purchase_order_id
          obj[:item_id] = stock_po.item_id
          obj[:item_number] = stock_po.item_number
          obj[:item_name] = stock_po.item_masterlist.name
          obj[:po_number] = stock_po.purchase_order.po_number
          obj[:received_quantity] = stock_po.stock_in.to_i
          obj[:unit] = stock_po.item_masterlist.unit.abbrev
          obj[:unit_cost] = stock_po.cost
          obj[:total_cost] = stock_po.cost * stock_po.stock_in.to_i
          obj[:issued_quantity] = 0.0
          obj[:unit_out] = 0.0
          obj[:unit_cost_out] = 0.0
          obj[:total_cost_out] = 0.0
          obj[:date_issued] = ''
          obj[:withdrawn_by] = '--'
          obj[:risid] = ''
          obj[:ris_number] = ''
          obj[:balance] = obj[:received_quantity]

          stock_content[:items] << obj
          next # PROCEED TO NEXT ITEM.
        end

        # GET ALL THE ISSUANCES OF THE PO.
        stock_po.stocks.order('item_id').each_with_index do |stock_ris, index|

          obj = Hash.new

          # SET STOCK CARD INFORMATION
          obj[:date_received] = stock_po.purchase_order.date_issued
          obj[:poid] = stock_po.purchase_order_id
          obj[:item_id] = stock_po.item_id
          obj[:item_number] = stock_po.item_number
          obj[:item_name] = stock_po.item_masterlist.name
          obj[:po_number] = stock_po.purchase_order.po_number
          obj[:received_quantity] = stock_po.stock_in.to_i
          obj[:unit] = stock_po.item_masterlist.unit.abbrev
          obj[:unit_cost] = stock_po.cost
          obj[:total_cost] = stock_po.cost * stock_po.stock_in.to_i
          obj[:issued_quantity] = stock_ris.stock_in.to_i
          obj[:unit_out] = stock_ris.item_masterlist.unit.abbrev
          obj[:unit_cost_out] = stock_ris.cost
          obj[:total_cost_out] = stock_ris.cost * stock_ris.stock_in.to_i
          obj[:date_issued] = stock_ris.req_issued_slip.date_issued
          obj[:withdrawn_by] = stock_ris.req_issued_slip.withdrawn_by,
          obj[:risid] = stock_ris.req_issued_slip_id
          obj[:ris_number] = stock_ris.req_issued_slip.ris_number

          stock_content[:items] << obj
        end
      end
    end

    stock_content
  end


  def get_project_total_bal_cost(project)
    t_bal = 0
    t_cost = 0.0

    project.purchase_orders.each do |p|
      p.stocks.each do |s|
        t_bal += s.stock_in - s.stock_out
        t_cost += s.cost * s.stock_in
      end
    end

    { t_bal: t_bal, t_cost: t_cost }
  end


  def init_project
    @project = Project.new(
                department_id: get_department_id,
                project_in_charge_id: get_project_in_charge_id,
                pr_number: params[:pr_number],
                pow_number: params[:pow_number],
                purpose: params[:purpose]
               )
  end


  def validate_project
    render json: @project.errors.first, status: 301 if @project.invalid?
  end


  def autonumber_prs
    month_number = Time.now.month
    series = 1

    last_prs = Project.where('prs_number IS NOT NULL').sort.last
    if last_prs
      series = last_prs.prs_number.split('-')[0].to_i + 1
      unless last_prs.prs_number.split('-')[1].to_i == month_number
        series = 1
      end
    end

    year_number = Time.now.year - 2000

    "%04d-%02d-%02d" % [series,month_number,year_number]
  end

end
