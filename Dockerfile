# Use the official Node.js image as a base
FROM node:18.16.0 AS base
# Set the working directory in the container
WORKDIR /app
# Copy package.json and package-lock.json into the container
COPY package*.json ./
# Development stage
FROM base AS development
# Install dependencies
RUN npm install --legacy-peer-deps
# Install Angular CLI globally
RUN npm install -g @angular/cli@16.0.1
# Copy the rest of the application code into the container
COPY . .
# Expose the Angular app port
EXPOSE 4200
# Start the Angular development server
CMD ["ng", "serve", "--host", "0.0.0.0"]

# Production stage
FROM base AS production
# Install only production dependencies
RUN npm ci --only=production
# Build the Angular app
COPY . .
RUN ng build --prod
# Use the official nginx image as a base
FROM nginx:1.21.6-alpine
# Copy the Angular build files into the container
COPY dist/angular/* /var/www/html/
# Expose the default nginx port
EXPOSE 80
# Start nginx server
CMD ["nginx", "-g", "daemon off;"]