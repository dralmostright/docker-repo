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
