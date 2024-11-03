## Docker Swarm

Docker Swarm is used to manage the containers, scale containers re-create if they fails/crash. We can upgrade of services by scaling with new upgraded containers. Mainly its a clustering and a scheduling tool for managing Docker engines running on different hosts. Its native tool provided by docker for Orchestration of containers. 

Docker Swarm have two types of Nodes [Master/Worker]. Every swarm must have one manager node desinated as the leader. Swarm is highly available architecture and it uses Raft algorithm. 

### Benifit of Swarm

1. Task Scheduling
2. Load Balancing
3. Rolling Updates
4. Security

### Docker swarm terminology

* Toolkit specific to Docker swarm is ```swarkit```. Docker hosts which run in ```swarm mode``` acts as managers and workes which run swarm services.
* Host : It can be a manager, worker or both
* service : It can be services like database, web etc. where you define its optimal state (network, storage, replicas ..), is the definition of task to execute on the manager or work nodes.
* Task: Task is a running container which is part of swarm service and managed by a swarm manager
* Node : A node is an instance of the Docker engine participating in swarm.

Now lets get the hands dirty:

Lets check for docker swarm status as below:
```
root@testpc:~/docker-repo# docker info | grep Swarm
 Swarm: inactive
root@testpc:~/docker-repo#
```

Initializing the docker swarm
```
root@testpc:~/docker-repo# docker swarm init
Error response from daemon: could not choose an IP address to advertise since this system has multiple addresses on different interfaces (192.168.227.128 on ens33 and 10.0.8.116 on ens38) - specify one with --advertise-addr
root@testpc:~/docker-repo# 
```
The above error is due to our host using multiple ethernet and docker swarm is confused which one to use, hence we will need to explicitly define the ethernet which to user.
```
root@testpc:~/docker-repo# docker swarm init --advertise-addr 192.168.227.128
Swarm initialized: current node (xeruvdjd3sal5z1ybb5qspwi6) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-5eudxzz27gq6dzcjkxz1uo2wo 192.168.227.128:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

root@testpc:~/docker-repo# 
```

Now we have initialized docker swarm manager. To get more info and help about the swarm command we can use the help:
```
root@testpc:~/docker-repo# docker swarm --help

Usage:  docker swarm COMMAND

Manage Swarm

Commands:
  ca          Display and rotate the root CA
  init        Initialize a swarm
  join        Join a swarm as a node and/or manager
  join-token  Manage join tokens
  leave       Leave the swarm
  unlock      Unlock swarm
  unlock-key  Manage the unlock key
  update      Update the swarm

Run 'docker swarm COMMAND --help' for more information on a command.
root@testpc:~/docker-repo# 
```

Docker services:
```
root@testpc:~/docker-repo# docker service --help

Usage:  docker service COMMAND

Manage services

Commands:
  create      Create a new service
  inspect     Display detailed information on one or more services
  logs        Fetch the logs of a service or task
  ls          List services
  ps          List the tasks of one or more services
  rm          Remove one or more services
  rollback    Revert changes to a service's configuration
  scale       Scale one or multiple replicated services
  update      Update a service

Run 'docker service COMMAND --help' for more information on a command.
root@testpc:~/docker-repo#
```

Now lets create a service which pings a google.

This will download the alpine latest image and run the command we have given.
```
root@testpc:~/docker-repo# docker service create alpine ping www.google.com
p2kugrgft5a9ybz8gxurn2jrc
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~/docker-repo# docker service ls
ID             NAME                   MODE         REPLICAS   IMAGE           PORTS
p2kugrgft5a9   condescending_jepsen   replicated   1/1        alpine:latest   
root@testpc:~/docker-repo# 
```
The ID, Name give are name of service not container names. And we can use docker service inspect to know more detail about the service.

