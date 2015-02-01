# to get this to work in cloud9 type "ruby myapp.rb -p $PORT -o $IP"

require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'haml'
# require 'pony' => for sending email

DB = Sequel.connect('sqlite://prescreen.db')

meetings_db = DB[:meetings]
names_db = DB[:names]


def remove_zero(a_number)
  if a_number[0] = "0"
    a_number[0] = ""  
  end
  return a_number.to_i
end

get '/setup' do
  @last_date = meetings_db.order(:id).last[:date]
  haml :setup
end

post '/setup' do
  @date = params[:date]
  @time = params[:time]
  
  meetings_db.insert(:date => @date, :time => @time)
  @flash = 'Date added. Go to show page <a href="show"></a>'
end

get '/' do
  @next_meeting_date = meetings_db.order(:id).last[:date]
  @next_meeting_time = meetings_db.order(:id).last[:time]
  
  time_now = Time.now
  time_in_mins = time_now.hour * 60 + time_now.min
  
  # the days match, if the time is right open it up
  meeting_time_in_mins = @next_meeting_time.split(":").first.to_i * 60 + @next_meeting_time.split(":").last.to_i
    
  if time_now.day == remove_zero(@next_meeting_date.split("-").last) && time_in_mins > meeting_time_in_mins - 90 && time_in_mins < meeting_time_in_mins - 15 
    
    haml :submit_prescreen
    
  else
    #@flash = remove_zero(@next_meeting_date.split("-").last)
    #@flash = "time now #{time_now.hour}:#{time_now.min} and time just set #{meeting_time_in_mins.to_s}"
    
    haml :home
  end
  
end

post '/' do
  # add the info to the database
  number_of_prescreens = params[:number_of_prescreens]
  name_of_pe = params[:name_of_pe]
  date_to_store = meetings_db.order(:id).last[:date] + " " + meetings_db.order(:id).last[:time]  
  names_db.insert(:manuscripts => number_of_prescreens, :name => name_of_pe, :date => date_to_store)
  @flash = "Thanks for submitting, see you at the meeting."
  haml :submit_prescreen
end

get '/show' do
  @count_the_prescreens = 0
  @item_from_names = names_db.where(:date => meetings_db.order(:id).last[:date] + " " + meetings_db.order(:id).last[:time]).order(:manuscripts)
  haml :show
end