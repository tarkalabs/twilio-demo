class AddTactiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tactive, :boolean
  end
end
