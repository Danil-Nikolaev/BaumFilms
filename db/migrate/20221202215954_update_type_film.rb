class UpdateTypeFilm < ActiveRecord::Migration[7.0]
  def change
    change_table :films do |t|
      t.change :country, :text
    end
  end
end
