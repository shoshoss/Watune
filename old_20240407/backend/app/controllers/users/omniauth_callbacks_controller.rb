module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      # ここにGoogle認証の処理を実装
    end
  end
end
