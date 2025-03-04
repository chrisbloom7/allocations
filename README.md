# 💰 Allocations - A Ruby on Rails 8 Application

This is a Ruby on Rails 8 application that allows users to allocate prorated funds from a pool of investors.

## 🚀 Features

- ✅ Allocate funds automatically using a proration algorithm
- ✅ Add new investors and funds to the pool
- ✅ Live updates using Hotwire/Stimulus
- ✅ TailwindCSS + DaisyUI for modern UI styling

## 📦 Installation

### 1️⃣ Clone the Repository

```shell
git clone https://github.com/chrisbloom7/allocations.git
cd allocations
```

### 2️⃣ Install Dependencies

```shell
bundle install
npm install # or yarn install
```

### 3️⃣ Setup Database

(This project does not require a database, but Rails expects one to be present)

```shell
bin/rails db:create
bin/rails db:migrate
```

### 4️⃣ Start the Server

```shell
bin/dev
```

Visit http://localhost:3000 🚀

## 🧪 Running Tests

Run Rails Unit Tests

```shell
bin/rails test
```
