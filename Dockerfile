FROM php:7.2-fpm-alpine

# Add docker-php-extension-installer script
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    icu-libs \
    libc-dev \
    libzip-dev \
    make \
    mysql-client \
    nodejs \
    npm \
    oniguruma-dev \
    yarn \
    openssh-client \
    postgresql-libs \
    rsync \
	supervisor \
    zlib-dev

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
    @composer \
    redis-stable \
    imagick-stable \
    xdebug-stable \
    bcmath \
    calendar \
    exif \
    gd \
    intl \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pcntl \
    soap \
    mongodb \
    zip

RUN apk update && apk upgrade &&\
    apk add supervisor  openssh nginx
# Add local and global vendor bin to PATH.
ENV PATH ./vendor/bin:/composer/vendor/bin:/root/.composer/vendor/bin:/usr/local/bin:$PATH

# Supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

# Override nginx's default config
COPY ./config/app.conf /etc/nginx/nginx.conf

# Override default nginx welcome page
COPY . /var/www/html

# Copy Scripts
COPY ./start.sh /start.sh

# Copy crontab file to the cron.d directory
COPY ./config/crontab /etc/cron.d/crontab

# Give execution rights on the cron job
RUN chmod 0777 /etc/cron.d/crontab

# Apply cron job
RUN /usr/bin/crontab /etc/cron.d/crontab

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

WORKDIR /var/www/html
RUN echo "extension=mongodb.so" > /usr/local/etc/php/php.ini
RUN echo "extension=mongodb.so" > /usr/local/etc/php/mongodb.ini

#RUN composer update
#RUN php artisan schedule:clear-cache
# Run the command on container startup

EXPOSE 80

CMD ["/start.sh"]
