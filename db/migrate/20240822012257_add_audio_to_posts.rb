class AddAudioToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :audio, :string
  end
end
