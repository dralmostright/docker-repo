## Docker Swarm Traffic Management

Swarm Global Traffic Management is related to "Routing Mesh". Docker Swarm publish Services on some ports and allow outer world to access these services. This is called ingress Routing mesh. As we have seen in our earlier, we were able to access all drupal from all nodes even though the actual drupal container is running on testpc3.
```
root@testpc:~# docker  service ps mydrupal
ID             NAME         IMAGE           NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
c9a013u8yuwi   mydrupal.1   drupal:latest   testpc3.localdomain   Running         Running 31 minutes ago
root@testpc:~# 
```
In swarm the routing mesh enables each node to accept connections on published ports from any service running in the swarm, even if there's no taks is running on the node. The routing mesh routes all incoming requests to published ports on available nodes to an active container and its doing via Docker Swarm Load balancer.

Basically we ran ```docker service create --name mydrupal --network docknet -p 80:80 durpal``` i.e. <strong> -p <published_port>:<container_port> </strong> where:
* <published_port> : the port where the swarm makes the service available to outer world
* <container_port> : is port where the container listens the traffic.

Routing mesh listens on the published port for any IP address assigned to the node.