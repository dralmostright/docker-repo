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

Routing mesh listens on the published port for any IP address assigned to the node. Now lets inspect our service to see:
```
root@testpc:~# docker service inspect --format="{{json .Endpoint.Spec.Ports}}" mydrupal
[{"Protocol":"tcp","TargetPort":80,"PublishedPort":80,"PublishMode":"ingress"}]
root@testpc:~# 
```

Now we will create a docker swarm with following service:
1. vote front-end that enables a user to choose between a cat and dog
2. redis: database where votes are stored
3. worker: service that get votes from redis and store the results in postgres database
4. db: the postgres database in which vote's results are stored
5. result: front-end displaying the results of the vote

Creating db service:
```
root@testpc:~# docker service create --name db --network docknet -e POSTGRES_PASSWORD=example postgres
ujaniddchfu295w5ewcedltk2
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~# 
```
Creating vote service:
```
root@testpc:~# docker service create --name vote -p 5000:80 --network docknet --replicas 3 dockersamples/examplevotingapp_vote:before 
ep10y45tuotj1c150icaz9cm3
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged
root@testpc:~#
```
Creating redis service:
```
root@testpc:~# docker service create --name redis --network docknet --replicas 3 redis:3.2
xx5h3h774vz6fp726pc5fi7wi
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged
root@testpc:~# 
```
Creating worker service:
```
root@testpc:~# docker service create --name worker --network docknet dockersamples/examplevotingapp_worker:latest 
mfmzg7wc5p77rs624bck4d6hk
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~# 
```
Creating Result Service:
```
root@testpc:~# docker service create --name result -p 5001:80 --network docknet dockersamples/examplevotingapp_result:before
hbnflx8nbvoceesp6jf3sikld
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~# 
```
Lets review the services
```
root@testpc:~# docker service ls
ID             NAME      MODE         REPLICAS   IMAGE                                          PORTS
ujaniddchfu2   db        replicated   1/1        postgres:latest
xx5h3h774vz6   redis     replicated   3/3        redis:3.2
hbnflx8nbvoc   result    replicated   1/1        dockersamples/examplevotingapp_result:before   *:5001->80/tcp
ep10y45tuotj   vote      replicated   3/3        dockersamples/examplevotingapp_vote:before     *:5000->80/tcp
mfmzg7wc5p77   worker    replicated   1/1        dockersamples/examplevotingapp_worker:latest   
root@testpc:~# 
```
Now lets see where those containers are running:
```
root@testpc:~# for i in `docker service ls | awk '{ print $1 }' | grep -v ID | awk 'ORS=" "'`; do docker service ps $i;echo " "; done
ID             NAME      IMAGE             NODE      DESIRED STATE   CURRENT STATE            ERROR     PORTS
wpoejj4sq1hd   db.1      postgres:latest   testpc    Running         Running 22 minutes ago

ID             NAME      IMAGE       NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
pht2asldvc24   redis.1   redis:3.2   testpc1.localdomain   Running         Running 15 minutes ago
k3vj5dsab7cq   redis.2   redis:3.2   testpc3.localdomain   Running         Running 15 minutes ago
fkxh9fsskd2k   redis.3   redis:3.2   testpc                Running         Running 15 minutes ago
 
ID             NAME       IMAGE                                          NODE      DESIRED STATE   CURRENT STATE           ERROR     PORTS
vqseoq8hzsdl   result.1   dockersamples/examplevotingapp_result:before   testpc    Running         Running 7 minutes ago

ID             NAME      IMAGE                                        NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
ry501b8338u1   vote.1    dockersamples/examplevotingapp_vote:before   testpc3.localdomain   Running         Running 17 minutes ago
bvw1hlmoqx5o   vote.2    dockersamples/examplevotingapp_vote:before   testpc2.localdomain   Running         Running 17 minutes ago
rhhoejmxwgo3   vote.3    dockersamples/examplevotingapp_vote:before   testpc1.localdomain   Running         Running 17 minutes ago

ID             NAME       IMAGE                                          NODE                  DESIRED STATE   CURRENT STATE            ERROR     PORTS
lo9auxpouzlv   worker.1   dockersamples/examplevotingapp_worker:latest   testpc2.localdomain   Running         Running 13 minutes ago

root@testpc:~#
```