Now to determine which container is executing the service we defined by below command:
```
root@testpc:~/docker-repo# docker service ls
ID             NAME                   MODE         REPLICAS   IMAGE           PORTS
p2kugrgft5a9   condescending_jepsen   replicated   1/1        alpine:latest   
root@testpc:~/docker-repo# docker service ps condescending_jepsen
ID             NAME                     IMAGE           NODE      DESIRED STATE   CURRENT STATE           ERROR     PORTS
qjra5frhgktp   condescending_jepsen.1   alpine:latest   testpc    Running         Running 7 minutes ago
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# docker container ps | grep qjra5frhgktp
09e55bcc0bdb   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             condescending_jepsen.1.qjra5frhgktppq7br1lcbgqk3
root@testpc:~/docker-repo# 
```

How to scale up the service:
```
root@testpc:~/docker-repo# docker service update condescending_jepsen --replicas 4
condescending_jepsen
overall progress: 4 out of 4 tasks
1/4: running   [==================================================>]
2/4: running   [==================================================>]
3/4: running   [==================================================>]
4/4: running   [==================================================>]
verify: Service converged
root@testpc:~/docker-repo# docker service ls
ID             NAME                   MODE         REPLICAS   IMAGE           PORTS
p2kugrgft5a9   condescending_jepsen   replicated   4/4        alpine:latest
root@testpc:~/docker-repo#
```
The above command will create 4 replica which will be running our service i.e. ping google.com
```
root@testpc:~/docker-repo# docker service ps condescending_jepsen
ID             NAME                     IMAGE           NODE      DESIRED STATE   CURRENT STATE                ERROR     PORTS
qjra5frhgktp   condescending_jepsen.1   alpine:latest   testpc    Running         Running 11 minutes ago
up37jsvy9vs7   condescending_jepsen.2   alpine:latest   testpc    Running         Running about a minute ago
ohb2jrr3lhcx   condescending_jepsen.3   alpine:latest   testpc    Running         Running about a minute ago
qmuen4zlk09n   condescending_jepsen.4   alpine:latest   testpc    Running         Running about a minute ago
root@testpc:~/docker-repo#
```

And to determine which container are running those services we can check using below:
```
root@testpc:~/docker-repo# docker container ps | grep `docker service ps condescending_jepsen | awk  '{ print $1 }' | grep -v 'ID' | awk 'ORS="\|"'`
CONTAINER ID   IMAGE           COMMAND                 CREATED          STATUS          PORTS     NAMES
d7ca5b370392   alpine:latest   "ping www.google.com"   9 minutes ago    Up 9 minutes              condescending_jepsen.3.ohb2jrr3lhcxh7qc11qkx3sqw       
ae61b5485176   alpine:latest   "ping www.google.com"   9 minutes ago    Up 9 minutes              condescending_jepsen.2.up37jsvy9vs7kqgg6fask4y7c       
7fa93ffa6b60   alpine:latest   "ping www.google.com"   9 minutes ago    Up 9 minutes              condescending_jepsen.4.qmuen4zlk09nkkc68r2wnj1do       
09e55bcc0bdb   alpine:latest   "ping www.google.com"   19 minutes ago   Up 19 minutes             condescending_jepsen.1.qjra5frhgktppq7br1lcbgqk3       
root@testpc:~/docker-repo#
```

Now lets do a sample how docker swarm handles high availability:
```
root@testpc:~/docker-repo# docker service ps condescending_jepsen
ID             NAME                     IMAGE           NODE      DESIRED STATE   CURRENT STATE            ERROR     PORTS
qjra5frhgktp   condescending_jepsen.1   alpine:latest   testpc    Running         Running 21 minutes ago
up37jsvy9vs7   condescending_jepsen.2   alpine:latest   testpc    Running         Running 11 minutes ago
ohb2jrr3lhcx   condescending_jepsen.3   alpine:latest   testpc    Running         Running 11 minutes ago
qmuen4zlk09n   condescending_jepsen.4   alpine:latest   testpc    Running         Running 11 minutes ago
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# docker container rm -f condescending_jepsen.3.ohb2jrr3lhcxh7qc11qkx3sqw
condescending_jepsen.3.ohb2jrr3lhcxh7qc11qkx3sqw
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# docker service ps condescending_jepsen
ID             NAME                         IMAGE           NODE      DESIRED STATE   CURRENT STATE            ERROR                         PORTS
qjra5frhgktp   condescending_jepsen.1       alpine:latest   testpc    Running         Running 21 minutes ago
up37jsvy9vs7   condescending_jepsen.2       alpine:latest   testpc    Running         Running 12 minutes ago
wnj7lzjhsk6t   condescending_jepsen.3       alpine:latest   testpc    Running         Running 6 seconds ago
ohb2jrr3lhcx    \_ condescending_jepsen.3   alpine:latest   testpc    Shutdown        Failed 12 seconds ago    "task: non-zero exit (137)"   
qmuen4zlk09n   condescending_jepsen.4       alpine:latest   testpc    Running         Running 12 minutes ago
root@testpc:~/docker-repo# 
```
From above we can see even we removed one container the swarm is automatcally bringing up the another one.

