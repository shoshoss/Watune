module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        "yellow-400-accent": "#ffea00",
        "yellow-700-accent": "#ffd600",
        "deep-orange-400": "#ff7043",
        "deep-orange-500": "#ff5722",
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
      },
      fontSize: {
        sm: "15px", // 15pxの文字サイズを設定
      },
      screens: {
        "lg-plus": "1200px", // ここでlgより少し大きいサイズを設定
        "sm-plus": "720px",
      },
    },
  },
  plugins: [require("daisyui")],
};
