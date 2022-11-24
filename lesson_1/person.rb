
class Person
  attr_accessor :first_name, :last_name

  def initialize(name)
    parse_full_name(name)
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(name)
    parse_full_name(name)
  end

  private

  def parse_full_name(full_name)
    names = full_name.split
    self.first_name = names[0]
    self.last_name = names.size > 1 ? names[1] : ''
  end

end


bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')

p bob.name == rob.name