To stop the service either we need to sacle it to 0 or remove the servie:
```
root@testpc:~/docker-repo# docker service rm condescending_jepsen
condescending_jepsen
root@testpc:~/docker-repo#
root@testpc:~/docker-repo# docker container ls
CONTAINER ID   IMAGE           COMMAND                 CREATED          STATUS          PORTS     NAMES
d6603dc72b7e   alpine:latest   "ping www.google.com"   6 minutes ago    Up 6 minutes              condescending_jepsen.3.wnj7lzjhsk6t5qaskan2ed3hq       
ae61b5485176   alpine:latest   "ping www.google.com"   18 minutes ago   Up 18 minutes             condescending_jepsen.2.up37jsvy9vs7kqgg6fask4y7c       
7fa93ffa6b60   alpine:latest   "ping www.google.com"   18 minutes ago   Up 18 minutes             condescending_jepsen.4.qmuen4zlk09nkkc68r2wnj1do       
09e55bcc0bdb   alpine:latest   "ping www.google.com"   28 minutes ago   Up 28 minutes             condescending_jepsen.1.qjra5frhgktppq7br1lcbgqk3       
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@testpc:~/docker-repo# 
```

Now we will create three more hosts for testing of Docker swarm and create passwordless connection for our flexibility:
1. testpc
2. testpc1
3. testpc2
4. testpc3

Lets check the docker swarm in each newly added nodes:
```
root@testpc:~# for i in 1 2 3
> do
> ssh testpc$i docker info | grep Swarm
> done
 Swarm: inactive
 Swarm: inactive
 Swarm: inactive
root@testpc:~#
```

Now we will build clusters and add nodes:
```
root@testpc:~# docker node --help

Usage:  docker node COMMAND

Manage Swarm nodes

Commands:
  demote      Demote one or more nodes from manager in the swarm
  inspect     Display detailed information on one or more nodes
  ls          List nodes in the swarm
  promote     Promote one or more nodes to manager in the swarm
  ps          List tasks running on one or more nodes, defaults to current node
  rm          Remove one or more nodes from the swarm
  update      Update a node

Run 'docker node COMMAND --help' for more information on a command.
root@testpc:~# 
```
We can add nodes in docker swarm using the tokens and if we want to get tokens as below:
```
root@testpc:~# docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-cs1taapbb0vr8a7iia9mqtlzd 192.168.227.128:2377

root@testpc:~# 
```
Now lets add the node one by one:
```
root@testpc1:~# docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-cs1taapbb0vr8a7iia9mqtlzd 192.168.227.128:2377
This node joined a swarm as a manager.
root@testpc1:~# 
```

