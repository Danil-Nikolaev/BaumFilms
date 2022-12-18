# frozen_string_literal: true

require 'json'
require 'open-uri'

# Class-controller
class FilmsController < ApplicationController
  before_action :check_params, only: :index
  before_action :convert_params_string_into_array, only: :index

  def index
    @films_before_order = Film.all
    find_film_with_filter
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
    @prev_url = request.referrer
  end

  def add_comment_to_films
    return if params[:comment].empty?

    film = Film.find(params[:id].to_i)
    if film.comment.nil?
      comment_hash = ActiveSupport::JSON.encode(result_comment: [{ email: current_user.email,
                                                                   comment: params[:comment] }])
    else
      comment_hash = ActiveSupport::JSON.decode(film.comment)
      comment_hash['result_comment'].unshift({ email: current_user.email, comment: params[:comment] })
      comment_hash = ActiveSupport::JSON.encode(comment_hash)
    end
    film.update(comment: comment_hash)
    redirect_to action: 'film', id: params[:id]
  end

  def add_rating
    film = Film.find(params[:id].to_i)
    if film.baum_rating.nil?
      rating_hash = ActiveSupport::JSON.encode({ rating: params[:rating].to_i, number_of_appraisers: 1 })
    else
      rating_hash = ActiveSupport::JSON.decode(film.baum_rating)
      rating_hash['number_of_appraisers'] += 1
      count_before = rating_hash['number_of_appraisers'] - 1
      number = rating_hash['number_of_appraisers']
      rating = rating_hash['rating']
      rating_hash['rating'] = ((rating * count_before + params[:rating].to_f) / number).round(2)
      rating_hash = ActiveSupport::JSON.encode(rating_hash)
    end
    film.update(baum_rating: rating_hash)
  end

  private

  def check_params
    @current_page = params[:current_page].nil? ? 1 : params[:current_page].to_i
    @filters_genres = params[:filters_genres].nil? ? '' : params[:filters_genres]
    @filters_countries = params[:filters_countries].nil? ? '' : params[:filters_countries]
    @filters_years = params[:filters_years].nil? ? '' : params[:filters_years]
  end

  def convert_params_string_into_array
    @filters_genres = @filters_genres.split(',')
    @filters_countries = @filters_countries.split(',')
    @filters_years = @filters_years.split(',')
  end

  def find_film_with_filter
    find_film_by_genres unless @filters_genres.empty?
    find_film_by_years unless @filters_years.empty?
    find_film_by_countries unless @filters_countries.empty?
  end

  def find_film_by_genres
    @filters_genres.each do |genre|
      @films_before_order = @films_before_order.where('genres like ?', "%#{genre}%")
    end
  end

  def find_film_by_countries
    @filters_countries.each do |country|
      @films_before_order = @films_before_order.where('country like ?', "%#{country}%")
    end
  end

  def find_film_by_years
    @filters_years = @filters_years.map(&:to_i)
    @filters_years.each do |year|
      @films_before_order = @films_before_order.where('year = ?', year)
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

  # Все методы ниже нужны для заполнения БД

  def generate_model_filters
    set_years_list
    set_genres_list
    set_country_list
  end

  def set_years_list
    @year_list = Film.select(:year).distinct.order(year: :desc)
    @year_list.each { |year| Year.create(year: year.year) }
  end

  def set_country_list
    @country_list = []
    Film.select(:country).distinct.each do |film|
      ActiveSupport::JSON.decode(film.country).each do |country|
        country = { 'name_ru' => 'Страна не указана' } if country.is_a? Array
        unless @country_list.include? country['name_ru']
          @country_list.push(country['name_ru'])
          Couynty.create(country: country['name_ru'])
        end
      end
    end
  end

  def set_genres_list
    @genres_list = []
    Film.select(:genres).distinct.each do |film|
      ActiveSupport::JSON.decode(film.genres).each do |genre|
        genre = { 'name_ru' => 'Жанры не указаны' } if genre.is_a?(Array)
        unless @genres_list.include? genre['name_ru']
          @genres_list.push(genre['name_ru'])
          Genre.create(genre: genre['name_ru'])
        end
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
