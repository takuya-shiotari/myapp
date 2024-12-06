class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32, allow_blank: true }

  def foo
    'foo'
  end

  def email
    "#{name}@example.com"
  end

  def bar
    "#{name} bar"
  end

  def baz
    "#{name} baz"
  end
end
