class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :role, default: 2 #0:admin, 1:user, 2:guest
      t.string :password_digest
      t.string :auth_token, default: ""
      t.boolean :disabled, default: false

      t.timestamps
      
      t.index :auth_token, unique: true
      t.index :email, unique: true
    end
  end
end
