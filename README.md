# README

Este es un proyecto de API creado sobre docker con una configuración básica, usando y configurando la base de datos de postgresql

comando para replicar la creación del proyecto

### crear proyecto en rails
```bash
rails new docker_ror_postgres_api --api -d postgresql
```

### Valores del Dockerfile
```
FROM ruby:3.3.0

WORKDIR /app

# Clean and update system packages manager
RUN apt-get clean && apt-get update -qq

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock into the container
COPY ["Gemfile", "Gemfile.lock", "./"]

# Install gems
RUN bundle install

EXPOSE 3000
```

### Valores del docker-compose.yml

```yml
version: "3.8"
name: "ror_postgres"
services:
  rails_app:
    image: ror_postgres-api
    build:
      context: .
      dockerfile: Dockerfile
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/app
      - bundler_gems:/usr/local/bundle/
    ports:
      - '3000:3000'
    depends_on:
      - database
      - redis
    environment:
      POSTGRES_USER: user_postgres
      POSTGRES_PASSWORD: passdev
      POSTGRES_PORT: 5432
      POSTGRES_HOST_SERVICE: database

  database:
    restart: on-failure
    image: postgres:14
    command: ["postgres", "-c", "log_statement=all"]
    environment:
      POSTGRES_USER: user_postgres
      POSTGRES_PASSWORD: passdev
      POSTGRES_PORT: 5432
      PGDATA: /var/lib/postgresql/data/pgdata
    ports:
      - 5432:5432
    volumes:
      - postgres_data:/var/lib/postgresql/data

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

  redis:
    image: redis:6
    ports:
      - 6379:6379

volumes:
  bundler_gems:
  postgres_data:

```

### Valores del config/database.yml
```yml
default: &default
  adapter: postgresql
  encoding: unicode
  # schema_search_path: public
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV['POSTGRES_USER'] %>
  password: <%= ENV['POSTGRES_PASSWORD'] %>
  port: <%= ENV['POSTGRES_PORT'] %>
  host: <%= ENV['POSTGRES_HOST_SERVICE']%> # from docker-compose.yml database service

development:
  <<: *default
  database: docker_ror_postgres_api_development

test:
  <<: *default
  database: docker_ror_postgres_api_test

production:
  <<: *default
  database: docker_ror_postgres_api_production

```

### Construir imagen
```bash
docker compose build
```

## Crear Modelo, controllador y migraciones

### Crear controller
```bash
docker-compose run --rm -u 1000:1000 rails_app rails generate controller Api::V1::Animals index create
```

### Crear model

```bash
docker-compose run --rm -u 1000:1000 rails_app rails generate model Animal name:string species:string age:integer
```

### Agregar ruta

```ruby
config/routes.rb

namespace :api do
  namespace :v1 do
    resources :animals, only: %i[create index]
  end
end
```

### Ejecutar migración

```bash
docker compose run --rm rails_app rake db:create
docker compose run --rm rails_app rake db:migration
```

### Ejecutar servidor
```bash
docker compose up
```

### Consumir el create del controller
```
curl -X POST -H "Content-Type: application/json" http://localhost:3000/api/v1/animals
```

### Consumir el index del controller
```
curl http://localhost:3000/api/v1/animals  
```
