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
* service : It can be services like database, web etc. where you define its optimal state (network, storage, replicas ..)
* Task: Task is a running container which is part of swarm service and managed by a swarm manager
* Node : A node is an instance of the Docker engine participating in swarm.