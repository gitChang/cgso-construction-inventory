class ChangeLogsController < ApplicationController

  before_action :is_admin_for_callback, only: :create


  def create
    doc = nil
    log = nil
    if params[:doc] == 'PO'
      doc = PurchaseOrder.where(po_number: params[:doc_number]).first
      if doc
        log = UserActionsLog.new(purchase_order: doc, action: params[:message],
                                 genkey: generate_edit_key, admin_id: current_user.id)
        vacant_key = doc.user_actions_log.where('assigned = ? AND genkey IS NOT NULL', false).first
        if vacant_key
          render json: ['notif', "Admin - #{current_user.name } has already generated an edit key for PO #{doc.po_number}."], status: 301
          return
        end
      else
        render json: {}
        return
      end
    end
    if params[:doc] == 'RIS'
      doc = ReqIssuedSlip.where(ris_number: params[:doc_number]).first
      if doc
        log = UserActionsLog.new(req_issued_slip: doc, action: params[:message],
                                 genkey: generate_edit_key, admin_id: current_user.id)
        vacant_key = doc.user_actions_log.where('assigned = ? AND genkey IS NOT NULL', false).first
        if vacant_key
          render json: ['notif', "Admin - #{current_user.name} has already generated an edit key for RIS #{doc.ris_number}."], status: 301
          return
        end
      else
        render json: {}
        return
      end
    end
    if log.save
      render json: { edit_key: log.genkey }
      return
    end
    render json: false
  end


  def is_admin_for_callback
    unless admin_user = current_user.system_role.role.upcase == 'ADMINISTRATOR'
      render json: {}, status: 301
      return
    end
  end


  def get_logs
    log_collection = nil
    logs = []

    if params[:poid]
      log_collection = UserActionsLog.where('purchase_order_id = ? AND user_id IS NOT NULL', params[:poid]).order(created_at: :desc)
    else
      log_collection = UserActionsLog.where('req_issued_slip_id = ? AND user_id IS NOT NULL', params[:risid]).order(created_at: :desc)
    end

    log_collection.each do |l|
      logs << {
        date_changed: l.created_at.to_formatted_s(:long),
        action: l.action,
        user: l.user.name.downcase
      }
    end
    render json: logs
  end


  private


  def generate_edit_key
    if current_user.system_role.role.upcase == 'ADMINISTRATOR'
      ekey = ('a'..'z').to_a.shuffle[0,8].join
      return ekey
    end
    return
  end
end
