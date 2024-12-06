class Blog
  attr_writer :title

  def initialize(title:)
    @title = title
  end

  def title
    @title
  end
end
