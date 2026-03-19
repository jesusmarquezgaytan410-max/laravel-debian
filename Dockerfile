FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git curl unzip zip \
    libpq-dev libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring bcmath

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN mkdir -p /var/www/database \
    && touch /var/www/database/database.sqlite

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

RUN php artisan config:clear \
    && php artisan cache:clear \
    && php artisan route:clear \
    && php artisan view:clear

EXPOSE 10000
CMD php artisan serve --host=0.0.0.0 --port=10000
