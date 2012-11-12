# t = Time.now                    # => Thu Jan 15 21:26:36 -0500 2009
# t.floor(15.minutes)             # => Thu Jan 15 21:15:00 -0500 2009
# t.ceil(15.minutes)              # => Thu Jan 15 21:30:00 -0500 2009

class Time
  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end

  def ceil(seconds = 60)
    Time.at((self.to_f / seconds).ceil * seconds)
  end
end