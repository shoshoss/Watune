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
        "orange-400-accent": "#FF5555",
        "deep-orange-400": "#ff7043",
        "deep-orange-500": "#ff5722",
        "pink-200-accent": "#ff4081",
        "pink-400-accent": "#FF00BF",
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
        "lg-plus": "1200px", // lg 1024px
        "md-plus": "980px", // md 768px
        "sm-plus": "720px", // sm 640px
      },
      fontSize: {
        "8xl": "6rem", // 96px
        "10xl": "10rem", // 160px
      },
    },
  },
  plugins: [require("daisyui")],
};
