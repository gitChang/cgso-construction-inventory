class EndorsementsController < ApplicationController

  def index
    endorsed_projects = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:key]
      # WHEN SEARCHING FOR PR_NUMBER
      if params[:key].downcase == 'pr'
        query_results = Project.order(:pr_number).where('endorsement_id IS NOT NULL AND pr_number LIKE ?', "%#{params[:val]}%")
      end

      # WHEN SEARCHING FOR POW_NUMBER
      if params[:key].downcase == 'pow'
        query_results = Project.order(:pow_number).where('endorsement_id IS NOT NULL AND pow_number LIKE ?', "%#{params[:val]}%")
      end

      # WHEN SEARCHING FOR CONTROL NUMBER
      if params[:key].downcase == 'ctl'
        endo = Endorsement.where(control_number: params[:val].strip).first
        query_results = endo.projects if endo
      end

    else
      # DEFAULT COLLECTION
      query_results = Project.where('endorsement_id IS NOT NULL').order(created_at: :desc)
    end

    unless query_results
      render json: { total_entries: 0, from_index: 0, to_index: 0, current_page: 1, endorsed_projects: [] }
      return
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    endorsed_projects = query_results.collect do |p|
                          {
                            endoid: p.endorsement_id,
                            control_number: p.endorsement.control_number,
                            pr_number: p.pr_number,
                            pow_number: p.pow_number,
                            purpose: p.purpose
                          }
                        end
    render json: Paginator.pagination_attributes(query_results).merge!(endorsed_projects: endorsed_projects)
  end


  def create
    control_number_val = "%02d-%02d-%04d" % "#{Time.now.year - 2000}-#{Time.now.month}-#{Endorsement.count + 1}".split("-")

    endo = Endorsement.new(
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

    if endo.save
      params[:letter][:projects].each do |p|
        project = Project.where("pow_number = ? OR pr_number = ?", p.last[:pow_number], p.last[:pow_number]).first
        project.update_column(:endorsement_id, endo.id) if project.present?
      end
    end
    render json: { endoid: endo.id }, status: 200
  end


  def show
    endo = Endorsement.find(params[:id])
    projects_coll = []

    endo.projects.collect do |p|
      if p[:pow_number].present?
        projects_coll << { pow_number: p[:pow_number], purpose: p[:purpose], total_cost: get_project_total_bal_cost(p)[:t_cost] }
      else
        projects_coll << { pow_number: p[:pr_number], purpose: p[:purpose], total_cost: get_project_total_bal_cost(p)[:t_cost] }
      end
    end

    endo_hash = {
      projects: projects_coll,
      recipient: { name: endo.recipient, designation: endo.recipient_designation },
      thru: { name: endo.thru, designation: endo.thru_designation },
      sender: { name: endo.sender, designation: endo.sender_designation },
      cc: endo.cc,
      active_user: current_user.name
    }

    render json: endo_hash, status: 200 if endo.present?
  end


  def update
    endo = Endorsement.find(params[:id])

    endo.recipient = params[:letter][:recipient][:name].upcase
    endo.recipient_designation = params[:letter][:recipient][:designation]
    endo.thru = params[:letter][:thru][:name].upcase
    endo.thru_designation = params[:letter][:thru][:designation]
    endo.sender = params[:letter][:sender][:name].upcase
    endo.sender_designation = params[:letter][:sender][:designation]
    endo.cc = params[:letter][:cc]
    endo.user_id = current_user.id

    if endo.save
      params[:letter][:projects].each do |p|
        project = Project.where("pow_number = ? OR pr_number = ?", p.last[:pow_number], p.last[:pow_number]).first
        project.update_column(:endorsement_id, endo.id) if project.present?
      end
    end

    render json: { endoid: endo.id }, status: 200
  end


  def download_pdf
    endo = Endorsement.find(params[:id])
    projects_coll = []

    endo.projects.collect do |p|
      if p[:pow_number].present?
        projects_coll << { pow_number: p[:pow_number], purpose: p[:purpose], total_cost: get_project_total_bal_cost(p)[:t_cost] }
      else
        projects_coll << { pow_number: p[:pr_number], purpose: p[:purpose], total_cost: get_project_total_bal_cost(p)[:t_cost] }
      end
    end

    endo_hash = {
      date_endorsed: endo.updated_at,
      projects: projects_coll,
      recipient: { name: endo.recipient, designation: endo.recipient_designation },
      thru: { name: endo.thru, designation: endo.thru_designation },
      sender: { name: endo.sender, designation: endo.sender_designation },
      cc: endo.cc,
      active_user: current_user.name,
      control_number: "<b>Control No.: #{endo.control_number}</b>"
    }

    pdf = EndorsementReportPdf.new(endo_hash)
    File.delete('public/endorsement.pdf')
    pdf_new = File.new('public/endorsement.pdf', 'wb')
    pdf.render_file File.join(Rails.root, "public", "endorsement.pdf")

    render json: {}, status: 200 if endo.present?
  end


  def is_endorsed
    pow = Project.where("pow_number = ? AND endorsement_id IS NOT NULL", params[:pow_number].strip).first
    if pow
      render json: true, status: 301
      return
    end
    render json: false, status: 200
  end


  def get_pow_data
    pow = Project.where("pow_number = ? OR pr_number = ?", params[:pow_number], params[:pow_number]).first

    unless pow.present?
      render json: {}, status: 301
      return
    end

    pow_data = {
      pow_number: pow.pow_number.present? ? pow.pow_number : pow.pr_number,
      purpose: pow.purpose,
      total_cost: get_project_total_bal_cost(pow)[:t_cost]
    }

    render json: pow_data
  end


  def remove_project
    pow = Project.where("pow_number = ? OR pr_number = ?", params[:pow_number], params[:pow_number]).first
    if pow
      pow.update_column(:endorsement_id, nil)
      render json: {}, status: 200
      return
    end
    render json: {}, status: 301
  end


  private

    def get_project_total_bal_cost(project)
      t_bal = 0
      t_cost = 0.0

      project.purchase_orders.each do |p|
        p.stocks.each do |s|
          t_bal += s.stock_in.to_i - s.stock_out.to_i
          t_cost += s.cost * s.stock_in.to_i
        end
      end

      { t_bal: t_bal, t_cost: t_cost }
    end

end
