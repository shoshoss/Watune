class Category < ApplicationRecord
  has_many :posts

  validates :category_name, presence: true, uniqueness: true
  validates :add_category_name, uniqueness: true, allow_blank: true
end
