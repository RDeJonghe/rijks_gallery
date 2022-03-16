require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "json"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

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

  def find_current_note
    @notes.select do |note|
      note[:name] == @name
    end
  end

  def note_name_exists?(name)
    session[:notes].any? { |note| note[:name] == name }
  end

  def meets_size_requirements?(name)
    name.size >= 1 && name.size <= 30
  end

end

before do
  session[:favorites] ||= []
  session[:notes] ||= []
end

get '/' do
  redirect '/artists'
end

get '/artists' do
  erb :artists, layout: :menu
end

get '/artists/:artist' do
  @artist = params[:artist]
  @file_path = ARTIST_FILE[@artist]
  @art_objects = convert_json_to_hash["artObjects"]
  @titles = find_titles

  erb :artist
end

get '/artists/:artist/:id' do
  @artist = params[:artist]
  @id = params[:id]
  @url = "/artists/#{@artist}/#{@id}"
  @file_path = ARTIST_FILE[@artist]
  @art_objects = convert_json_to_hash["artObjects"]
  @image = find_image
  @long_title = find_long_title

  erb :id
end

get '/favorites' do
  @favorites = session[:favorites]

  erb :favorites
end

get '/artists/:artist/:id/add_favorite' do
  @artist = params[:artist]
  @id = params[:id]
  @url = "/artists/#{@artist}/#{@id}"
  @file_path = ARTIST_FILE[@artist]
  @art_objects = convert_json_to_hash["artObjects"]
  @image = find_image
  @long_title = find_long_title

  session[:favorites] << { long_title: @long_title, url: @url }
  redirect "/favorites"
end

get '/artists/:artist/:id/remove_favorite' do
  @artist = params[:artist]
  @id = params[:id]
  @url = "/artists/#{@artist}/#{@id}"
  @file_path = ARTIST_FILE[@artist]
  @art_objects = convert_json_to_hash["artObjects"]
  # @image = find_image
  @long_title = find_long_title

  session[:favorites].delete_if { |favorite| favorite[:url] == @url }
  redirect "/favorites"
end

get '/notes' do
  @notes = session[:notes]
    
  erb :notes
end

get '/notes/new_note' do
  erb :new_note
end

get '/notes/:note' do
  @notes = session[:notes]
  @name = params[:note]
  @current_note = find_current_note
  erb :note
end

post '/notes' do
  name = params[:name].strip
  
  if meets_size_requirements?(name) && !note_name_exists?(name)
    session[:notes] << { name: params[:name], text: params[:text] }
    session[:success] = "The note has been created."
    redirect '/notes'
  else
    session[:error] = "Note name must be unique and between 1 and 30 characters."
    erb :new_note
  end
end

get '/notes/:note/delete' do
  @notes = session[:notes]
  @name = params[:note]
  @current_note = find_current_note
  session[:notes].delete_if { |note| note[:name] == @current_note[0][:name] }
  redirect '/notes'
end

get '/notes/:note/edit' do
  @notes = session[:notes]
  @name = params[:note]
  @current_note = find_current_note
  
  erb :edit
end

post '/notes/:note' do
  name = params[:name].strip
  @notes = session[:notes]
  @name = params[:note]
  @current_note = find_current_note
  
  if meets_size_requirements?(name)
    @current_note[0][:name] = params[:name]
    @current_note[0][:text] = params[:text]
    session[:success] = "The note has been updated."
    redirect '/notes'
  else
    session[:error] = "Note name must be between 1 and 30 characters."
    erb :edit
  end
end



