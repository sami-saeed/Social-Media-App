class AddPlatformNameToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :platform_name, :string
  end
end
