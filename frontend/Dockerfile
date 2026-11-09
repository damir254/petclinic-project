FROM node:24.22.2-bookworm as build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . ./

RUN npm run build -- --configuration production 

FROM nginx:1.31.8 as runtime

COPY --from=build /app/dist/browser/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /tmp/run

RUN chown -R nginx:nginx /var/cache/nginx /tmp/run /var/log/nginx /usr/share/nginx/html

RUN chmod ug+rwx /var/cache/nginx /tmp/run /var/log/nginx /usr/share/nginx/html

RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 8080

USER nginx


