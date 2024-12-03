# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
# Added libpam0g-dev to resolve pam_appl.h error
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    openssl \
    libpam0g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the latest Node.js LTS version (version 20)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install carta-controller and PM2 globally
RUN npm install -g --unsafe-perm carta-controller pm2

# Set up the working directory
WORKDIR /etc/carta

# Generate private and public keys
RUN openssl genrsa -out carta_private.pem 4096 && \
    openssl rsa -in carta_private.pem -outform PEM -pubout -out carta_public.pem

# Copy the configuration file template
COPY config.json /etc/carta/config.json

# Expose the configured port
EXPOSE 8000

# Define the default command to run Carta Controller using PM2
CMD ["pm2-runtime", "carta-controller"]