If Docker swarm is initialized you may get below error and need to leave the swram forced follow:
```
root@testpc2:~# docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-cs1taapbb0vr8a7iia9mqtlzd 192.168.227.128:2377
Error response from daemon: This node is already part of a swarm. Use "docker swarm leave" to leave this swarm and join another one.
root@testpc2:~# docker swarm leave --force
Node left the swarm.
root@testpc2:~# docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-cs1taapbb0vr8a7iia9mqtlzd 192.168.227.128:2377
This node joined a swarm as a manager.
root@testpc2:~# 
root@testpc3:~# docker swarm join --token SWMTKN-1-5v3ijd1h6uo602kv1sfeh2iauifs24sv9kd5z6lxlav02k8u4g-cs1taapbb0vr8a7iia9mqtlzd 192.168.227.128:2377
This node joined a swarm as a manager.
root@testpc3:~# 
```
Now lets see the nodes info:
```
root@testpc:~# docker node ls
ID                            HOSTNAME              STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xeruvdjd3sal5z1ybb5qspwi6 *   testpc                Ready     Active         Leader           20.10.17
8ijx60ucfzwb13iewk9t9gylj     testpc1.localdomain   Ready     Active         Reachable        20.10.17
eoqu84doijqaxz1i4hznznjgz     testpc2.localdomain   Ready     Active         Reachable        20.10.17
tecz6jl64zcjs7lwsn9x2at9m     testpc3.localdomain   Ready     Active         Reachable        20.10.17
root@testpc:~# 
```
Now we will create docker service same as above we created:
```
root@testpc:~# docker service create --replicas 8 alpine ping www.google.com
ffmhs9bui4av3jxn780q9dpoe
overall progress: 8 out of 8 tasks
1/8: running   [==================================================>]
2/8: running   [==================================================>]
3/8: running   [==================================================>]
4/8: running   [==================================================>]
5/8: running   [==================================================>]
6/8: running   [==================================================>]
7/8: running   [==================================================>]
8/8: running   [==================================================>]
verify: Service converged
root@testpc:~# 
root@testpc:~# docker service ls
ID             NAME              MODE         REPLICAS   IMAGE           PORTS
ffmhs9bui4av   awesome_khorana   replicated   8/8        alpine:latest
root@testpc:~# docker service ps awesome_khorana
ID             NAME                IMAGE           NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
lcx3lnkqrcbg   awesome_khorana.1   alpine:latest   testpc2.localdomain   Running         Running 37 seconds ago
zo69tb8ele93   awesome_khorana.2   alpine:latest   testpc3.localdomain   Running         Running 37 seconds ago
mp09lgri4tbl   awesome_khorana.3   alpine:latest   testpc                Running         Running 34 seconds ago
nzua7jrxl460   awesome_khorana.4   alpine:latest   testpc1.localdomain   Running         Running 37 seconds ago
thmbmeek3qoe   awesome_khorana.5   alpine:latest   testpc2.localdomain   Running         Running 37 seconds ago
xr10rx76v10w   awesome_khorana.6   alpine:latest   testpc3.localdomain   Running         Running 37 seconds ago
kd5waylolf8s   awesome_khorana.7   alpine:latest   testpc                Running         Running 34 seconds ago
04s4avqvxqaj   awesome_khorana.8   alpine:latest   testpc1.localdomain   Running         Running 37 seconds ago
root@testpc:~#
```

In above we can see each node has created 2 container on each nodes.
```
root@testpc:~# for i in "" 1 2 3; do ssh testpc$i docker container ls; done
CONTAINER ID   IMAGE           COMMAND                 CREATED         STATUS         PORTS     NAMES
d2848dab28e5   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.7.kd5waylolf8skytc7947bgoej
480c2bf60a73   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.3.mp09lgri4tblhfja648iqjq2y
CONTAINER ID   IMAGE           COMMAND                 CREATED         STATUS         PORTS     NAMES
e1d1b866bef1   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.4.nzua7jrxl460nz4ajga90yspp
91135393ac9f   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.8.04s4avqvxqajdbf1by2u9jmz1
CONTAINER ID   IMAGE           COMMAND                 CREATED         STATUS         PORTS     NAMES
9939c59d005c   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.1.lcx3lnkqrcbgj2szj3guw2ira
39d7e512a060   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.5.thmbmeek3qoeuxja5j6hksraa
CONTAINER ID   IMAGE           COMMAND                 CREATED         STATUS         PORTS     NAMES
14523c9d24d4   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.2.zo69tb8ele93yp7ii91tliqay
5a881ede34e9   alpine:latest   "ping www.google.com"   8 minutes ago   Up 8 minutes             awesome_khorana.6.xr10rx76v10wrkj74316ud4g6
root@testpc:~#
```