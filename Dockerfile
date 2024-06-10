FROM php:8.0-apache

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    git \
    unzip \
    && docker-php-ext-install mysqli session xml

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set the document root
WORKDIR /var/www/webpa

# Copy application files
COPY . .

# Set proper permissions
RUN chown -R www-data:www-data /var/www/webpa \
    && chmod -R 755 /var/www/webpa

# Copy Apache configuration
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install application dependencies
WORKDIR /var/www/webpa
RUN composer install --no-dev --prefer-dist

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@8.19.4

# Install feather-icons
RUN npm install
RUN npm run build

# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
