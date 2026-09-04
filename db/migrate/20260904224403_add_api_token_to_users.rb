class AddApiTokenToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true

    # An account made before there was a token gets one now; has_secure_token
    # only issues them on create.
    User.reset_column_information
    User.where(api_token: nil).find_each(&:regenerate_api_token)
  end

  def down
    remove_index :users, :api_token
    remove_column :users, :api_token
  end
end
