require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'do_postgres'
require 'pony'
require 'json'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Car 
  include DataMapper::Resource
  
  property :id, Serial, :key => true
  property :rfid, String
  property :carname, String
  property :name, String

  has n, :racings
  has n, :races, :through => :racings
end

class Race
  include DataMapper::Resource

  property :id, Serial, :key => true

  has n, :racings
  has n, :cars, :through => :racings
  
  
end

class Racing
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :duration, Integer # time duration of a race in whole numbers

  belongs_to :race, :key => true
  belongs_to :car, :key => true
end


def millisToTime(millis)
  minutes = millis / 60000
  millis = millis - minutes * 60000
  seconds = millis / 1000
  mils = millis % 1000
  output = "%02d" % minutes + ":" + "%02d" % seconds + "." + mils.to_s()
  return output
end


# Main route  - this is the form where we take the input
get '/' do
  @page_title = "Entry"
  #@cars = Car.all

  erb :addcar
  
  
end





get '/addcar' do
  
  @page_title = "addcar"
  
  erb :addcar
  
end

get '/cars' do
  
  @cars = Car.all
  @page_title = "cars"
  
  erb :cars
  
end

get '/cars/:rfid' do
  @cars = Car.all 
  @this_car = Car.first(:rfid => params[:rfid])
  @page_title = "single_car"

  erb :single_car

end

get '/races' do
  
  @page_title = "races"
  @races = Race.all
  @cars = Car.all
  @racings = Racing.all
  erb :races
  
  
end

get '/races/:id' do

  @page_title = "this_race"
  @this_race = Race.get(params[:id])
  @races = Race.all
  
  
  
  erb :single_race


end


get '/racings' do
  
  @page_title = "Leaderboard"
  @racings = Racing.all
  
  erb :racings
  
  
end


get '/eraseall' do
  
  Car.all.destroy
  Race.all.destroy
  Racing.all.destroy
  
  redirect '/cars'
  
end

get '/erase/:rfid' do
  
  Car.first(:rfid => params[:rfid]).destroy
  redirect '/addcar'
  
  
end

get '/erase' do
  
  
  @page_title = "Edit Entries"
  @cars = Car.all
  
  erb :erase
  
end

post '/newcar' do
  car = Car.new
  
  car.id = params[:id]
  car.rfid = params[:rfid].to_s
  car.carname = params[:carname]
  car.name = params[:name]
  
  
  
  if car.save
  
    status 201
    output = ""
  
     output += <<-HTML
     Sucess!
     <br>
     <a href = "/addcar">Add another car</a>
     <br>
     <br>
     <a href = "/cars">See all cars</a>
     <br>
     <br>
    <h2><a href=  "/erase">Edit entries</a></h2>
    <br>
    
     HTML
    
    
    
  else
    status 412
    
    output = ""
    output += <<-HTML
    Error - Could not read car
    <br>
    <br>
    <a href="/addcar">Try Again</a>
    <br>
    HTML
  end
  output
  
end



post '/races/new' do
  #raise params.inspect
  #raise JSON.parse(params[:cars]).inspect
  #assume data comes in formatted like this:
  stuff = JSON.parse(params[:cars])



p params

p stuff



# Creating a Race etc.


race = Race.new

  # If your rfid ID isnt the same as the car.id do this
 stuff.each do |car|
   
    actual_car = Car.first(:rfid => car["rfid"])
    
    p actual_car
    race.racings << Racing.new(:car => actual_car, :duration => car["duration"])
  end


#car1 = Car.first(:rfid => params[:car1id])
#car2 = Car.first(:rfid => params[:car2id])
#car3 = Car.first(:rfid => params[:car3id])


#race.racings << Racing.new(:car => car1, :duration => params[:car1dur])
#race.racings << Racing.new(:car => car2, :duration => params[:car2dur])
#race.racings << Racing.new(:car => car3, :duration => params[:car3dur])

race.save


  if race.save
  
    status 201
    output = ""
  
   for r in Race.all
     output += <<-HTML
     
  <h1>SUCCESS!</h1>
  r.racings
  r.cars


      HTML
      end
      output
  else
    status 412
    output = ""
    
    output += <<-HTML
    
    <h1>FAIL</h1>
    HTML
    
  end
  output
  end
  
  
  

DataMapper.finalize
DataMapper.auto_upgrade!
