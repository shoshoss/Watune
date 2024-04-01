// jest.config.js
module.exports = {
  preset: "ts-jest",
  testEnvironment: "jsdom", // フロントエンドのテストの場合、'node' の代わりに 'jsdom' を使用します。
  testPathIgnorePatterns: ["/node_modules/"], // node_modules ディレクトリをテストから除外します。
  transform: {
    "^.+\\.tsx?$": "ts-jest", // .ts および .tsx ファイルを ts-jest を使って変換します。
  },
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"], // Jestが解決するファイル拡張子のリスト。
};
