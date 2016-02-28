class Event
  include Mongoid::Document

  field :o, type: Integer, as: :order
  field :n, type: String, as: :name
  field :d, type: Float, as: :distance
  field :u, type: String, as: :units

  embedded_in :parent, polymorphic: true, touch: true

  validates :order, :name, presence: true

  def meters
    case units
    when "yards" || "yard" then
      distance * 0.9144
    when "miles" || "mile" then
      distance * 1609.34
    when "kilometers" || "kilometer" then
      distance * 1000
    when "meters" || "meter" then
      distance
    else
      nil
    end
  end

  def miles
    case units
    when "meters" || "meter" then
      distance * 0.000621371
    when "kilometers" || "kilometer" then
      distance * 0.621371
    when "yards" || "yard" then
      distance * 0.000568182
    when "miles" || "mile" then
      distance
    else
      nil
    end
  end

end
