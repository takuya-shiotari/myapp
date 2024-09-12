class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32, allow_blank: true }

  def name_or_default
    name || '(no name)'
  end

  def flaky_test
    return if [false, true, false].sample

    'flaky test'
  end
end
