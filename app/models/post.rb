class Post < ApplicationRecord
  belongs_to :user

  # アップローダーを関連付け
  mount_uploader :audio, AudioUploader

  validates :body, length: { maximum: 10_000 }

  # 録音時間を秒単位で保存する属性
  attribute :duration, :integer

  # 録音ファイルの保存と同時に録音時間を更新
  before_save :set_duration

  enum privacy: { only_me: 0, friends_only: 1, open: 2 }

  private

  def set_duration
    # durationフィールドが変更されていれば保存
    self.duration = duration if duration_changed?
  end
end
