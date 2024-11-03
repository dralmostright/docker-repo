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

Basic template of docker-compose file
```
version : '3'

services : #name for the container
   servicename1: # container service name
        image : # optional specify if build specific
        command: # optional relm and CMD specified in image
        environment: # optional similar to -e in Docker run command
        volumes: # optionsl, similar to --mount in docker run
   servicename2:
           .....

volumes: # Optional Mounts a linked path on host machine  that can be accessed in containers

networks: # optional same as Docker network
```

Now we will setup MySQL and Wordpress containers. First lets create a compose file
```
root@testpc:~/bindmount# cat docker-compose.yml
version: '2.6' #Version of YML file

services:
        db:
                image: mysql:5.7
                container_name: db
                volumes:
                        - db_data:/var/lib/mysql
                restart: always
                environment:
                        MYSQL_ROOT_PASSWORD: mypassword
                        MYSQL_DATABASE: wordpress
                        MYSQL_USER: wordpressuser
                        MYSQL_PASSWORD: wordpress

        wordpress:
                depends_on:
                        - db
                image: wordpress:latest
                container_name: wordpress
                ports:
                        - "8080:80"
                restart: always
                environment:
                        WORDPRESS_DB_HOST: db:3306
                        WORDPRESS_DB_USER: wordpressuser
                        WORDPRESS_DB_PASSWORD: wordpress

volumes:
        db_data:
root@testpc:~/bindmount#
```

Now lets run docker compose:
```
root@testpc:~/bindmount# docker compose up -d
[+] Running 34/34
 ⠿ db Pulled                                                                                                                                                                                                                                                                    18.8s
   ⠿ 20e4dcae4c69 Pull complete                                                                                                                                                                                                                                                  5.0s
   ⠿ 1c56c3d4ce74 Pull complete                                                                                                                                                                                                                                                  5.2s
   ⠿ e9f03a1c24ce Pull complete                                                                                                                                                                                                                                                  5.4s
   ⠿ 68c3898c2015 Pull complete                                                                                                                                                                                                                                                  5.9s
   ⠿ 6b95a940e7b6 Pull complete                                                                                                                                                                                                                                                  6.0s
   ⠿ 90986bb8de6e Pull complete                                                                                                                                                                                                                                                  6.2s
   ⠿ ae71319cb779 Pull complete                                                                                                                                                                                                                                                  8.1s
   ⠿ ffc89e9dfd88 Pull complete                                                                                                                                                                                                                                                  8.2s
   ⠿ 43d05e938198 Pull complete                                                                                                                                                                                                                                                 17.2s
   ⠿ 064b2d298fba Pull complete                                                                                                                                                                                                                                                 17.3s
   ⠿ df9a4d85569b Pull complete                                                                                                                                                                                                                                                 17.5s
 ⠿ wordpress Pulled                                                                                                                                                                                                                                                             21.5s
   ⠿ a480a496ba95 Already exists                                                                                                                                                                                                                                                 0.0s
   ⠿ 95ab1cc5ca33 Pull complete                                                                                                                                                                                                                                                  2.9s
   ⠿ 78ee5e1490ca Pull complete                                                                                                                                                                                                                                                 12.7s
   ⠿ e807ae4973d0 Pull complete                                                                                                                                                                                                                                                 12.9s
   ⠿ 8a1846dfbe9a Pull complete                                                                                                                                                                                                                                                 14.1s
   ⠿ 27f1d0bbde81 Pull complete                                                                                                                                                                                                                                                 14.2s
   ⠿ 8fac5e585cd6 Pull complete                                                                                                                                                                                                                                                 14.3s
   ⠿ 7c65c4fca52e Pull complete                                                                                                                                                                                                                                                 14.6s
   ⠿ af2e2799aa38 Pull complete                                                                                                                                                                                                                                                 14.8s
   ⠿ a54527c6f928 Pull complete                                                                                                                                                                                                                                                 16.4s
   ⠿ 3d76291219c3 Pull complete                                                                                                                                                                                                                                                 16.5s
   ⠿ c8e14935230b Pull complete                                                                                                                                                                                                                                                 16.6s
   ⠿ 24cbeb13063d Pull complete                                                                                                                                                                                                                                                 16.7s
   ⠿ 72c6dbb62161 Pull complete                                                                                                                                                                                                                                                 18.0s
   ⠿ f3380324bcbe Pull complete                                                                                                                                                                                                                                                 18.6s
   ⠿ c0fa9286e198 Pull complete                                                                                                                                                                                                                                                 18.7s
   ⠿ 8e16f05140fd Pull complete                                                                                                                                                                                                                                                 18.7s
   ⠿ ed249af23b65 Pull complete                                                                                                                                                                                                                                                 18.8s
   ⠿ acd6e8eb134b Pull complete                                                                                                                                                                                                                                                 20.1s
   ⠿ 4e0d1246ed19 Pull complete                                                                                                                                                                                                                                                 20.1s
   ⠿ 72a1501f3910 Pull complete                                                                                                                                                                                                                                                 20.2s
[+] Running 4/4
 ⠿ Network bindmount_default   Created                                                                                                                                                                                                                                           0.1s
 ⠿ Volume "bindmount_db_data"  Created                                                                                                                                                                                                                                           0.0s
 ⠿ Container db                Started                                                                                                                                                                                                                                           0.9s
 ⠿ Container wordpress         Started                                                                                                                                                                                                                                           1.0s
root@testpc:~/bindmount# docker container ls
CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS          PORTS                                   NAMES
14646b715466   wordpress:latest   "docker-entrypoint.s…"   12 seconds ago   Up 11 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   wordpress
008deecd9005   mysql:5.7          "docker-entrypoint.s…"   13 seconds ago   Up 12 seconds   3306/tcp, 33060/tcp                     db
root@testpc:~/bindmount#
```

