## Docker swarm Networks

Docker Swarm has new Network Driver which we call as overlay Network. THe overlay Network creates a distributed network among multiple Docker hosts and it allow container to communicate inside the single Swarm. If we have multiple Swarm we need to provide multiple networks.

When we initialize a swarm or join a Docker host to an existing swarm, two new networks are created on that Docker host:. 

* Ingress: Ingress is an Overlay Network, which handles control and data traffic related to swarm services. Ingress will only work we are not attaching any user defined overlay network and data traffic related to swarm services. Ingress network will be responsible for communication between the containers on the same node.

* Bridge: Bridge network called docker_gwbridge, which connects the individual Docker node to the other node participating in the swarm and its responsible for the communication between node to node. 

There are few rules for Overlay Networks
1. TCP port 2377 for cluster management communications
2. TCP and UDP port 7946 for communication among nodes
3. UDP port 4789 for overlay network traffic