from ubuntu:latest

LABEL version="0.0.1"
LABEL maintainer="Suman"

RUN apt-get update && apt-get upgrade -y

RUN apt-get install nginx -y

EXPOSE 80

CMD [ "nginx", "-g" , "daemon off;"]
