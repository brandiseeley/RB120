class Student
  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    other_student.grade < grade
  end


  protected

  def grade
    @grade
  end

end

joe = Student.new('joe', 95)
sandy = Student.new('sandy', 80)

puts "well done" if joe.better_grade_than?(sandy)
