## Docker Images

Below command can be used to list all images currently locally available. The command lists the repository name, name aka TAG, image id, image downloaded  date and the space currently consumed.
```
root@testpc:~# docker images
REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
nginx             alpine    cb8f91112b6b   3 weeks ago     47MB
nginx             latest    3b25b682ea82   3 weeks ago     192MB
hello-world       latest    d2c94e258dcb   18 months ago   13.3kB
root@testpc:~#
```

### Docker Images
In real time Docker images is basically a series of alyers and DOcuer used the union file system to create the layer and then combine them to create a single unit or to create a single image. Each layer have their own specific use and each layer have a union file system which is independent from the other part of layer.

Union file systems allow files and directories of separate file systems known as branches
```
root@testpc:~# docker history nginx
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
3b25b682ea82   3 weeks ago   CMD ["nginx" "-g" "daemon off;"]                0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   STOPSIGNAL SIGQUIT                              0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   EXPOSE map[80/tcp:{}]                           0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   ENTRYPOINT ["/docker-entrypoint.sh"]            0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   COPY 30-tune-worker-processes.sh /docker-ent…   4.62kB    buildkit.dockerfile.v0
<missing>      3 weeks ago   COPY 20-envsubst-on-templates.sh /docker-ent…   3.02kB    buildkit.dockerfile.v0
<missing>      3 weeks ago   COPY 15-local-resolvers.envsh /docker-entryp…   389B      buildkit.dockerfile.v0
<missing>      3 weeks ago   COPY 10-listen-on-ipv6-by-default.sh /docker…   2.12kB    buildkit.dockerfile.v0
<missing>      3 weeks ago   COPY docker-entrypoint.sh / # buildkit          1.62kB    buildkit.dockerfile.v0
<missing>      3 weeks ago   RUN /bin/sh -c set -x     && groupadd --syst…   117MB     buildkit.dockerfile.v0
<missing>      3 weeks ago   ENV DYNPKG_RELEASE=1~bookworm                   0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   ENV PKG_RELEASE=1~bookworm                      0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   ENV NJS_RELEASE=1~bookworm                      0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   ENV NJS_VERSION=0.8.6                           0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   ENV NGINX_VERSION=1.27.2                        0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   LABEL maintainer=NGINX Docker Maintainers <d…   0B        buildkit.dockerfile.v0
<missing>      3 weeks ago   /bin/sh -c #(nop)  CMD ["bash"]                 0B
<missing>      3 weeks ago   /bin/sh -c #(nop) ADD file:90b9dd8f12120e8b2…   74.8MB
root@testpc:~#
```

In above output there series of file systems the last line is one which are followed by bash, other filesystems and cmds. Each layer is depended on previous creating funnel like structure.

```
root@testpc:~# docker image inspect nginx | grep -A 8 "Layers"
            "Layers": [
                "sha256:98b5f35ea9d3eca6ed1881b5fe5d1e02024e1450822879e4c13bb48c9386d0ad",
                "sha256:b33db0c3c3a85f397c49b1bf862e0472bb39388bd7102c743660c9a22a124597",
                "sha256:63d7ce983cd5c7593c2e2467d6d998bb78ddbc2f98ec5fed7f62d730a7b05a0c",
                "sha256:296af1bd28443744e7092db4d896e9fda5fc63685ce2fcd4e9377d349dd99cc2",
                "sha256:8ce189049cb55c3084f8d48f513a7a6879d668d9e5bd2d4446e3e7ef39ffee60",
                "sha256:6ac729401225c94b52d2714419ebdb0b802d25a838d87498b47f6c5d1ce05963",
                "sha256:e4e9e9ad93c28c67ad8b77938a1d7b49278edb000c5c26c87da1e8a4495862ad"
            ]
root@testpc:~#
```

### Docker images tagging
Docker tages convery useful information about specific images and its a basically a version of a image. DOcker images don't have name. Tags will be added during build of image and they can be explictly tagged using docke tag command.
```
root@testpc:~# docker images
REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
nginx             latest    3b25b682ea82   3 weeks ago     192MB
nginx             alpine    cb8f91112b6b   3 weeks ago     47MB
hello-world       latest    d2c94e258dcb   18 months ago   13.3kB
jenkins/jenkins   latest    487c02871276   2 years ago     460MB
root@testpc:~#
root@testpc:~#
root@testpc:~# docker tag cb8f91112b6b nginxchg
root@testpc:~#
root@testpc:~# docker images
REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
nginx             latest    3b25b682ea82   3 weeks ago     192MB
nginx             alpine    cb8f91112b6b   3 weeks ago     47MB
nginxchg          latest    cb8f91112b6b   3 weeks ago     47MB
hello-world       latest    d2c94e258dcb   18 months ago   13.3kB
jenkins/jenkins   latest    487c02871276   2 years ago     460MB
root@testpc:~#
```

The above command tagged image with new name copying as new image. When you didn't specify tag, by default it will tag as latest tag.

### Build own docker images

#### Dockerfile
Docker images can be build automatically by reading the instructions from a Dockerfile. A dockerfile is a text (yaml syntax) that contains all the commands a user could call on the command line to assemble an image. A docker image consists of read-only layers each of which represents a Dockerfile instruction.

FROM : The FROM instruction initializes a new build stage and sets the base Image form subsquent instructions and a dockerfile to be valid it must start with FROM instruction with base image being any valid image.
LABEL : LABEL added to image to orginie images by project, record lisencing information. Each label will have one or more key-value pairs e.g. LABEL client="ABC Industries"
RUN : RUN instruction will execute any commands in a new layer on top of hte current image and commit the results e.g.
```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y ftp
```
CMD : CMD instruction should be used to run the software contained by your image, along with any arguments. There can be only one CMD instruction in Dockerfile. If we have multiple, last one will take precedence. Main purpose of a CMD is to provide defaults for executing container.
EXPOSE : EXPOSE instruction indicates the ports on which a container listens for connections
ENV : ENV instruction sets the environment variables
ADD : ADD instruction copies new files, directories or remote file URLS from <src> and adds then to the filesystem of the image at the patch <dest>
VOLUME : VOLUME instruction should be used to expose any database storage area, configuration storage, or files/folders created by you docker container.
WORKDIR : WORKDIR instruction sets the working directory for any RUN, CMD, ADD instructions that follow it in DockerFile.

```
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . .

# Define environment variable
ENV NAME World

# Expose port 80
EXPOSE 80

# Run app.py when the container launches
CMD ["python", "app.py"]
```
