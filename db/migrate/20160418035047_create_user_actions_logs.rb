class CreateUserActionsLogs < ActiveRecord::Migration
  def up
    create_table :user_actions_logs do |t|
      t.references :user, foreign_key: true, index: true, null: true
      t.references :purchase_order, foreign_key: true, index: true
      t.references :req_issued_slip, foreign_key: true, index: true
      t.text :action
      t.string :genkey
      t.boolean :assigned, default: false, index: true
      t.integer :admin_id, references: 'user', index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :user_actions_logs
  end
end
