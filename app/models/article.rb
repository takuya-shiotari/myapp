class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 64, allow_blank: true }
  validates :content, presence: true

  def bar
    "#{title} bar"
  end

  def baz
    "#{title} baz"
  end

  def hoge
    'hoge'
  end
end
