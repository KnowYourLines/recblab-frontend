# build stage
FROM node:lts-alpine as build-stage
ENV VUE_APP_BACKEND_URL https://recblab-backend.herokuapp.com
ENV VUE_APP_FIREBASE_API_KEY AIzaSyDVXIlfI6TaN9HTiBr5LOO_og5llrmHGJY
ENV VUE_APP_FIREBASE_AUTH_DOMAIN blabsnap.firebaseapp.com
ENV VUE_APP_FIREBASE_PROJECT_ID blabsnap
ENV VUE_APP_FIREBASE_STORAGE_BUCKET blabsnap.appspot.com
ENV VUE_APP_FIREBASE_MESSAGING_SENDER_ID 686756332129
ENV VUE_APP_FIREBASE_APP_ID 1:686756332129:web:a4e367288a0ec0eff6e020
ENV VUE_APP_FIREBASE_MEASUREMENT_ID G-2RW888FZ67
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
COPY nginx.conf /etc/nginx/conf.d/configfile.template
COPY --from=build-stage /app/dist /usr/share/nginx/html
ENV PORT 8080
ENV HOST 0.0.0.0
EXPOSE 8080
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"