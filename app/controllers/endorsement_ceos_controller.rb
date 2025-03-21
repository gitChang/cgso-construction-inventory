class EndorsementCeosController < ApplicationController

  def index
    endorsed_pos = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:po_number]
      query_results = PurchaseOrder.order(:po_number).where('endorsement_po_id IS NOT NULL AND po_number LIKE ?', "%#{params[:po_number]}%")
    else
      # DEFAULT COLLECTION
      query_results = PurchaseOrder.where('endorsement_po_id IS NOT NULL').order(po_number: :desc)
    end

    unless query_results
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, endorsed_pos: [] }
      return
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    endorsed_pos = query_results.collect do |p|
                          {
                            endo_po_id: p.endorsement_po_id,
                            control_number: p.endorsement_po.control_number,
                            po_number: p.po_number,
                            purpose: p.project.purpose
                          }
                        end
    render json: Paginator.pagination_attributes(query_results).merge!(endorsed_pos: endorsed_pos)
  end


  def show
    endo_po = EndorsementPo.find(params[:id])
    pos_coll = []

    endo_po.purchase_orders.collect do |p|
      pos_coll << {
        po_number: p[:po_number],
        reference: p.project.pow_number.present? ? p.project.pow_number : p.project.pr_number,
        total_cost: get_po_total_cost(p)
      }
    end

    endo_po_hash = {
      date_endorsed: endo_po.updated_at,
      pos: pos_coll,
      recipient: { name: endo_po.recipient, designation: endo_po.recipient_designation },
      thru: { name: endo_po.thru, designation: endo_po.thru_designation },
      sender: { name: endo_po.sender, designation: endo_po.sender_designation },
      cc: endo_po.cc,
      active_user: current_user.name,
      control_number: "<b>Control No.: #{endo_po.control_number}</b>"
    }

    render json: endo_po_hash, status: 200 if endo_po.present?
  end


  def create
    control_number_val = "%02d-%02d-%04d" % "#{Time.now.year - 2000}-#{Time.now.month}-#{EndorsementPo.count + 1}".split("-")

    endo_po = EndorsementPo.new(
            control_number: control_number_val,
            recipient: params[:letter][:recipient][:name].upcase,
            recipient_designation: params[:letter][:recipient][:designation],
            thru: params[:letter][:thru][:name].upcase,
            thru_designation: params[:letter][:thru][:designation],
            sender: params[:letter][:sender][:name].upcase,
            sender_designation: params[:letter][:sender][:designation],
            cc: params[:letter][:cc],
            user_id: current_user.id
          )

    if endo_po.save
      params[:letter][:pos].each do |p|
        po = PurchaseOrder.where("po_number = ?", p.last[:po_number]).first if p.last[:selected].to_b
        po.update_column(:endorsement_po_id, endo_po.id) if po.present?
      end
    end
    render json: { endo_po_id: endo_po.id }, status: 200
  end


  def update
    endo_po = EndorsementPo.find(params[:id])

    endo_po.recipient = params[:letter][:recipient][:name].upcase
    endo_po.recipient_designation = params[:letter][:recipient][:designation]
    endo_po.thru = params[:letter][:thru][:name].upcase
    endo_po.thru_designation = params[:letter][:thru][:designation]
    endo_po.sender = params[:letter][:sender][:name].upcase
    endo_po.sender_designation = params[:letter][:sender][:designation]
    endo_po.cc = params[:letter][:cc]
    endo_po.user_id = current_user.id
    endo_po.save

    render json: { endo_po_id: endo_po.id }, status: 200
  end


  def unendorse_po
    po = PurchaseOrder.find_by_po_number(params[:po_number])
    po = po.update_column(:endorsement_po_id, nil)
    render json: {}, status: 200 if po
  end


  def endorse_po
    po = PurchaseOrder.find_by_po_number(params[:po_number])
    po = po.update_column(:endorsement_po_id, params[:endopoid])
    render json: {}, status: 200 if po
  end


  def download_pdf
    #endo_po = EndorsementPo.find(params[:id])
    #pos_coll = []

    #endo_po.purchase_orders.collect do |p|
    #  pos_coll << {
    #    po_number: p[:po_number],
    #    pow_number: p.project.pow_number.present? ? p.project.pow_number : p.project.pr_number,
    #    supplier: p.supplier.name,
    #    total_cost: get_po_total_cost(p)
    #  }
    #end

    #endo_po_hash = {
    #  date_endorsed: endo_po.updated_at,
    #  pos: pos_coll,
    #  recipient: { name: endo_po.recipient, designation: endo_po.recipient_designation },
    #  thru: { name: endo_po.thru, designation: endo_po.thru_designation },
    #  sender: { name: endo_po.sender, designation: endo_po.sender_designation },
    #  cc: endo_po.cc,
    #  active_user: current_user.name,
    # control_number: "Control No. #{endo_po.control_number}"
    #}

    #pdf = EndorsementPoReportPdf.new(endo_po_hash)
    #File.delete('public/endorsement_po.pdf')
    #pdf_new = File.new('public/endorsement_po.pdf', 'wb')
    #pdf.render_file File.join(Rails.root, "public", "endorsement_po.pdf")

    #render json: {}, status: 200 if endo_po.present?
    pdf = EndorsementCeoReportPdf.new({})
    #send_data pdf.render, type: 'application/pdf', disposition: 'attachment', filename: "cgso-stock-card-report.pdf"
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end



  def get_project_pos
    param_pow = ["#{params[:pow_number]}"] * 2
    proj = Project.where("pow_number = ? OR pr_number = ?", *param_pow).first
    pos = []

    unless proj
      render json: pos
      return
    end

    proj.purchase_orders.order(:po_number).each do |po|
      pos << {
        po_number: po.po_number,
        reference: po.project.pow_number.present? ? po.project.pow_number : po.project.pr_number,
        total_cost: get_po_total_cost(po),
        selected: false
      }
    end

    render json: pos
  end


  private

    def get_po_total_cost(po)
      t_cost = 0.0
      po.stocks.each do |s|
        t_cost += s.cost * s.stock_in
      end
      t_cost
    end

end
