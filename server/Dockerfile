FROM node:lts-alpine

EXPOSE 3000
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . ./

# Generate Prisma Client, apply migrations and start the server
CMD ["npm", "start"]
