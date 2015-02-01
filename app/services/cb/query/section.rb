class CB::Query::Section

  attr_reader :channel

  def initialize channel
    @channel = channel
  end

  def list
    channel.sections
  end

  def find_by_slug slug
    [true, list.friendly.find(slug)]
  end
end