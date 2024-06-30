class Category < ApplicationRecord
  has_many :posts

  validates :category_name, presence: true, uniqueness: true
end