Now lets check if wordpress is accessible:
![Word Press](./imgs/img-1.png)

More on docker Compose:

Stopping containers created by compose:
```
root@testpc:~# docker compose down
no configuration file provided: not found
root@testpc:~#
root@testpc:~# cd bindmount/
root@testpc:~/bindmount# docker container ls
CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS          PORTS                                   NAMES
48d2c7cb7f6d   wordpress:latest   "docker-entrypoint.s…"   27 seconds ago   Up 25 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   wordpress
96f3260d6c8e   mysql:5.7          "docker-entrypoint.s…"   27 seconds ago   Up 26 seconds   3306/tcp, 33060/tcp                     db
root@testpc:~/bindmount#
root@testpc:~/bindmount# ls -ltr docker-compose.yml
-rw-r--r-- 1 root root 939 Oct 27 22:37 docker-compose.yml
root@testpc:~/bindmount#
root@testpc:~/bindmount# docker compose down
[+] Running 3/3
 ⠿ Container wordpress        Removed                                                                                                                1.2s
 ⠿ Container db               Removed                                                                                                                1.9s
 ⠿ Network bindmount_default  Removed                                                                                                                0.1s
root@testpc:~/bindmount#
root@testpc:~/bindmount# docker container ls
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@testpc:~/bindmount# 
```

We will create a new docker images by our own:
```
version : 3

services:
  destro: 
    image: alpine ## Image to download from docker hub
    restart: always ## Restart always if any issues with instance
    container_name: calpine ## Give own name instead of system generated name
    entrypoint: tail -f /dev/null ## An event which will be running forver to keep the instance running.
 ```

Now lets create and run it:
 ```
 root@testpc:~/docker-repo/05.docker-compose# cat docker-compose.yml 
version : '3'

services:
  destro: 
    image: alpine
    restart: always
    container_name: calpine
    entrypoint: tail -f /dev/null

root@testpc:~/docker-repo/05.docker-compose# docker compose -f docker-compose.yml up -d
[+] Running 2/2
 ⠿ destro Pulled                                                                                                                                     1.7s
   ⠿ 43c4264eed91 Already exists                                                                                                                     0.0s
[+] Running 2/2
 ⠿ Network 05docker-compose_default  Created                                                                                                         0.1s
 ⠿ Container calpine                 Started                                                                                                         0.7s
root@testpc:~/docker-repo/05.docker-compose# docker container ls
CONTAINER ID   IMAGE     COMMAND               CREATED         STATUS         PORTS     NAMES
59345279f33d   alpine    "tail -f /dev/null"   7 seconds ago   Up 7 seconds             calpine
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# docker container ls
CONTAINER ID   IMAGE     COMMAND               CREATED         STATUS         PORTS     NAMES
59345279f33d   alpine    "tail -f /dev/null"   7 seconds ago   Up 7 seconds             calpine
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# docker compose -f docker-compose.yml down
[+] Running 2/2
 ⠿ Container calpine                 Removed                                                                                                        10.2s
 ⠿ Network 05docker-compose_default  Removed                                                                                                         0.1s
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@testpc:~/docker-repo/05.docker-compose# 
 ```

 We will be adding more containers:
 ```
 root@testpc:~/docker-repo/05.docker-compose# cat docker-compose.yml 
version : '3'

services:
  destro: 
    image: alpine
    restart: always
    container_name: calpine
    entrypoint: tail -f /dev/null

  database:
    image: postgres:latest
    container_name: pgdatabase
    restart: always
    environment: 
      POSTGRES_PASSWORD: example
    ports:
      - "5432:5432"
    volumes:
      - ../../bindmount/pgdata:/tmp/

root@testpc:~/docker-repo/05.docker-compose# docker compose -f docker-compose.yml up -d
[+] Running 3/3
 ⠿ Network 05docker-compose_default  Created                                                                                                         0.1s
 ⠿ Container pgdatabase              Started                                                                                                         1.1s
 ⠿ Container calpine                 Started                                                                                                         1.0s
root@testpc:~/docker-repo/05.docker-compose# docker container ls
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                       NAMES
95054da192da   postgres:latest   "docker-entrypoint.s…"   9 seconds ago   Up 7 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   pgdatabase
3e6b342c19ea   alpine            "tail -f /dev/null"      9 seconds ago   Up 7 seconds                                               calpine
root@testpc:~/docker-repo/05.docker-compose# 
 ```

 Now lets add webserver too. The ``` links ``` links the containers, if any of the container restarts the webserver also restart. And ```database:db``` where the ```db``` is just an alias to container ```database```. Additionally the ```external:true``` under volume section states use external volume named ```pgdata```. If in case that volume doesn't exists the container will not cople up and stack will not start.

