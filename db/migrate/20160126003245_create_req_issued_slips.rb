class CreateReqIssuedSlips < ActiveRecord::Migration
  def change
    create_table :req_issued_slips do |t|

      t.string :ris_number, index: true, unique: true, null: false
      t.boolean :savings, index: true, default: false
      t.date :date_issued

      t.references :project, index: true
      #t.references :department, index: true, foreign_key: true
      #t.references :department_division, index: true, foreign_key: true
      t.references :warehouseman, index: true, foreign_key: true

      t.date :date_released

      t.string :approved_by, index: true
      t.string :issued_by, index: true
      t.string :withdrawn_by, index: true, default: ''

      t.timestamps null: false
    end
  end
end

