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

Lets build a custom image as below:
```
root@testpc:~/docker-repo/03.docker-images# docker image build -t testnginx:0.0.1 .
Sending build context to Docker daemon  10.24kB
Step 1/7 : from ubuntu:latest
latest: Pulling from library/ubuntu
ff65ddf9395b: Pull complete
Digest: sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5
Status: Downloaded newer image for ubuntu:latest
 ---> 59ab366372d5
Step 2/7 : LABEL version="0.0.1"
 ---> Running in 49ed7d39526f
Removing intermediate container 49ed7d39526f
 ---> cca1d516569d
Step 3/7 : LABEL maintainer="Suman"
 ---> Running in 6d6058efb071
Removing intermediate container 6d6058efb071
 ---> d4c441bf23b9
Step 4/7 : RUN apt-get update && apt-get upgrade -y
 ---> Running in 260cd0269541
Get:1 http://archive.ubuntu.com/ubuntu noble InRelease [256 kB]
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:3 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [13.7 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:5 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [543 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble/restricted amd64 Packages [117 kB]
Get:8 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [717 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble/universe amd64 Packages [19.3 MB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [491 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages [1808 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble/multiverse amd64 Packages [331 kB]
Get:13 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [761 kB]
Get:14 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [491 kB]
Get:15 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [920 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Packages [18.2 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Packages [11.8 kB]
Fetched 26.2 MB in 4s (6679 kB/s)
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
The following packages will be upgraded:
  gcc-14-base libgcc-s1 libstdc++6
3 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 921 kB of archives.
After this operation, 2048 B of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 gcc-14-base amd64 14.2.0-4ubuntu2~24.04 [50.8 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libstdc++6 amd64 14.2.0-4ubuntu2~24.04 [791 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libgcc-s1 amd64 14.2.0-4ubuntu2~24.04 [78.6 kB]
debconf: delaying package configuration, since apt-utils is not installed
Fetched 921 kB in 1s (786 kB/s)
(Reading database ... 4379 files and directories currently installed.)
Preparing to unpack .../gcc-14-base_14.2.0-4ubuntu2~24.04_amd64.deb ...
Unpacking gcc-14-base:amd64 (14.2.0-4ubuntu2~24.04) over (14-20240412-0ubuntu1) ...
Setting up gcc-14-base:amd64 (14.2.0-4ubuntu2~24.04) ...
(Reading database ... 4379 files and directories currently installed.)
Preparing to unpack .../libstdc++6_14.2.0-4ubuntu2~24.04_amd64.deb ...
Unpacking libstdc++6:amd64 (14.2.0-4ubuntu2~24.04) over (14-20240412-0ubuntu1) ...
Setting up libstdc++6:amd64 (14.2.0-4ubuntu2~24.04) ...
(Reading database ... 4379 files and directories currently installed.)
Preparing to unpack .../libgcc-s1_14.2.0-4ubuntu2~24.04_amd64.deb ...
Unpacking libgcc-s1:amd64 (14.2.0-4ubuntu2~24.04) over (14-20240412-0ubuntu1) ...
Setting up libgcc-s1:amd64 (14.2.0-4ubuntu2~24.04) ...
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...
Removing intermediate container 260cd0269541
 ---> e779467d3f00
Step 5/7 : RUN apt-get install nginx -y
 ---> Running in dc84f3c2f03c
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  iproute2 krb5-locales libatm1t64 libbpf1 libcap2-bin libelf1t64
  libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libmnl0
  libpam-cap libtirpc-common libtirpc3t64 libxtables12 nginx-common
Suggested packages:
  iproute2-doc python3:any krb5-doc krb5-user fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  iproute2 krb5-locales libatm1t64 libbpf1 libcap2-bin libelf1t64
  libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libmnl0
  libpam-cap libtirpc-common libtirpc3t64 libxtables12 nginx nginx-common
0 upgraded, 18 newly installed, 0 to remove and 0 not upgraded.
Need to get 2733 kB of archives.
After this operation, 8057 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 libelf1t64 amd64 0.190-1.1build4 [57.6 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble/main amd64 libbpf1 amd64 1:1.3.0-2build2 [166 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 libmnl0 amd64 1.0.5-2build1 [12.3 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libkrb5support0 amd64 1.20.1-6ubuntu2.1 [33.6 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libk5crypto3 amd64 1.20.1-6ubuntu2.1 [81.7 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble/main amd64 libkeyutils1 amd64 1.6.3-3build1 [9490 B]
Get:7 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libkrb5-3 amd64 1.20.1-6ubuntu2.1 [347 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libgssapi-krb5-2 amd64 1.20.1-6ubuntu2.1 [143 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble/main amd64 libtirpc-common all 1.3.4+ds-1.1build1 [8094 B]
Get:10 http://archive.ubuntu.com/ubuntu noble/main amd64 libtirpc3t64 amd64 1.3.4+ds-1.1build1 [82.6 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble/main amd64 libxtables12 amd64 1.8.10-3ubuntu2 [35.7 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble/main amd64 libcap2-bin amd64 1:2.66-5ubuntu2 [34.5 kB]
Get:13 http://archive.ubuntu.com/ubuntu noble/main amd64 iproute2 amd64 6.1.0-1ubuntu6 [1120 kB]
Get:14 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 krb5-locales all 1.20.1-6ubuntu2.1 [14.0 kB]
Get:15 http://archive.ubuntu.com/ubuntu noble/main amd64 libatm1t64 amd64 1:2.5.1-5.1build1 [22.9 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble/main amd64 libpam-cap amd64 1:2.66-5ubuntu2 [12.4 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx-common all 1.24.0-2ubuntu7.1 [31.2 kB]
Get:18 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx amd64 1.24.0-2ubuntu7.1 [521 kB]
debconf: delaying package configuration, since apt-utils is not installed
Fetched 2733 kB in 1s (1883 kB/s)
Selecting previously unselected package libelf1t64:amd64.
(Reading database ... 4379 files and directories currently installed.)
Preparing to unpack .../00-libelf1t64_0.190-1.1build4_amd64.deb ...
Unpacking libelf1t64:amd64 (0.190-1.1build4) ...
Selecting previously unselected package libbpf1:amd64.
Preparing to unpack .../01-libbpf1_1%3a1.3.0-2build2_amd64.deb ...
Unpacking libbpf1:amd64 (1:1.3.0-2build2) ...
Selecting previously unselected package libmnl0:amd64.
Preparing to unpack .../02-libmnl0_1.0.5-2build1_amd64.deb ...
Unpacking libmnl0:amd64 (1.0.5-2build1) ...
Selecting previously unselected package libkrb5support0:amd64.
Preparing to unpack .../03-libkrb5support0_1.20.1-6ubuntu2.1_amd64.deb ...
Unpacking libkrb5support0:amd64 (1.20.1-6ubuntu2.1) ...
Selecting previously unselected package libk5crypto3:amd64.
Preparing to unpack .../04-libk5crypto3_1.20.1-6ubuntu2.1_amd64.deb ...
Unpacking libk5crypto3:amd64 (1.20.1-6ubuntu2.1) ...
Selecting previously unselected package libkeyutils1:amd64.
Preparing to unpack .../05-libkeyutils1_1.6.3-3build1_amd64.deb ...
Unpacking libkeyutils1:amd64 (1.6.3-3build1) ...
Selecting previously unselected package libkrb5-3:amd64.
Preparing to unpack .../06-libkrb5-3_1.20.1-6ubuntu2.1_amd64.deb ...
Unpacking libkrb5-3:amd64 (1.20.1-6ubuntu2.1) ...
Selecting previously unselected package libgssapi-krb5-2:amd64.
Preparing to unpack .../07-libgssapi-krb5-2_1.20.1-6ubuntu2.1_amd64.deb ...
Unpacking libgssapi-krb5-2:amd64 (1.20.1-6ubuntu2.1) ...
Selecting previously unselected package libtirpc-common.
Preparing to unpack .../08-libtirpc-common_1.3.4+ds-1.1build1_all.deb ...
Unpacking libtirpc-common (1.3.4+ds-1.1build1) ...
Selecting previously unselected package libtirpc3t64:amd64.
Preparing to unpack .../09-libtirpc3t64_1.3.4+ds-1.1build1_amd64.deb ...
Adding 'diversion of /lib/x86_64-linux-gnu/libtirpc.so.3 to /lib/x86_64-linux-gnu/libtirpc.so.3.usr-is-merged by libtirpc3t64'
Adding 'diversion of /lib/x86_64-linux-gnu/libtirpc.so.3.0.0 to /lib/x86_64-linux-gnu/libtirpc.so.3.0.0.usr-is-merged by libtirpc3t64'
Unpacking libtirpc3t64:amd64 (1.3.4+ds-1.1build1) ...
Selecting previously unselected package libxtables12:amd64.
Preparing to unpack .../10-libxtables12_1.8.10-3ubuntu2_amd64.deb ...
Unpacking libxtables12:amd64 (1.8.10-3ubuntu2) ...
Selecting previously unselected package libcap2-bin.
Preparing to unpack .../11-libcap2-bin_1%3a2.66-5ubuntu2_amd64.deb ...
Unpacking libcap2-bin (1:2.66-5ubuntu2) ...
Selecting previously unselected package iproute2.
Preparing to unpack .../12-iproute2_6.1.0-1ubuntu6_amd64.deb ...
Unpacking iproute2 (6.1.0-1ubuntu6) ...
Selecting previously unselected package krb5-locales.
Preparing to unpack .../13-krb5-locales_1.20.1-6ubuntu2.1_all.deb ...
Unpacking krb5-locales (1.20.1-6ubuntu2.1) ...
Selecting previously unselected package libatm1t64:amd64.
Preparing to unpack .../14-libatm1t64_1%3a2.5.1-5.1build1_amd64.deb ...
Unpacking libatm1t64:amd64 (1:2.5.1-5.1build1) ...
Selecting previously unselected package libpam-cap:amd64.
Preparing to unpack .../15-libpam-cap_1%3a2.66-5ubuntu2_amd64.deb ...
Unpacking libpam-cap:amd64 (1:2.66-5ubuntu2) ...
Selecting previously unselected package nginx-common.
Preparing to unpack .../16-nginx-common_1.24.0-2ubuntu7.1_all.deb ...
Unpacking nginx-common (1.24.0-2ubuntu7.1) ...
Selecting previously unselected package nginx.
Preparing to unpack .../17-nginx_1.24.0-2ubuntu7.1_amd64.deb ...
Unpacking nginx (1.24.0-2ubuntu7.1) ...
Setting up libkeyutils1:amd64 (1.6.3-3build1) ...
Setting up libatm1t64:amd64 (1:2.5.1-5.1build1) ...
Setting up libtirpc-common (1.3.4+ds-1.1build1) ...
Setting up krb5-locales (1.20.1-6ubuntu2.1) ...
Setting up libelf1t64:amd64 (0.190-1.1build4) ...
Setting up libkrb5support0:amd64 (1.20.1-6ubuntu2.1) ...
Setting up libcap2-bin (1:2.66-5ubuntu2) ...
Setting up libmnl0:amd64 (1.0.5-2build1) ...
Setting up libk5crypto3:amd64 (1.20.1-6ubuntu2.1) ...
Setting up libxtables12:amd64 (1.8.10-3ubuntu2) ...
Setting up libkrb5-3:amd64 (1.20.1-6ubuntu2.1) ...
Setting up libpam-cap:amd64 (1:2.66-5ubuntu2) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC entries checked: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.38.2 /usr/local/share/perl/5.38.2 /usr/lib/x86_64-linux-gnu/perl5/5.38 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl-base /usr/lib/x86_64-linux-gnu/perl/5.38 /usr/share/perl/5.38 /usr/local/lib/site_perl) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 8.)
debconf: falling back to frontend: Teletype
Setting up libbpf1:amd64 (1:1.3.0-2build2) ...
Setting up libgssapi-krb5-2:amd64 (1.20.1-6ubuntu2.1) ...
Setting up libtirpc3t64:amd64 (1.3.4+ds-1.1build1) ...
Setting up iproute2 (6.1.0-1ubuntu6) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC entries checked: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.38.2 /usr/local/share/perl/5.38.2 /usr/lib/x86_64-linux-gnu/perl5/5.38 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl-base /usr/lib/x86_64-linux-gnu/perl/5.38 /usr/share/perl/5.38 /usr/local/lib/site_perl) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 8.)
debconf: falling back to frontend: Teletype
Setting up nginx (1.24.0-2ubuntu7.1) ...
invoke-rc.d: unknown initscript, /etc/init.d/nginx not found.
invoke-rc.d: could not determine current runlevel
Setting up nginx-common (1.24.0-2ubuntu7.1) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC entries checked: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.38.2 /usr/local/share/perl/5.38.2 /usr/lib/x86_64-linux-gnu/perl5/5.38 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl-base /usr/lib/x86_64-linux-gnu/perl/5.38 /usr/share/perl/5.38 /usr/local/lib/site_perl) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 8.)
debconf: falling back to frontend: Teletype
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...
Removing intermediate container dc84f3c2f03c
 ---> 80790bd380ac
Step 6/7 : EXPOSE 80
 ---> Running in 876bbda3cd87
Removing intermediate container 876bbda3cd87
 ---> a6e6826859ed
Step 7/7 : CMD [ "nginx", "-g" , "daemon off;"]
 ---> Running in 60a617572eab
Removing intermediate container 60a617572eab
 ---> 8354333cd5a4
Successfully built 8354333cd5a4
Successfully tagged testnginx:0.0.1
root@testpc:~/docker-repo/03.docker-images#
```
Lets view the images and run the images:
```
root@testpc:~# docker images testnginx
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
testnginx    0.0.1     8354333cd5a4   2 minutes ago   133MB
root@testpc:~#
root@testpc:~/docker-repo/03.docker-images# docker run -d -p 8080:80  testnginx:0.0.1
ee5620a3d5f5522af70755704b3eb6f782f004ee29c45b6f7cbd0072c9fc1229
root@testpc:~/docker-repo/03.docker-images#
root@testpc:~/docker-repo/03.docker-images# docker container ls
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS         PORTS                                   NAMES
ee5620a3d5f5   testnginx:0.0.1   "nginx -g 'daemon of…"   10 seconds ago   Up 8 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   nifty_swanson
root@testpc:~/docker-repo/03.docker-images#
```

