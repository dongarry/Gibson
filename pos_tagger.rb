require 'singleton'

class POS_Tagger
  include Singleton

  # Make this a singleton as we only need one of these at any stage.

  def initialize()
    @tags=Hash.new
    load_tags
  end

  def load_tags
    f = File.open("POS_Tags.csv", "r")
    # loop through the csv file, adding each record to our hash table.
    f.each_line { |line|
      fields = line.split(',')
      @tags[fields[0].to_s] = fields[1].strip.to_s
  }
  end

  def have_tags?(str)
      return @tags.has_key?(str)
  end

end
