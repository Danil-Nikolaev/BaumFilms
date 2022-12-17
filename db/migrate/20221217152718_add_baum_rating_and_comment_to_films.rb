class AddBaumRatingAndCommentToFilms < ActiveRecord::Migration[7.0]
  def change
    add_column :films, :baum_rating, :integer
    add_column :films, :comment, :text
  end
end
