# 💰 Allocations - A Ruby on Rails 8 Application

This is a Ruby on Rails 8 application that allows users to allocate prorated funds from a pool of investors.

## 🚀 Features

- ✅ Search for a location using autocomplete (Stimulus.js + Geocoder + Nominatim API)
- ✅ Retrieve weather data using OpenWeather API
- ✅ Cache results using Redis (for faster subsequent requests)
- ✅ Live updates using Hotwire/Stimulus
- ✅ TailwindCSS + DaisyUI for modern UI styling

## 📦 Installation

### 1️⃣ Clone the Repository

```shell
git clone https://github.com/your-username/weather-report.git
cd weather-report
```

### 2️⃣ Install Dependencies

```shell
bundle install
npm install # or yarn install
```

You'll also need to install Redis on your machine. You can do this using Homebrew:

```shell
brew install redis
```

### 3️⃣ Setup Environment Variables

Create a .env file and add:

```env
OPENWEATHER_API_KEY=your_api_key_here
REDIS_URL=your_redis_url_here
SECRET_KEY_BASE=your_secret_key_here
```

### 4️⃣ Setup Database

(This project does not require a database, but Rails expects one to be present)

```shell
bin/rails db:create
bin/rails db:migrate
```

### 5️⃣ Start the Server

```shell
bin/dev
```

Visit http://localhost:3000 🚀

## 🧪 Running Tests

Run Rails Unit Tests

```shell
bin/rails test
```

## 📝 API References

- [OpenWeather API](https://openweathermap.org/api)
- [Geocoder Gem](https://github.com/alexreisner/geocoder)
- [Nominatim API](https://nominatim.org/release-docs/develop/api/Search/)
- [TailwindCSS](https://tailwindcss.com/)
- [DaisyUI](https://daisyui.com/)
