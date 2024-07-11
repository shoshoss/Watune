module Posts
  module SharedScopes
    extend ActiveSupport::Concern

    included do
      # 相互のダイレクトメッセージや複数選択の送受信、返信のやり取りを表示するスコープ
      scope :shared_with_you, lambda { |current_user, profile_user|
        if current_user.nil? || profile_user.nil?
          Post.none
        else
          # 指定されたユーザーと現在のユーザー間のダイレクトメッセージを取得
          direct_to_profile_user = joins(:post_users).where(
            user_id: current_user.id,
            post_users: { user_id: profile_user.id, role: 'direct_recipient', approved: true }
          )
          direct_to_current_user = joins(:post_users).where(
            user_id: profile_user.id,
            post_users: { user_id: current_user.id, role: 'direct_recipient', approved: true }
          )
          # 現在のユーザーが返信した投稿を取得
          reply_from_current_user = where(
            user_id: current_user.id,
            post_reply_id: Post.where(user_id: profile_user.id).select(:id)
          )
          # プロフィールユーザーが返信した投稿を取得
          reply_from_profile_user = where(
            user_id: profile_user.id,
            post_reply_id: Post.where(user_id: current_user.id).select(:id)
          )

          Post.where(id: direct_to_profile_user.select(:id))
              .or(Post.where(id: direct_to_current_user.select(:id)))
              .or(Post.where(id: reply_from_current_user.select(:id)))
              .or(Post.where(id: reply_from_profile_user.select(:id)))
              .distinct
        end
      }
    end
  end
end
