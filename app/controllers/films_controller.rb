require 'json'
require 'open-uri'

class FilmsController < ApplicationController
  def index
     generate_db
     @genres_list = Film.select(:genres).distinct
     @year_list = Film.select(:year).distinct.order(year: :desc)
     @country_list = Film.select(:country).distinct
     current_page = params[:current_page].nil? ? 1 : params[:current_page].to_i
     @films = Film.where('filmID > ?', 50 * (current_page - 1)).and(Film.where('filmID <= ?', 50 * (current_page - 1) + 50))
  end

  def film; end

  def generate_db
    current_page = 1
    id = 1
    json_response = JSON.parse(URI.open("https://kinobd.ru/api/films?page=#{current_page}").read)
    while !(json_response['next_page_url'].nil?)
      (0...json_response['data'].length).each do | index |
        film_id = id
        data = json_response['data'][index]
        name = data['name_russian'].nil? ? ' ' : data['name_russian']
        genres = data['genres'].nil? ? ActiveSupport::JSON.encode(name_ru: ' ') : ActiveSupport::JSON.encode(data['genres'][0])
        year = data['year'].nil? ? 0 : data['year'].to_i
        age_restriction = data['age_restriction'].nil? ? 0 : data['age_restriction'].to_i
        country = data['countries'][0]['name_ru'].nil? ? ' ' : data['countries'][0]['name_ru']
        rating_imdb = data['rating_imdb'].nil? ? 0 : data['rating_imdb']
        rating_imdb_count = data['rating_imdb_count'].nil? ? 0 : data['rating_imdb_count']
        rating_kp = data['rating_kp'].nil? ? 0 : data['rating_kp']
        rating_kp_count = data['rating_kp_count'].nil? ? 0 : data['rating_kp_count']
        player = data['player'].nil? ? ' ' : data['player']
        budget = data['budget'].nil? ? ' ' : data['budget']
        description = data['description'].nil? ? ' ' : data['description']
        time = data['time'].nil? ? ' ' : data['time']
        big_poster = data['big_poster'].nil? ? ' ' : data['big_poster']
        small_poster = data['small_poster'].nil? ? ' ' : data['small_poster']
        trailer = data['trailer'].nil? ? ' ' : data['trailer']
        Film.create(
          filmID: film_id,
          name: name,
          genres: genres,
          year: year,
          age_restriction: age_restriction,
          country: country,
          rating_imdb: rating_imdb,
          rating_imdb_count: rating_imdb_count,
          rating_kp: rating_kp,
          rating_kp_count: rating_kp_count,
          player: player,
          budget: budget,
          description: description,
          time: time,
          big_poster: big_poster,
          small_poster: small_poster,
          trailer: trailer
        ).save
        id += 1
      end
      current_page += 1
      json_response = JSON.parse(URI.open("https://kinobd.ru/api/films?page=#{current_page}").read)
    end
  end
end
