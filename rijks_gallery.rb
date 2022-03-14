require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "json"

helpers do
  ARTIST_FILE = {
    "bosch" => "./public/artists/bosch.json",
    "rembrandt" => "./public/artists/rembrandt.json",
    "ter_brugghen" => "./public/artists/ter_brugghen.json",
    "van_gogh" => "./public/artists/van_gogh.json"
  }

  FULL_NAME = {
    "bosch" => "Jheronimus Bosch",
    "rembrandt" => "Rembrandt van Rijn",
    "ter_brugghen" => "Hendrick ter Brugghen",
    "van_gogh" => "Vincent van Gogh"
  }

  def convert_json_to_hash
    json_obj = File.read(@file_path)
    ruby_hsh = JSON.parse(json_obj)
    ruby_hsh
  end

  def find_titles
    @art_objects.each_with_object([]) do |art_object, results|
      results << art_object["title"]
    end
  end

  def find_image
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["webImage"]["url"]
  end

  def find_long_title
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["longTitle"]
  end

  def find_maker
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["principalOrFirstMaker"]
  end

  def find_production_years
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["longTitle"].split(',')[2]
  end

  def find_title
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["title"]
  end

  def find_id_of_title(title)
    @art_objects.select do |art_object|
      art_object["title"] == title
    end[0]["id"]
  end
end

get '/' do
  redirect '/artists'
end

get '/artists' do
  erb :artists
end

get '/:artist' do
  @artist = params[:artist]
  @full_name = FULL_NAME[@artist]
  @file_path = ARTIST_FILE[@artist]
  @collection = convert_json_to_hash
  @art_objects = @collection["artObjects"]
  @titles = find_titles

  erb :artist
end

get '/:artist/:id' do
  @artist = params[:artist]
  @full_name = FULL_NAME[@artist]
  @id = params[:id]
  @file_path = ARTIST_FILE[@artist]
  @collection = convert_json_to_hash
  @art_objects = @collection["artObjects"]
  @image = find_image
  @long_title = find_long_title

  erb :id
end
