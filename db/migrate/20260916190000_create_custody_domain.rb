class CreateCustodyDomain < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :cases do |t|
      t.string :code, null: false
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.datetime :opened_at, null: false
      t.datetime :closed_at

      t.timestamps
    end
    add_index :cases, :code, unique: true

    create_table :case_assignments do |t|
      t.references :case, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :case_assignments, %i[case_id user_id], unique: true

    create_table :evidence_types do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :evidence_types, :name, unique: true

    create_table :evidences do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.references :case, null: false, foreign_key: true
      t.references :evidence_type, null: false, foreign_key: true
      t.references :current_custodian, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.datetime :collected_at, null: false
      t.string :location

      t.timestamps
    end
    add_index :evidences, :code, unique: true

    create_table :custody_movements do |t|
      t.references :evidence, null: false, foreign_key: true
      t.references :from_user, foreign_key: { to_table: :users }
      t.references :to_user, null: false, foreign_key: { to_table: :users }
      t.references :performed_by, null: false, foreign_key: { to_table: :users }
      t.datetime :transferred_at, null: false
      t.string :reason, null: false
      t.text :notes

      t.timestamps
    end
    add_index :custody_movements, %i[evidence_id transferred_at]
  end
end
