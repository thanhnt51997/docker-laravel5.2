FROM php:7.3.2-fpm

# Add docker-php-extension-installer script
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install dependencies
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
	apk add --no-cache \
    libzip4 \
    libzip-dev \
    unzip \
	openssh-client \
    libmcrypt-dev \
    libssl-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
&& apt-get autoremove \
&& apt-get clean \
&& rm -r /var/lib/apt/lists/* \
&& cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

# https://github.com/docker-library/php/issues/541
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
&& docker-php-ext-install gd \
&& docker-php-ext-install pdo_mysql zip mysqli \
&& pecl install mcrypt-1.0.2 \
&& docker-php-ext-enable mcrypt \
&& pecl install msgpack \
&& echo "extension=msgpack.so" > /usr/local/etc/php/conf.d/msgpack.ini \
&& pecl install mongodb \
&& echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini \
&& pecl install redis \
&& echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
&& pecl clear-cache

#RUN apk update && apk upgrade &&\
#    apk add  openssh nginx
RUN apk update && apk upgrade &&\
    apk add supervisor  openssh nginx
    apk add  openssh nginx

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
RUN /etc/cron.d/crontab

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

WORKDIR /var/www/html

#RUN composer update
#RUN php artisan schedule:clear-cache
# Run the command on container startup

EXPOSE 80

CMD ["/start.sh"]
