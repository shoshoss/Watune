require 'pagy/extras/countless'
require 'pagy/extras/overflow'

#  存在しないページがリクエストされた場合、空のページを返します。
Pagy::DEFAULT[:overflow] = :empty_page
