class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32, allow_blank: true }

  def normalized_name
    return if [true, false].sample

    name.strip.gsub(/\s+/, ' ')
  end

  def bar
    'bar'
  end
end
