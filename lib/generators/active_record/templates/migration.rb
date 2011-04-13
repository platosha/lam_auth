class Create<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    create_table(:<%= table_name %>) do |t|
      t.string :login, :null => false
      t.string :email, :null => false
      t.string :first_name
      t.string :last_name
      t.string :userpic
      t.text :profile
      t.timestamps
    end
    
    add_index :<%= table_name %>, :login
    add_index :<%= table_name %>, :email
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
