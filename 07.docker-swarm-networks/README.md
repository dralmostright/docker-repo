## Docker swarm Networks

Docker Swarm has new Network Driver which we call as overlay Network. THe overlay Network creates a distributed network among multiple Docker hosts and it allow container to communicate inside the single Swarm. If we have multiple Swarm we need to provide multiple networks.

When we initialize a swarm or join a Docker host to an existing swarm, two new networks are created on that Docker host:. 

* Ingress: Ingress is an Overlay Network, which handles control and data traffic related to swarm services. Ingress will only work we are not attaching any user defined overlay network and data traffic related to swarm services. Ingress network will be responsible for communication between the containers on the same node.

* Bridge: Bridge network called docker_gwbridge, which connects the individual Docker node to the other node participating in the swarm and its responsible for the communication between node to node. 

There are few rules for Overlay Networks
1. TCP port 2377 for cluster management communications
2. TCP and UDP port 7946 for communication among nodes
3. UDP port 4789 for overlay network traffic
4. Before creating any overlay network, docker Swarm must be initialized on Node or it should have been joined an existing swarm.

Creating user defined Overlay Network. First we will check ohter networks and create our own networks
```
root@testpc:~# docker network ls | grep "ingress\|docker_gw"
37473ce8a6df   docker_gwbridge   bridge    local
sck4qambmmmu   ingress           overlay   swarm
root@testpc:~# 
root@testpc:~# docker network create -d overlay docknet
6u61wkz785kx5msmyg032t6m1
root@testpc:~# docker network ls | grep docknet
6u61wkz785kx   docknet           overlay   swarm
root@testpc:~# 
```
Now lets create a new service using that network:
```
root@testpc:~# docker service create --name postgress --network docknet -e POSTGRES_PASSWORD=example postgres
wmb7kw0vyxdvdmtwlcby4c44m
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~# docker service ls
ID             NAME              MODE         REPLICAS   IMAGE             PORTS
ffmhs9bui4av   awesome_khorana   replicated   8/8        alpine:latest
wmb7kw0vyxdv   postgress         replicated   1/1        postgres:latest   
root@testpc:~# 
```
Now we will create one more nodeas below
```
root@testpc:~# docker service create --name mydrupal --network docknet -p 80:80 drupal
vsp0rlxyngz2su7vaertghgvc
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~# docker service ls
ID             NAME              MODE         REPLICAS   IMAGE             PORTS
ffmhs9bui4av   awesome_khorana   replicated   8/8        alpine:latest
vsp0rlxyngz2   mydrupal          replicated   1/1        drupal:latest     *:80->80/tcp
wmb7kw0vyxdv   postgress         replicated   1/1        postgres:latest
root@testpc:~#
root@testpc:~#
root@testpc:~# docker service ps mydrupal
ID             NAME         IMAGE           NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
c9a013u8yuwi   mydrupal.1   drupal:latest   testpc3.localdomain   Running         Running 41 seconds ago
root@testpc:~# docker service ps postgress
ID             NAME          IMAGE             NODE      DESIRED STATE   CURRENT STATE           ERROR     PORTS
ncb5xzfp3on9   postgress.1   postgres:latest   testpc    Running         Running 6 minutes ago
root@testpc:~#
```