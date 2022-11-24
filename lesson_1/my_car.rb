class Vehicle
  attr_accessor :color
  attr_reader :year, :model, :current_speed
  @@number_of_vehicles = 0

  def self.number_of_vehicles
    puts "#{@@number_of_vehicles} vehicles have been instantiated"
  end

  def initialize(year, model, color)
    @@number_of_vehicles += 1
    @year = year
    @model = model
    @color = color
    @current_speed = 0
  end

  def spray_paint(new_color)
    @color = new_color
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  def speed_up(number)
    @current_speed += number
    puts "You push the gas and accelerate #{number} mph."
  end
  
  def brake(number)
    @current_speed -= number
    puts "You push the brake and decelerate #{number} mph."
  end

  def current_speed
    puts "You are now going #{@current_speed} mph."
  end

  def shut_down
    @current_speed = 0
    puts "Let's park this bad boy!"
  end

  def age
    "Your #{self.model} is #{calculate_age} years old"
  end

  private

  def calculate_age
    current_year = Time.now.year
    current_year - self.year
  end

end
  
module HasBed
  def tailgate_party
    "We're throwing a tailgate party!"
  end

  def can_tow?(pounds)
    pounds < 2000
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def to_s
    "My car is a #{self.color}, #{self.year}, #{self.model}"
  end

end

class MyTruck < Vehicle
  include HasBed
  NUMBER_OF_DOORS = 2

  def to_s
    "My truck is a #{self.color}, #{self.year}, #{self.model}"
  end

end

lumina = MyCar.new(1997, 'chevy lumina', 'white')
ford = MyTruck.new(2000, 'ford f250', 'black')

puts lumina
puts ford

puts lumina.age
puts ford.age
# p ford.tailgate_party
# p ford.can_tow?(1400)

# puts Vehicle.number_of_vehicles

# puts MyTruck.ancestors
# puts '----------------'
# puts MyCar.ancestors
# puts '----------------'
# puts Vehicle.ancestors
