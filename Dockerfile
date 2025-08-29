# Serve prebuilt static files in dist/ on port 3000
FROM node:20-alpine
WORKDIR /app
COPY dist/ ./dist
RUN npm i -g serve
EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
