class AddUserToHomes < ActiveRecord::Migration[7.2]
  def change
    add_reference :homes, :user, null: false, foreign_key: true
  end
end
