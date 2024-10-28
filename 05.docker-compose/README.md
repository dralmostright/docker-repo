## Docker Compose

Docker compose is used to run multiple containers as a single service. Compose provide relationship between multiple Containers. E.g. a users want to start database server , application server and web server with one YML file. Docker Compose is a three step process.
1. Define app's env with dockerfile so it can be reproduced anywhere.
2. Define the services that make up app in docker-compose.yml, so they can be run together in a isolated enviornment
3. Run docker-compose up and Compose start and runs your entire stack.

Docker compose need to be installed seperately and can be done through instructions in docker website.
```
root@testpc:~# docker compose version
Docker Compose version v2.6.0
root@testpc:~#
```

Docker Compose is based on YML formatted file which describs 
* Containers
* Networks
* Volumes

Components of Docker compose file
* Version statement should be the first line of file
* YML can be used with docker compose comand
* docker-compose.yml if default name of yml file
* Custom name can be used by command using flag -f in compose command.

