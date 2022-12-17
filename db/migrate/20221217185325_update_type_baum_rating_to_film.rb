class UpdateTypeBaumRatingToFilm < ActiveRecord::Migration[7.0]
  def change
    change_table :films do |t|
      t.change :baum_rating, :text
    end
  end
end
