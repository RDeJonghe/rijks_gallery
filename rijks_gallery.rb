require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "json"

helpers do
  ARTIST_FILE = {
    "bosch" => "./public/bosch.json",
    "rembrandt" => "./public/rembrandt.json",
    "ter_brugghen" => "./public/ter_brugghen.json",
    "van_gogh" => "./public/van_gogh.json"
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

  # def find_ids
  #   @art_objects.each_with_object([]) do |art_object, results|
  #     results << art_object["id"]
  #   end
  # end

  def find_image
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["webImage"]["url"]
  end

  def find_long_title
    @art_objects.select { |art_obj| art_obj["id"] == @id }[0]["longTitle"]
  end

  def find_id_of_title(title)
    @art_objects.select do |art_object|
      art_object["title"] == title
    end[0]["id"]
  end
end

# before do
#   @rembrandt_collection = convert_json_to_hash
#   @art_objects = @rembrandt_collection["artObjects"]
#   @titles = find_titles
#   @ids = find_ids
# end

get '/' do
  redirect '/artists'
end

get '/artists' do
  erb :artists
end

get '/:artist' do
  @artist = params[:artist]
  @file_path = ARTIST_FILE[@artist]
  @collection = convert_json_to_hash
  @art_objects = @collection["artObjects"]
  @titles = find_titles
  
  erb :artist
end

get '/:artist/:id' do
  @artist = params[:artist]
  @id = params[:id]
  @file_path = ARTIST_FILE[@artist]
  @collection = convert_json_to_hash
  @art_objects = @collection["artObjects"]
  @image = find_image
  @long_title = find_long_title

  erb :id
end




# get all the ids and check to see if it's included

# jobj = File.read('rijk_proj.json')

# hsh = JSON.parse(jobj)

# p hsh