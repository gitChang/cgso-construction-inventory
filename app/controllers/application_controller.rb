class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :require_login
  skip_before_action :require_login, only: [:index, :user_access, :is_spectator]
  #before_action :is_spectator, only: [:create, :edit, :update]


  def index
    render layout: layout_name
  end


  # send authenticity_token and store to cookies
  # for post action on form submit.
  def user_access
    cookies[:xsrf_token] = form_authenticity_token
    render json: logged_in?
  end


  # prevent administrative function for limited users.
  def is_admin
    if admin_user = current_user.system_role.role.upcase == 'ADMINISTRATOR'
      render json: { access_granted: 'yes' }
      return
    end
    render json: { access_granted: 'nahh!' }
  end


  def is_spectator
    if current_user.system_role.role == 'SPECTATOR'
      render json: { spectator: true }
      return
    end
    render json: { spectator: false }
  end


  private

    def layout_name
      if params[:layout] == 0
          false
      else
          'application'
      end
    end


    #def spectator_user
    #  if current_user.system_role.role.downcase == "spectator"
    #    render json: [], status: 301
    #    return
    #  end
    #end


    def get_department_id(department_name=params[:department])
      return nil unless department_name.present?
      department = Department.where('name = ? OR abbrev = ?', "#{department_name}", "#{department_name}").first
      return department.id
    end


    def get_department_division_id(department_id)
      return nil unless Department.find(department_id).present?

      department = Department.find(department_id)
      division = department.department_divisions.where('division = ?', params[:department_division]).first

      return nil unless division.present?
      return division.id
    end


    def get_system_role_id(system_role=params[:system_role])
      return nil unless system_role.present?
      system_role = SystemRole.find_by_role(system_role)
      return system_role.id
    end


    def get_supply_id(kind=params[:supplies])
      return nil unless kind.present?
      supply = Supply.find_by_kind(kind)
      return supply.id
    end


    def get_units_id(unit=params[:unit])
      return nil unless unit.present?
      unit = Unit.find_by_abbrev(unit)
      return unit.id
    end


    def get_supplier_id(supplier_name=params[:supplier])
      return nil unless supplier_name.present?
      supplier = Supplier.find_by_name(supplier_name)
      return supplier.id
    end


    def get_mode_of_proc_id(mode=params[:mode_of_procurement])
      return nil unless mode.present?
      mode = ModeOfProcurement.find_by_mode(mode)
      return mode.id
    end


    def get_inspector_id(inspector_name=params[:inspector])
      return nil unless inspector_name.present?
      inspector = Inspector.find_by_name(inspector_name)
      return inspector.id
    end


    def get_warehouseman_id(warehouseman_name=params[:warehouseman])
      return nil unless warehouseman_name.present?
      warehouseman = Warehouseman.find_by_name(warehouseman_name.upcase)
      return warehouseman.present? ? warehouseman.id : nil
    end


    # get the record object and get field value.
    def get_record(pf_name_id, pf_index_id)
      record = nil
      case ProcurementForm.find(pf_name_id).short_name
      when 'po'
        record = PurchaseOrder.find(pf_index_id)
      when 'ris'
        record = ReqIssuedSlip.find(pf_index_id)
      end

      return record
    end


    def get_reference(pf_name_id, pf_index_id)
      reference = nil
      case ProcurementForm.find(pf_name_id).short_name
      when 'po'
        reference = "PO " << PurchaseOrder.find(pf_index_id).po_number
        puts ">>>>>>> #{PurchaseOrder.find(pf_index_id).po_number}"
      when 'ris'
        reference = "RIS " << ReqIssuedSlip.find(pf_index_id).ris_number
      end

      return reference
    end


    def get_reference_date(pf_name_id, pf_index_id)
      date_issued = nil
      case ProcurementForm.find(pf_name_id).short_name
      when 'po'
        date_issued = PurchaseOrder.find(pf_index_id).date_issued
      when 'ris'
        date_issued = ReqIssuedSlip.find(pf_index_id).date_issued
      end

      return date_issued
    end


    def get_reference_purpose(pr, pow)
      return PurchaseOrder.where('pr_number = ? OR pow_number = ?', pr, pow).first.purpose
    end


    def get_ris_withdrawn_by(pf_index_id)
      return ReqIssuedSlip.find(pf_index_id).withdrawn_by
    end


    def get_project_in_charge_id(in_charge=params[:in_charge])
      return nil unless in_charge.present?
      return ProjectInCharge.find_by_name(in_charge).id
    end
end
