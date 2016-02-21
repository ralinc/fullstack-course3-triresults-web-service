class BikeResult < LegResult

  field :mph, as: :mph, type: Float

  def calc_ave
    if event && secs
      self.mph = (event.miles * 3600 / secs)
    end
  end

end
