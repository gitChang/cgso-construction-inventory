class ReqIssuedSlip < ActiveRecord::Base

  belongs_to :project
  belongs_to :warehouseman
  has_many :stocks
  has_many :user_actions_log


  attr_accessor :pr_number, :pow_number, :ris_items, :user_id, :genkey


  NUMBER_REGEX   = /\A[0-9_-]+\z/
  ALPHA_REGEX = /\A[a-zA-Z -.']+\z/


  before_validation :autonumber, on: :create
  before_save :uppercase_names
  after_create :log_action
  after_update :mark_key_assigned


  #validates :savings,
  #    inclusion:  { in: [true, false], message: 'Invalid value for delivery status.' }

  #validates :genkey,
  #  presence: { message: 'Please provide the Generated Key to apply update.' }, on: :update

  #validate :genkey_inused, on: :update

  #validate :genkey_valid, on: :update

  validate :valid_date_issued

  validates :ris_number,
    uniqueness: { case_sensitive: false, message: 'Duplicate RIS number found.', on: :create }

  validates :pr_number,
    presence:   { message: 'Please provide the PR number.' },
    format:   { with: NUMBER_REGEX, message: 'PR number only allows numbers and dashes (-).' }

  #validates :pow_number, presence: true
    # format:   { with: NUMBER_REGEX, message: 'POW number only allows numbers and dashes (-).' },
             #  if: -> { pow_number.present? }

  #validates :department_id,
  #    presence:   { message: 'Please provide department name.' },
  #    inclusion: { in: :department_ids, message: 'Invalid department name selected.' }

  #validates :department_division_id,
  #  presence: { message: 'Please specify Department Division.' },
  #  inclusion: { in: :department_division_ids, message: 'Invalid Department Division selected.' }

  validates :warehouseman_id,
    presence: { message: 'Please specify the Releasing In-charge.' },
    inclusion: { in: :warehouseman_ids, message: 'The Warehouseman selected is invalid.' }

  validate :valid_date_released

  validate :count_of_ris_items

  validates :approved_by,
    presence: { message: 'Please provide the name of the Approver.' }

  validates :issued_by,
    presence: { message: 'Please provide the name of the Issuer.' },
    format:   { with: ALPHA_REGEX, message: 'Invalid characters found in Issuer\'s name.' }

  validates :withdrawn_by,
    presence: { message: 'Please provide the name of who withdrawn the supplies.' }


  private

  def autonumber
    month_number = "%02d" % date_issued.to_datetime.month # Time.now.month
    year_number = "%02d" % (date_issued.to_datetime.year - 2000) # Time.now.year
    que_param_month = "'#{month_number}-%'"
    que_param_year = "'%-#{year_number}'"
    clause = "ris_number LIKE #{que_param_month} AND ris_number LIKE #{que_param_year}"
    series = 1
    new_ris_series = "#{month_number.to_i}-#{series}-#{year_number.to_i}"
    ris_len = ReqIssuedSlip.all.size

    if ris_len > 0
      rises = ReqIssuedSlip.where(clause).collect {|r| r.ris_number }.sort
      if rises.size > 0
        last_series_month = rises.last
        new_ris_series = "#{last_series_month.split('-').first.to_i}-#{last_series_month.split('-').second.to_i + 1}-#{last_series_month.split('-').last.to_i}"
      end
    end

    self.ris_number = "%02d-%04d-%02d" % new_ris_series.split('-')
  end


  def valid_date_issued
    valid = Date.strptime(date_issued.to_s, '%Y-%m-%d') rescue false
    errors.add(:date_issued, 'Date entered is invalid.') unless valid
  end


  def valid_date_released
    valid = Date.strptime(date_released.to_s, '%Y-%m-%d') rescue false
    errors.add(:date_released, 'Date Released entered is invalid.') unless valid
  end


  def count_of_ris_items
    unless savings
      errors.add(:ris_items, 'Please provide the RIS items.') unless ris_items.present?
    end
  end


  def uppercase_names
    self.approved_by = approved_by.upcase
    self.issued_by = issued_by.upcase
    self.withdrawn_by = withdrawn_by.upcase
  end


  def department_ids
    Department.all.collect {|d| d.id }
  end


  def department_division_ids
    DepartmentDivision.all.collect {|dv| dv.id }
  end


  def warehouseman_ids
    Warehouseman.all.collect { |w| w.id }
  end


  def log_action
    UserActionsLog.create(user_id: user_id, req_issued_slip_id: id, action: "encoded ris number #{ris_number}.")
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
