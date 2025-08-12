class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :mentioned_user, null: false, foreign_key: { to_table: :users }
      t.references :mentioner, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    # composite unique index prevents duplicate mentions for same (user, comment)
    add_index :mentions, [ :mentioned_user_id, :comment_id ], unique: true, name: "index_mentions_on_user_and_comment"
  end
end
