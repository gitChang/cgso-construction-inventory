class PurchaseOrder < ActiveRecord::Base

  belongs_to :project
  belongs_to :supplier
  belongs_to :mode_of_procurement
  belongs_to :inspector
  belongs_to :endorsement_po
  has_many :stocks
  has_many :user_actions_log

  attr_accessor :pr_number, :pow_number, :po_items, :user_id, :genkey


  NUMBER_REGEX   = /\A[0-9_-]+\z/
  ALPHA_REGEX = /\A[a-zA-Z -]+\z/


  before_save :uppercase_remarks
  after_create :log_action
  after_update :mark_key_assigned


  #validates :genkey,
  #  presence: { message: 'Please provide the Generated Key to apply update.' }, on: :update

  #validate :genkey_inused, on: :update

  #validate :genkey_valid, on: :update

  validate :valid_date_issued

  validates :pr_number,
    presence: { message: 'Please provide the PR number.' },
    format:   { with: NUMBER_REGEX, message: 'PR number only allows numbers and dashes (-).' }

  # validates :pow_number, presence: true
    # format:   { with: NUMBER_REGEX, message: 'POW number only allows numbers and dashes (-).' },
             # if: -> { pow_number.present? }

  validates :project,
    presence: { message: 'Unable to find the Project / Purchase Request.' }

  validates :po_number,
    presence: { message: 'Please provide the PO number.' },
    #format:   { with: NUMBER_REGEX, message: 'PO number only allows numbers and dashes (-).' },
    uniqueness: { case_sensitive: false, message: 'Duplicate PO number found.', on: :create }

  #validates :remarks,
  #  presence: { message: '' }

  validates :iar_number,
    presence: { message: 'Please provide the IAR number.' }
    #format:   { with: NUMBER_REGEX, message: 'IAR number only allows numbers and dashes (-).' }
    # uniqueness: { case_sensitive: false, message: 'Duplicate IAR number found.', on: :create }

  validate :valid_date_of_delivery

  validates :complete,
      inclusion:  { in: [true, false], message: 'Invalid value for delivery status.' }

  validates :inspector_id,
      presence:   { message: 'Please provide the Inspector name.' },
      inclusion: { in: :inspector_ids, message: 'The selected Inspector name is invalid.' }

  validates :supplier_id,
      presence:   { message: 'Please provide the Supplier name.' },
      inclusion: { in: :supplier_ids, message: 'The selected Supplier name is invalid.' }

  validates :mode_of_procurement_id,
      presence:   { message: 'Please provide the Mode of Procurement.' },
      inclusion: { in: :mode_of_procurement_ids , message: 'The selected Mode of Procurement is invalid.' }

  validate :count_of_po_items

  #validate :completed_project


  private

  def valid_date_issued
    valid = Date.strptime(date_issued.to_s, '%Y-%m-%d') rescue false
    errors.add(:date_issued, 'Date entered is invalid.') unless valid
  end


  def valid_date_of_delivery
    valid = Date.strptime(date_of_delivery.to_s, '%Y-%m-%d') rescue false
    errors.add(:date_of_delivery, 'Date of delivery is invalid.') unless valid
  end


  def pr_or_pow_number_presence
    errors.add(:pr_number, 'Please provide the PR or POW Number.') unless pr_number.present? && pow_number.present?
  end


  def count_of_po_items
    errors.add(:po_items, 'Please provide the PO items.') unless po_items.present?
  end


  def inspector_ids
    Inspector.all.collect {|i| i.id }
  end


  def supplier_ids
    Supplier.all.collect {|s| s.id }
  end


  def mode_of_procurement_ids
    ModeOfProcurement.all.collect {|m| m.id }
  end


  def uppercase_remarks
    self.remarks = remarks.upcase
  end


  def completed_project
    if project
      query_project = Project.where(id: project.id).first
      errors.add(:project, 'Project is already completed. Check PR/POW Number.') if query_project.prs_number.present?
    end
  end


  def log_action
    UserActionsLog.create(user_id: user_id, purchase_order_id: id, action: "encoded po number #{po_number}.")
  end


  def mark_key_assigned
    UserActionsLog.where(genkey: genkey).first.update(user_id: user_id, assigned: true)
  end


  def genkey_inused
    # check if genkey is already in used.
    inused_key = UserActionsLog.where('genkey = ? AND assigned = ?', genkey, true).first
    errors.add(:genkey, 'Invalid entered Key for update. (Dup)') if inused_key
  end


  def genkey_valid
    valid_key = UserActionsLog.where('genkey = ? AND assigned = ?', genkey, false).first
    errors.add(:genkey, 'Invalid entered Key for update.') unless valid_key
  end

end
