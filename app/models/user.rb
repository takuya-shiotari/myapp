class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32, allow_blank: true }
end