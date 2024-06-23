require 'pagy/extras/countless'
require 'pagy/extras/overflow'

#  存在しないページがリクエストされた場合、最後のページを返します。
Pagy::DEFAULT[:overflow] = :last_page
