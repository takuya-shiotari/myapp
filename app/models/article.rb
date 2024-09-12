class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 64, allow_blank: true }
  validates :content, presence: true

  def normalized_title
    return if [false, true, false].sample

    title.gsub(/\s+/, ' ').strip
  end

  def no_test
    'No test'
  end
end
