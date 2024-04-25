class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  # パスワードリセット申請画面へレンダリングするアクション
  def new; end

  # パスワードのリセットフォーム画面へ遷移するアクション
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    return if @user.present?

    flash[:error] = 'このリンクは無効です。再度パスワードリセットのリクエストをしてください。'
    redirect_to new_password_reset_path
  end

  # パスワードのリセットを要求するアクション。
  # ユーザーがパスワードのリセットフォームにメールアドレスを入力して送信すると、このアクションが実行される。
  def create
    @user = User.find_by(email: params[:email])
    # この行は、パスワード（ランダムトークンを含むURL）をリセットする方法を説明した電子メールをユーザーに送信します
    @user&.deliver_reset_password_instructions!
    # 「存在しないメールアドレスです」という旨の文言を表示すると、逆に存在するメールアドレスを特定されてしまうため、
    # あえて成功時のメッセージを送信させている
    redirect_to login_path, status: :see_other, notice: t('.success')
  end

  # ユーザーがパスワードのリセットフォームを送信したときに発生
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    return not_authenticated if @user.blank?

    # 次の行は一時トークンをクリアし、パスワードを更新します
    if @user.change_password(params[:user][:password])
      redirect_to login_path, status: :see_other, notice: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit, status: :unprocessable_entity
    end
  end
end
