FROM node:22-alpine
LABEL org.opencontainers.image.source=https://github.com/chittng/github-kubernetes

WORKDIR /app
COPY package.json server.js index.html ./
USER node
EXPOSE 8080
CMD ["node", "server.js"]
