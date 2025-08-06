class RenameContextToContentInPosts < ActiveRecord::Migration[7.2]
  def change
    rename_column :posts, :context, :content
  end
end
