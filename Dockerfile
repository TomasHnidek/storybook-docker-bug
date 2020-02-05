#
#---- BASE NODE -----
#this uses alpine as the base and installs requirements to ensure a smaller container
FROM node:12-alpine AS base
RUN apk update &&  apk add --no-cache --update nodejs nodejs-npm tini
WORKDIR /root/app
ENTRYPOINT ["/sbin/tini", "--"]
COPY package.json .
COPY README.md .
COPY src src


#--- dependencies ----
#this will install all dependencies and prod dependencies for later consumption
FROM base AS dependencies
RUN npm install
RUN npm run build-storybook

#---- test install ----
# run tests here
EXPOSE 6006
#---- release ----
FROM base AS release
COPY --from=dependencies /root/app/node_modules ./node_modules
COPY --from=dependencies /root/app/storybook-static ./storybook-static
CMD ["npm", "run", "server"]
