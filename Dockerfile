# Use Nginx to serve static files
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your HTML/CSS files to the Nginx web directory
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Nginx will serve content automatically from /usr/share/nginx/html
