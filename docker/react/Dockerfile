FROM node:20

# 言語環境をUTF-8、タイムゾーンを日本（東京）に設定
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

WORKDIR /usr/src/app

# yarn.lockをpackage-lock.jsonに変更
COPY package.json package-lock.json ./

# yarn installをnpm installに変更
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
