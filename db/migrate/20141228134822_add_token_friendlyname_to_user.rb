class AddTokenFriendlynameToUser < ActiveRecord::Migration
  def change
    rename_column :users, :sid, :tsid
    add_column :users, :tauthtoken, :string
    add_column :users, :tfriendlyname, :string
  end
end