First lets create a new volume in docker and later use it:
```
root@testpc:~/docker-repo/05.docker-compose# docker volume create --opt device=/root/bindmount/pgdata pgdata --opt type=mount
pgdata
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# docker volume ls
DRIVER    VOLUME NAME
local     1ddc17c1cf14b3853d4edc766386c806a9ee2c38f507a1afb31b87ae171b5bb8
local     1ee4049b0b66fbdb85ece5d688713138c0a9c3d789836da2283e1bca4e4ef102
local     511d9d05180b535ca6158e9e3c4b77ace37be35fa5c0cbae129fb5eee16fe8da
local     8444556434aadd80d1afd1a5a9aa36ffb0073e8f6ce3f82a4803a9be05b8c2e1
local     bindmount_db_data
local     cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314
local     ebc1e8bc962e0aa5b1696e8a4c7b6eaca0dae95aed22dcfdb52b146be73d6d39
local     mysql-data
local     pgdata
root@testpc:~/docker-repo/05.docker-compose# 
root@testpc:~/docker-repo/05.docker-compose# docker volume inspect pgdata
[
    {
        "CreatedAt": "2024-11-04T02:36:29+05:45",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/pgdata/_data",
        "Name": "pgdata",
        "Options": {
            "device": "/root/bindmount/pgdata",
            "type": "mount"
        },
        "Scope": "local"
    }
]
root@testpc:~/docker-repo/05.docker-compose#
```

Now finally create containers:
```
root@testpc:~/docker-repo/05.docker-compose# cat docker-compose.yml 
version : '3'

services:
  destro: 
    image: alpine
    restart: always
    container_name: calpine
    entrypoint: tail -f /dev/null

  database:
    image: postgres:latest
    container_name: pgdatabase
    restart: always
    environment: 
      POSTGRES_PASSWORD: example
    ports:
      - "5432:5432"
    volumes:
      - ../../bindmount/pgdata:/tmp/

  web:
    image: nginx
    restart: always
    container_name: websrv
    ports:
      - "8080:80"
    volumes:
      - ../../bindmount/pgdata:/etc/nginx/conf.d/mysite.template
    environment:
      - NGINX_HOST=sample.com
      - NGINX_PORT=80
    links:
      - database:db
      - destro
root@testpc:~/docker-repo/05.docker-compose# docker compose -f docker-compose.yml up -d
[+] Running 3/3
 ⠿ Container pgdatabase  Started                                                                                                                     1.0s
 ⠿ Container calpine     Started                                                                                                                     0.7s
 ⠿ Container websrv      Started                                                                                                                     1.9s
root@testpc:~/docker-repo/05.docker-compose# docker container ls
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS         PORTS                                       NAMES
0728db40d1e3   nginx             "/docker-entrypoint.…"   10 seconds ago   Up 7 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp       websrv
5c5f4f533294   postgres:latest   "docker-entrypoint.s…"   10 seconds ago   Up 8 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   pgdatabase
3ef6fe0ae31c   alpine            "tail -f /dev/null"      10 seconds ago   Up 8 seconds                                               calpine
root@testpc:~/docker-repo/05.docker-compose#
```