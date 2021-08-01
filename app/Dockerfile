FROM node:fermium-buster-slim

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init
RUN chmod 755 /usr/local/bin/dumb-init
RUN useradd app -m -d /home/app
USER app
WORKDIR /home/app
ADD --chown=app:app /package.json /yarn.lock /home/app/
ENV PATH=$PATH:/home/app/node_modules/.bin
RUN npm install yarn && \
    rm package-lock.json && \
  yarn install
ADD --chown=app:app /dist /home/app/dist/
EXPOSE 8080

#CMD [ "/usr/local/bin/dumb-init", "--", "node", "./dist/index.js" ]
CMD [ "node", "./dist/index.js" ]
