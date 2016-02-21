class Point

  attr_accessor :longitude, :latitude

  def initialize(longitude = nil, latitude = nil)
    @longitude = longitude
    @latitude = latitude
  end

  def mongoize
    return {type: "Point", coordinates: [(@longitude), (@latitude)]}
  end

  def self.mongoize object
    case object
    when nil then
      nil
    when Point then
      object.mongoize
    else
      object
    end
  end

  def self.demongoize object
    case object
    when nil then
      nil
    when Hash then
      Point.new(object[:coordinates][0], object[:coordinates][1])
    else
      object
    end
  end

  def self.evolve(object)
    mongoize(object)
  end

end
