## Docker Swarm Traffic Management

Swarm Global Traffic Management is related to "Routing Mesh". Docker Swarm publish Services on some ports and allow outer world to access these services. This is called ingress Routing mesh. As we have seen in our earlier, we were able to access all drupal from all nodes even though the actual drupal container is running on testpc3.
```
root@testpc:~# docker  service ps mydrupal
ID             NAME         IMAGE           NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
c9a013u8yuwi   mydrupal.1   drupal:latest   testpc3.localdomain   Running         Running 31 minutes ago
root@testpc:~# 
```