# Dockerfile for Strapi v5 (Node >=20)
FROM node:20-alpine

# set working dir
WORKDIR /app

# production environment
ENV NODE_ENV=production
ENV PORT=1337
EXPOSE 1337

# install build tools required for native modules (better-sqlite3)
RUN apk add --no-cache python3 make g++ bash

# copy package files and install production deps
COPY package*.json ./
RUN npm install && npm install pg --save


# copy app source
COPY . .

# build admin UI
RUN npm run build

# small cleanup (optional)
RUN rm -rf /tmp/*

# start
CMD ["npm", "run", "start"]
