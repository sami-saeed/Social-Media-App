class AddPlatformLogoToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :platform_logo, :string
  end
end
