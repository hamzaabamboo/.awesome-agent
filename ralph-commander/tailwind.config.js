/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'neon-blue': '#00f2ff',
        'neon-purple': '#bc13fe',
        'neon-green': '#39ff14',
        'dark-bg': '#0a0a0c',
        'dark-card': '#16161a',
      },
      boxShadow: {
        'neon-blue': '0 0 10px rgba(0, 242, 255, 0.5), 0 0 20px rgba(0, 242, 255, 0.3)',
        'neon-purple': '0 0 10px rgba(188, 19, 254, 0.5), 0 0 20px rgba(188, 19, 254, 0.3)',
      }
    },
  },
  plugins: [],
}
