#  Postoria - A Social Media App

Postoria is a modern social media web application built with **Ruby on Rails**.  
It allows users to sign up, log in, and create posts in a simple and engaging way.  

The project supports both **Dockerized setup** and **local setup**.

---

##  Features
-  User authentication with Devise (username & email login)
-  Full CRUD operations for posts
-  Responsive UI with Bootstrap + SCSS
-  URL scraping with Ferrum (fetch post image,title, description, etc.)
-  Background jobs using Sidekiq + Redis
-  Fully containerized with Docker & Docker Compose
-  Persistent database storage (via Docker volumes)

---

## Tech Stack
- **Backend:** Ruby on Rails 7
- **Frontend:** ERB templates, Bootstrap, SCSS
- **Database:** PostgreSQL (via Docker), SQLite (local development)
- **Background Jobs:** Sidekiq with Redis
- **Containerization:** Docker, Docker Compose

---

## Installation

You can run the project in **two ways**: using **Docker** (recommended) or directly on your **local machine**.

---

### 1. Setup with Docker (Recommended)

Make sure you have **Docker** and **Docker Compose** installed.

#### Build images (web + sidekiq):
```bash
sudo docker-compose build
```
#### Start containers (web, sidekiq, redis, db):
```bash
sudo docker-compose up
```

#### Access the App

 Visit http://localhost:3000

#### Stop containers
```bash
sudo docker-compose down
```
#### To Open Rails console inside web container
```bash
sudo docker-compose run web rails c
```


### 2. Setup on Localhost (Without Docker)

Make sure you have installed:
- Ruby 3.x
- Rails 7.x
- Bundler
- Yarn
- SQLite3

#### Install dependencies

```bash
 bundle install
 yarn install
```
#### Setup the database

```bash
rails db:create db:migrate
```

#### Start the server

```bash
rails s -p 3001
```

#### Access the App

 Visit http://localhost:3001