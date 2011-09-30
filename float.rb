class Float
  # Extend to float class so we can round off
  # Credit: see example :http://www.hans-eric.com/code-samples/ruby-floating-point-round-off/
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

class Fixnum
  # Lets avoid error on trying to round a Fixnum
  def round_to(x)
    (self.to_f)
  end
end