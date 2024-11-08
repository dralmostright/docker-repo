## Docker Stack

Stack is a group of interrelated services that share dependencies and can be orchestrated and scaled together. A single stack is capable of defining and coordinating the functionality of an entire application. And there could be complex application which might have multiple stacks as well.

Docker Stack uses Compose's YAML format and complements the swarm-specific properties for service deployments.

Now we will build stack from dockerfile to compose to docker swarm to docker stack.

Below is the docker image of which will run web server based on flask.
```
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```

And our python file ```app.py``` will be below:
```
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```
The requirements file will be like below:
```
Flask
Redis
```
And the docker-compose file looks like below:
```
version: "3"
services:
  # Service Name Defined as web
  web:
    image: web:v1 
    # Command used to deploy the Service
    deploy:
      # Run 5 instances of that image as a service called web
      replicas: 5
      resources:
        # Limiting each one to use, at most, 10% of a single core of CPU time and 50MB of RAM.
        limits:
          cpus: "0.1"
          memory: 50M
      # Immediately restart containers if one fails.     
      restart_policy:
        condition: on-failure
    # Map port 4000 on the host to web’s port 80.    
    ports:
      - "4000:80"
    # Define default network  
    networks:
      - webnet
networks:
  webnet:
```
What will above yml file do:
1. check for image web with latest tag
2. Run 5 instances of the service called web
3. Limit each service to 10% CPU and 50M of RAM
4. Restart container immediately if it fails
6. Instruc web's containers to share port 80 to 4000 outsiders via load-balanced network called webnet
7. Define the webnet network with the default settings which is a load balanced overlay network, and it will be created first and used by the image.

Now lets build the image:
```
root@testpc:~/docker-repo/09.docker-stacks/app# docker build --tag=web:v1 .
Sending build context to Docker daemon  6.656kB
Step 1/7 : FROM python:2.7-slim
2.7-slim: Pulling from library/python
123275d6e508: Pull complete
dd1cd6637523: Pull complete
0c4e6d630f2c: Pull complete
13e9cd8f0ea1: Pull complete
Digest: sha256:6c1ffdff499e29ea663e6e67c9b6b9a3b401d554d2c9f061f9a45344e3992363
Status: Downloaded newer image for python:2.7-slim
 ---> eeb27ee6b893
Step 2/7 : WORKDIR /app
 ---> Running in 56562eb9c685
Removing intermediate container 56562eb9c685
 ---> 9e06c3c5d3f7
Step 3/7 : COPY . /app
 ---> 86dacda3b823
Step 4/7 : RUN pip install --trusted-host pypi.python.org -r requirements.txt
 ---> Running in f172417eae57
DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. A future version of pip will drop support for Python 2.7. More details about Python 2 support in pip, can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
Collecting Flask
  Downloading Flask-1.1.4-py2.py3-none-any.whl (94 kB)
Collecting Redis
  Downloading redis-3.5.3-py2.py3-none-any.whl (72 kB)
Collecting click<8.0,>=5.1
  Downloading click-7.1.2-py2.py3-none-any.whl (82 kB)
Collecting Werkzeug<2.0,>=0.15
  Downloading Werkzeug-1.0.1-py2.py3-none-any.whl (298 kB)
Collecting Jinja2<3.0,>=2.10.1
  Downloading Jinja2-2.11.3-py2.py3-none-any.whl (125 kB)
Collecting itsdangerous<2.0,>=0.24
  Downloading itsdangerous-1.1.0-py2.py3-none-any.whl (16 kB)
Collecting MarkupSafe>=0.23
  Downloading MarkupSafe-1.1.1-cp27-cp27mu-manylinux1_x86_64.whl (24 kB)
Installing collected packages: click, Werkzeug, MarkupSafe, Jinja2, itsdangerous, Flask, Redis
Successfully installed Flask-1.1.4 Jinja2-2.11.3 MarkupSafe-1.1.1 Redis-3.5.3 Werkzeug-1.0.1 click-7.1.2 itsdangerous-1.1.0
WARNING: You are using pip version 20.0.2; however, version 20.3.4 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
Removing intermediate container f172417eae57
 ---> 4388309d6068
Step 5/7 : EXPOSE 80
 ---> Running in 5fb82a3c143b
Removing intermediate container 5fb82a3c143b
 ---> c48b3911e2d3
Step 6/7 : ENV NAME World
 ---> Running in 5165b78cafe0
Removing intermediate container 5165b78cafe0
 ---> 5541c0a1e6f8
Step 7/7 : CMD ["python", "app.py"]
 ---> Running in ee30a9822dad
Removing intermediate container ee30a9822dad
 ---> 09dbfea10f44
Successfully built 09dbfea10f44
Successfully tagged web:v1
root@testpc:~/docker-repo/09.docker-stacks/app# 
```

