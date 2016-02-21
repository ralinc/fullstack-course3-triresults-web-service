class Race
  include Mongoid::Document
  include Mongoid::Timestamps

  field :n, type: String, as: :name
  field :date, type: Date
  field :loc, type: Address, as: :location
  field :events, type: Event
  field :next_bib, type: Integer, default: 0

  embeds_many :events, as: :parent, order: [:order.asc]

  scope :upcoming, -> {where(:date.gte => Date.current)}
  scope :past, -> {where(:date.lt => Date.current)}

  has_many :entrants, foreign_key: "race._id", dependent: :delete, order: [:secs.asc, :bib.asc]

  DEFAULT_EVENTS = {"swim" => {order: 0, name: "swim", distance: 1.0, units: "miles"},
                    "t1"   => {order: 1, name: "t1"},
                    "bike" => {order: 2, name: "bike", distance: 25.0, units: "miles"},
                    "t2"   => {order: 3, name: "t2"},
                    "run"  => {order: 4, name: "run", distance: 10.0, units: "kilometers"}}

  DEFAULT_EVENTS.keys.each do |name|
    define_method("#{name}")  do
      event = events.select {|e| name == e.name}.first
      event ||= events.build(DEFAULT_EVENTS["#{name}"])
    end

    ["order", "distance", "units"].each do |prop|
      define_method("#{name}_#{prop}") do
        self.send("#{name}").send("#{prop}")
      end
      define_method("#{name}_#{prop}=") do |value|
        self.send("#{name}").send("#{prop}=", value)
      end
    end
  end

  ["city", "state"].each do |action|
    define_method("#{action}") do
      self.location ? self.location.send("#{action}") : nil
    end
    define_method("#{action}=") do |name|
      object = self.location ||= Address.new
      object.send("#{action}=", name)
      self.location = object
    end
  end

  def self.default
    Race.new do |race|
      DEFAULT_EVENTS.keys.each {|leg| race.send("#{leg}")}
    end
  end

  def self.upcoming_available_to racer
    upcoming_race_ids = racer.races.upcoming.pluck(:race).map{|r| r[:_id]}
    all_race_ids = Race.upcoming.map{|r| r[:_id]}
    self.in(:_id => (all_race_ids - upcoming_race_ids))
  end

  def create_entrant(racer)
    entrant_clone = Entrant.new
    entrant_clone.race = self.attributes.symbolize_keys.slice(:_id, :n, :date)
    entrant_clone.racer = racer.info.attributes
    entrant_clone.group = self.get_group(racer)
    self.events.each do |event|
      entrant_clone.send("#{event.name}=", event)
    end

    if entrant_clone.validate
      entrant_clone.bib = next_bib
      entrant_clone.save
    end
    entrant_clone
  end

  def next_bib
    self.inc(next_bib: 1)
    self[:next_bib]
  end

  def get_group racer
    if racer && racer.birth_year && racer.gender
      quotient = (date.year - racer.birth_year) / 10
      min_age = quotient * 10
      max_age = ((quotient + 1) * 10) - 1
      gender = racer.gender
      name = min_age >= 60 ? "masters #{gender}" : "#{min_age} to #{max_age} (#{gender})"
      Placing.demongoize(:name=>name)
    end
  end
end
