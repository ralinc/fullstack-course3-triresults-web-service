class RunResult < LegResult

  field :mmile, type: Float, as: :minute_mile

  def calc_ave
    if event && secs
      self.mmile = (secs / 60) / event.miles
    end
  end

  def secs=(value)
    super
    calc_ave
  end

end
