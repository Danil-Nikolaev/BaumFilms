class CreateFilms < ActiveRecord::Migration[7.0]
  def change
    create_table :films do |t|
      t.integer :filmID
      t.string :name
      t.text :genres
      t.integer :year
      t.integer :age_restriction
      t.string :country
      t.integer :rating_imdb
      t.integer :rating_imdb_count
      t.integer :rating_kp
      t.integer :rating_kp_count
      t.string :player
      t.string :budget
      t.text :description
      t.string :time
      t.string :big_poster
      t.string :small_poster
      t.string :trailer

      t.timestamps
    end
  end
end
