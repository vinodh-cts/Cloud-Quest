# Use the official Node.js image as the base image
FROM node:10

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install any needed dependencies
RUN npm install

# Copy the rest of your application code, including the bin directory
COPY . .

# Set execute permissions for all scripts in the bin directory
RUN chmod +x /usr/src/app/bin/*

# Expose the port the app runs on
EXPOSE 3000

# Start the application and fetch the SECRET_WORD
RUN node src/000.js & sleep 5 && curl -s http://localhost:3000 | grep -m 1 -oP 'Secret page you did find! \K\w+' > /tmp/secret_word

# Start the application and set the SECRET_WORD environment variable
CMD ["sh", "-c", "export SECRET_WORD=$(cat /tmp/secret_word) && node src/000.js"]
