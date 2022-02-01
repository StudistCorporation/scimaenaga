class AddDeletableToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deletable, :boolean
  end
end
