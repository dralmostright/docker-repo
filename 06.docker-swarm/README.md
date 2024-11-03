## Docker Swarm

Docker Swarm is used to manage the containers, scale containers re-create if they fails/crash. We can upgrade of services by scaling with new upgraded containers. Mainly its a clustering and a scheduling tool for managing Docker engines running on different hosts. Its native tool provided by docker for Orchestration of containers. 

Docker Swarm have two types of Nodes [Master/Worker]. Every swarm must have one manager node desinated as the leader. Swarm is highly available architecture and it uses Raft algorithm. 