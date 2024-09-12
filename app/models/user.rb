class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32, allow_blank: true }

  def name_or_default
    name || '(no name)'
  end
end