Lets view the image in our local repository:
```
root@testpc:~/docker-repo/09.docker-stacks/app# docker images | grep -B 1 web
REPOSITORY                              TAG        IMAGE ID       CREATED          SIZE
web                                     v1         09dbfea10f44   58 seconds ago   159MB
root@testpc:~/docker-repo/09.docker-stacks/app#
```
Now lets deploy the docker stack:
```
root@testpc:~# docker stack --help

Usage:  docker stack [OPTIONS] COMMAND

Manage Docker stacks

Options:
      --orchestrator string   Orchestrator to use (swarm|kubernetes|all)

Commands:
  deploy      Deploy a new stack or update an existing stack
  ls          List stacks
  ps          List the tasks in the stack
  rm          Remove one or more stacks
  services    List the services in the stack

Run 'docker stack COMMAND --help' for more information on a command.
root@testpc:~# 
root@testpc:~/docker-repo/09.docker-stacks/app# docker stack deploy -c docker-compose.yml webapp
Creating network webapp_webnet
Creating service webapp_web
root@testpc:~/docker-repo/09.docker-stacks/app# 
```
As shown above network and service are created with prefix webapp.
```
root@testpc:~/docker-repo/09.docker-stacks/app# docker network ls | grep "NETWORK\|webapp"
NETWORK ID     NAME              DRIVER    SCOPE
skyou62m6pbw   webapp_webnet     overlay   swarm
root@testpc:~/docker-repo/09.docker-stacks/app# 
root@testpc:~/docker-repo/09.docker-stacks/app# docker stack ls
NAME      SERVICES   ORCHESTRATOR
webapp    1          Swarm
root@testpc:~/docker-repo/09.docker-stacks/app# 
```
A single container running in this Service is called Task. So single Service can execute multiple Tasks.


Now if we check the services running under the docker stack we created we can use below:
```
root@testpc:~/docker-repo/09.docker-stacks/app# docker stack services webapp
ID             NAME         MODE         REPLICAS   IMAGE     PORTS
ojrrn3btkv2c   webapp_web   replicated   5/5        web:v1    *:4000->80/tcp
root@testpc:~/docker-repo/09.docker-stacks/app# 
root@testpc:~/docker-repo/09.docker-stacks/app# docker service ps  webapp_web
ID             NAME               IMAGE     NODE                  DESIRED STATE   CURRENT STATE             ERROR                     PORTS
l0vk4ex09c34   webapp_web.1       web:v1    testpc                Running         Running 13 minutes ago
t5d9xqkcs8v9    \_ webapp_web.1   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
0mw3supzz2h2    \_ webapp_web.1   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
wgz1yu0dxf9y    \_ webapp_web.1   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
n36xizgd3rku    \_ webapp_web.1   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
n4qycei5cyad   webapp_web.2       web:v1    testpc                Running         Running 13 minutes ago
jd1teke56acm    \_ webapp_web.2   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
o99tkuhqrr03    \_ webapp_web.2   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
hmhwl2uiqnr2    \_ webapp_web.2   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
gg6inh81h8l0    \_ webapp_web.2   web:v1    testpc1.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
i59au9o4hiqg   webapp_web.3       web:v1    testpc                Running         Running 13 minutes ago
z5mipof90yjy    \_ webapp_web.3   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
eipd4e8e0gpi    \_ webapp_web.3   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
pzo5s9imnpnx    \_ webapp_web.3   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"   
pzsrzpgby2ve    \_ webapp_web.3   web:v1    testpc1.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
nvzr1nsv4q1q   webapp_web.4       web:v1    testpc                Running         Running 13 minutes ago
tpuvo37rj81z    \_ webapp_web.4   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
grh0o5uqvj1i    \_ webapp_web.4   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
8yutgsofnew0    \_ webapp_web.4   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
snvtfuuy4slc    \_ webapp_web.4   web:v1    testpc1.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
o5em8a4rybf4   webapp_web.5       web:v1    testpc                Running         Running 14 minutes ago
1ucivr98vbns    \_ webapp_web.5   web:v1    testpc3.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
m0kdvyw2k3hs    \_ webapp_web.5   web:v1    testpc2.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
xknaktn6slgm    \_ webapp_web.5   web:v1    testpc1.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
l420sun298m8    \_ webapp_web.5   web:v1    testpc1.localdomain   Shutdown        Rejected 14 minutes ago   "No such image: web:v1"
root@testpc:~/docker-repo/09.docker-stacks/app#
```
As we can see its not able to start on other services, that because we don't have image created on other nodes.