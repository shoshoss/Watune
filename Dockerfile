FROM ruby:3.3.0
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# 基本的なパッケージのインストール
RUN apt-get update -qq \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=21 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y build-essential libpq-dev libssl-dev nodejs yarn vim wget yasm pkg-config \
    && apt-get install -y libmp3lame-dev

# FFmpegのインストール（LGPL準拠）
WORKDIR /tmp
RUN wget https://ffmpeg.org/releases/ffmpeg-7.0.1.tar.gz \
    && tar xzf ffmpeg-7.0.1.tar.gz \
    && cd ffmpeg-7.0.1 \
    && ./configure --enable-static --disable-shared --disable-debug --disable-doc --disable-ffplay --disable-ffprobe \
       --enable-libmp3lame --enable-libvpx \
    && make \
    && make install

# アプリケーションのセットアップ
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.7 && \
    bundle install
COPY . /app
