FROM node:22-alpine
LABEL org.opencontainers.image.source=https://github.com/chittng/github-kubernetes

WORKDIR /app
COPY package.json server.js ./
USER node
EXPOSE 3000
CMD ["node", "server.js"]
