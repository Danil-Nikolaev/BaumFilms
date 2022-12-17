# frozen_string_literal: true

require 'json'
require 'open-uri'

class FilmsController < ApplicationController
  def index
    check_params
    convert_params_string_into_array

    find_all_filters
    create_film_before_order

    find_film_with_filter
    convert_array_into_relation

    @films = @films_before_order.order(rating_kp: :desc).limit(48).offset(48 * (@current_page - 1))

    respond_to do |format|
      format.html
      format.json do
        render json: set_json_result
      end
    end
  end

  def film
    @film = Film.find(params[:id].to_i)
  end

  def find_film_with_filter
    find_film_by_genres unless @filters_genres.empty?
    find_film_by_years unless @filters_years.empty?
    find_film_by_countries unless @filters_countries.empty?
  end

  def create_film_before_order
    if @filters_years.empty? && @filters_countries.empty? && @filters_genres.empty?
      find_films_when_no_filters
    else
      @films_before_order = []
    end
  end

  def convert_array_into_relation
    @films_before_order = Film.where(id: @films_before_order.map(&:id))
  end

  def convert_params_string_into_array
    @filters_genres = @filters_genres.split(',')
    @filters_countries = @filters_countries.split(',')
    @filters_years = @filters_years.split(',')
  end

  def check_params
    @current_page = params[:current_page].nil? ? 1 : params[:current_page].to_i
    @filters_genres = params[:filters_genres].nil? ? '' : params[:filters_genres]
    @filters_countries = params[:filters_countries].nil? ? '' : params[:filters_countries]
    @filters_years = params[:filters_years].nil? ? '' : params[:filters_years]
  end

  def find_films_when_no_filters
    @films_before_order = Film.all
  end

  def find_all_filters
    @year_list = Film.select(:year).distinct.order(year: :desc)
    set_genres_list
    set_country_list
  end

  def find_film_by_genres
    @filters_genres.each do |genre|
      films_filter_genres = Film.where('genres like ?', "%#{genre}%")
      films_filter_genres.each { |film| @films_before_order.push(film) }
    end
  end

  def find_film_by_countries
    @filters_countries.each do |country|
      films_filter_country = Film.where('country like ?', "%#{country}%")
      films_filter_country.each { |film| @films_before_order.push(film) }
    end
  end

  def find_film_by_years
    @filters_years = @filters_years.map(&:to_i)
    @filters_years.each do |year|
      films_filter_year = Film.where('year = ?', year)
      films_filter_year.each { |film| @films_before_order.push(film) }
    end
  end

  def set_json_result
    result_hash = {}
    index = 0
    @films.each do |film|
      result_hash[index] = { filmID: film.filmID,
                             name: film.name,
                             genres: ActiveSupport::JSON.decode(film.genres),
                             year: film.year,
                             age_restriction: film.age_restriction,
                             country: ActiveSupport::JSON.decode(film.country),
                             rating_imdb: film.rating_imdb,
                             rating_imdb_count: film.rating_imdb_count,
                             rating_kp: film.rating_kp,
                             rating_kp_count: film.rating_kp_count,
                             player: film.player,
                             budget: film.budget,
                             description: film.description,
                             time: film.time,
                             big_poster: film.big_poster,
                             small_poster: film.small_poster,
                             trailer: film.trailer,
                            id: film.id }
      index += 1
    end
    result_hash
  end

  def set_country_list
    @country_list = []
    Film.select(:country).distinct.each do |film|
      ActiveSupport::JSON.decode(film.country).each do |country|
        country = { 'name_ru' => 'Страна не указана' } if country.is_a? Array
        @country_list.push(country['name_ru']) unless @country_list.include? country['name_ru']
      end
    end
  end

  def set_genres_list
    @genres_list = []
    Film.select(:genres).distinct.each do |film|
      ActiveSupport::JSON.decode(film.genres).each do |genre|
        genre = { 'name_ru' => 'Жанры не указаны' } if genre.is_a?(Array)
        @genres_list.push(genre['name_ru']) unless @genres_list.include? genre['name_ru']
      end
    end
  end

  def generate_db
    current_page = 1
    id = 1
    json_response = JSON.parse(URI.open("https://kinobd.ru/api/films?page=#{current_page}").read)
    until json_response['next_page_url'].nil?
      (0...json_response['data'].length).each do |index|
        set_variable_model(id, index)
        id += 1
      end
      current_page += 1
      json_response = JSON.parse(URI.open("https://kinobd.ru/api/films?page=#{current_page}").read)
    end
  end

  def set_variable_model(id, index)
    @film_id = id
    data = json_response['data'][index]
    @name = data['name_russian'].nil? ? ' ' : data['name_russian']
    @genres = data['genres'].empty? ? ActiveSupport::JSON.encode(name_ru: ' ') : ActiveSupport::JSON.encode(data['genres'])
    @year = data['year'].nil? ? 0 : data['year'].to_i
    @age_restriction = data['age_restriction'].nil? ? 0 : data['age_restriction'].to_i
    @country = data['countries'].empty? ? ActiveSupport::JSON.encode([{ name_ru: ' ' }]) : ActiveSupport::JSON.encode(data['countries'])
    @rating_imdb = data['rating_imdb'].nil? ? 0 : data['rating_imdb']
    @rating_imdb_count = data['rating_imdb_count'].nil? ? 0 : data['rating_imdb_count']
    @rating_kp = data['rating_kp'].nil? ? 0 : data['rating_kp']
    @rating_kp_count = data['rating_kp_count'].nil? ? 0 : data['rating_kp_count']
    @player = data['player'].nil? ? ' ' : data['player']
    @budget = data['budget'].nil? ? ' ' : data['budget']
    @description = data['description'].nil? ? ' ' : data['description']
    @time = data['time'].nil? ? ' ' : data['time']
    @big_poster = data['big_poster'].nil? ? ' ' : data['big_poster']
    @small_poster = data['small_poster'].nil? ? ' ' : data['small_poster']
    @trailer = data['trailer'].nil? ? ' ' : data['trailer']
  end

  def record_model
    Film.create(
      filmID: @film_id,
      name: @name,
      genres: @genres,
      year: @year,
      age_restriction: @age_restriction,
      country: @country,
      rating_imdb: @rating_imdb,
      rating_imdb_count: @rating_imdb_count,
      rating_kp: @rating_kp,
      rating_kp_count: @rating_kp_count,
      player: @player,
      budget: @budget,
      description: @description,
      time: @time,
      big_poster: @big_poster,
      small_poster: @small_poster,
      trailer: @trailer
    ).save
  end
end
