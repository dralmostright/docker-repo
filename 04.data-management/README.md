## Data management in Dockers
Containers are immuatable means once deployed they will not be persistent once the containers are not running inside the containers and only way is to rebuild the image and redeploy. The data doesn't persist when that container no longer exists, and it can be difficult to get the data out of the container if another process needs it.

Hence docker has two options for containers to store files in the host machine, so that thhe files are persisted even after the container stops. We can achive this by using Volumes and Bind Mounts.

### Volumes
Volumes are stored in part of the host filesystem which is managed by Docker. Volumes are created and Managed by Containers. Volumes can be created by Volume command in Docker File. When you create a volume it is stored within a directory on the Docker host machine. Volumes cannot be removed when user destroy the containers.

Lets review the docker image of mysql and examine how it is:
```
root@testpc:~# docker pull mysql
Using default tag: latest
latest: Pulling from library/mysql
eba3c26198b7: Pull complete
97f7c8c33abe: Pull complete
aa23d877fa04: Pull complete
a143609ddd2d: Pull complete
78308a3437c4: Pull complete
c0880e4b3737: Pull complete
4bab267f9ce1: Pull complete
e575f6d9b17a: Pull complete
607f86c00053: Pull complete
cd68caa5febe: Pull complete
Digest: sha256:fd8d1b4e287c49e1e35eb5a103f337111947662130eb8a3e6c3e823813f47f7d
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest
root@testpc:~#
root@testpc:~# docker images
REPOSITORY        TAG       IMAGE ID       CREATED          SIZE
testnginx         0.0.1     8354333cd5a4   20 minutes ago   133MB
mysql             latest    be960704dfac   13 days ago      602MB
ubuntu            latest    59ab366372d5   2 weeks ago      78.1MB
nginx             alpine    cb8f91112b6b   3 weeks ago      47MB
nginxchg          latest    cb8f91112b6b   3 weeks ago      47MB
nginx             latest    3b25b682ea82   3 weeks ago      192MB
hello-world       latest    d2c94e258dcb   18 months ago    13.3kB
jenkins/jenkins   latest    487c02871276   2 years ago      460MB
root@testpc:~#
root@testpc:~# docker inspect mysql | grep -v null | grep -A 5 "Volumes"
            "Volumes": {
                "/var/lib/mysql": {}
            },
            "WorkingDir": "/",
            "Entrypoint": [
                "docker-entrypoint.sh"
root@testpc:~#
root@testpc:~# docker run -d --name mydb -e MYSQL_ALLOW_EMPTY_PASSWORD=True mysql
114c343e302a502d078924882f3dd1b28ae99ad7d8e43d10258aeda693c2ff78
root@testpc:~# docker container ls
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                   NAMES
114c343e302a   mysql             "docker-entrypoint.s…"   8 seconds ago    Up 7 seconds    3306/tcp, 33060/tcp                     mydb
ee5620a3d5f5   testnginx:0.0.1   "nginx -g 'daemon of…"   19 minutes ago   Up 19 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   nifty_swanson
root@testpc:~# docker container inspect mydb | grep -v null | grep -A 5 "Mounts"
        "Mounts": [
            {
                "Type": "volume",
                "Name": "cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314",
                "Source": "/var/lib/docker/volumes/cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314/_data",
                "Destination": "/var/lib/mysql",
root@testpc:~# ls /var/lib/docker/volumes/cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314/_data
 auto.cnf        binlog.000002   ca-key.pem   client-cert.pem  '#ib_16384_0.dblwr'   ib_buffer_pool   ibtmp1         '#innodb_temp'   mysql.ibd    mysql_upgrade_history   private_key.pem   server-cert.pem   sys        undo_002
 binlog.000001   binlog.index    ca.pem       client-key.pem   '#ib_16384_1.dblwr'   ibdata1         '#innodb_redo'   mysql           mysql.sock   performance_schema      public_key.pem    server-key.pem    undo_001
root@testpc:~#
``` 
To list all the volumes created we can use below command
```
root@testpc:~# docker volume ls
DRIVER    VOLUME NAME
local     cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314
root@testpc:~#
```
Now lets stop the contaier and see if the volumes are still there:
```
root@testpc:~/docker-repo/04.data-management# docker container stop mydb
mydb
root@testpc:~/docker-repo/04.data-management#
root@testpc:~/docker-repo/04.data-management# docker volume ls
DRIVER    VOLUME NAME
local     cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314
root@testpc:~/docker-repo/04.data-management#
```
We can see eventhough the container is stopped its still there.

Now lets inspect the volumes too:
```
root@testpc:~# docker volume inspect cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314
[
    {
        "CreatedAt": "2024-10-28T08:07:48+05:45",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314/_data",
        "Name": "cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314",
        "Options": null,
        "Scope": "local"
    }
]
root@testpc:~#
```

If we need to create a new custom volume and start a container with it. 
```
root@testpc:~# docker run -d --name mysqldb1 -e MYSQL_ALLOW_EMPTY_PASSWORD=True --mount source=mysql-data,destination=/var/lib/mysql mysql
81c88706010c8b217894ab27209644f1d73312c655950dcf647c4243ac74b1de
root@testpc:~#
root@testpc:~# docker volume ls
DRIVER    VOLUME NAME
local     cf809034d8fb997777bf9ca5de66ac3393b2fd4014fc214ef575b48b08d71314
local     mysql-data
root@testpc:~# docker volume inspect mysql-data
[
    {
        "CreatedAt": "2024-10-28T08:15:29+05:45",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mysql-data/_data",
        "Name": "mysql-data",
        "Options": null,
        "Scope": "local"
    }
]
root@testpc:~#
```
