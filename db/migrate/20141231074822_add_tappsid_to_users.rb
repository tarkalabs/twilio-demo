class AddTappsidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tappsid, :string
  end
end
