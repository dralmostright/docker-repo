Containers may need to communicate among other container running on same host or other hots and this can be done. Each Container connect to virtual private network call 'bridge' which is the default network driver of docker. All Containers on same bridge can communicate each other without -p (Port) 
* Docker Network is easy to plugged-in in Containers.
* Users is allow to create Multiple VPN.
* Create Multiple Rules for Single Network.
* Attach Multiple Containers to One Network and Attach single container to more than One Network or no need to attach any network to container.

List port the container listening to :
```
root@testpc:~# docker container port nginx80
80/tcp -> 0.0.0.0:80
80/tcp -> :::80
root@testpc:~#
```
The container is listening to port 80 from anywhere

Now checking the ip address of the docker:
```
root@testpc:~# docker container inspect -f '{{.NetworkSettings.IPAddress}}' nginx80
172.17.0.2
root@testpc:~#
```
inspect will share us data in json format and with help of -f flag we can filter the results.

Show all networks in docker containers:
```
root@testpc:~# docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
07edd7f45c33   bridge       bridge    local
8e0ff381a56e   docker_net   bridge    local
03eefb956fe3   host         host      local
adb864e44803   none         null      local
root@testpc:~#

root@testpc:~# docker network ls -f driver=bridge
NETWORK ID     NAME         DRIVER    SCOPE
07edd7f45c33   bridge       bridge    local
8e0ff381a56e   docker_net   bridge    local
root@testpc:~#
```
And using -f flag we can filter the results using ID, Name, Driver, Scope

Additionally we can inspect each network as below:
```
root@testpc:~# docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "07edd7f45c338ffea5667fcfcd37cd2f2408aee94d43ee9478e62e4b7c34c91f",
        "Created": "2024-10-28T00:44:03.117165722+05:45",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "a4b6fe4536ab6d15527081c4a4a42cfc9402978d3c29ce0ea533cee19a32fe6f": {
                "Name": "nginx80",
                "EndpointID": "a5c22b0f2467d0700ada30fc5efeedafdc097bc742bb0aa0558dfd40ef4b4b1d",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
root@testpc:~#
```

Create Network for docker:
```
root@testpc:~# docker network create dockernet
e0e64fb87c893d476c65a9cb139c802ddcc0248fffa1886fd09ec752a505de88
root@testpc:~# docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
07edd7f45c33   bridge       bridge    local
8e0ff381a56e   docker_net   bridge    local
e0e64fb87c89   dockernet    bridge    local
03eefb956fe3   host         host      local
adb864e44803   none         null      local
root@testpc:~#
```
Above command creates 'bridge' network by default 

```
root@testpc:~# docker network inspect dockernet
[
    {
        "Name": "dockernet",
        "Id": "e0e64fb87c893d476c65a9cb139c802ddcc0248fffa1886fd09ec752a505de88",
        "Created": "2024-10-28T05:59:23.496927148+05:45",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.19.0.0/16",
                    "Gateway": "172.19.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
root@testpc:~# docker network inspect -f "{{.Name}} {{.Containers}}" dockernet
dockernet map[]
root@testpc:~#
```

### Connect Network with Container
A container can by connected to a network by container name or by ID. After connection the container can communicate with other containers in the same network.

```
root@testpc:~# docker container ls
CONTAINER ID   IMAGE     COMMAND                  CREATED       STATUS       PORTS                               NAMES
a4b6fe4536ab   nginx     "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:80->80/tcp, :::80->80/tcp   nginx80
root@testpc:~#
root@testpc:~#
root@testpc:~# docker container run -d --name mynginx -p 8082:80 --network dockernet nginx
406e32948fc274e8307d176582ad1664eb0390bd753796ce7c6ceaa9ef186a50
root@testpc:~#
root@testpc:~# docker container ls
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                   NAMES
406e32948fc2   nginx     "/docker-entrypoint.…"   12 seconds ago   Up 11 seconds   0.0.0.0:8082->80/tcp, :::8082->80/tcp   mynginx
a4b6fe4536ab   nginx     "/docker-entrypoint.…"   3 hours ago      Up 3 hours      0.0.0.0:80->80/tcp, :::80->80/tcp       nginx80
root@testpc:~#
root@testpc:~# docker network inspect -f "{{.Name}} {{.Containers}}" dockernet
dockernet map[406e32948fc274e8307d176582ad1664eb0390bd753796ce7c6ceaa9ef186a50:{mynginx 3896412f2c990d83862ac6da59be320e0bf4764774114aef7326c289b0f5d553 02:42:ac:13:00:02 172.19.0.2/16 }]
root@testpc:~#
root@testpc:~# docker network inspect -f "{{.Name}} {{.IPAM.Config}}" dockernet
dockernet [{172.19.0.0/16  172.19.0.1 map[]}]
root@testpc:~#
```

Now lets connect then newly created network to the running container:
```
root@testpc:~# docker network connect dockernet nginx80
root@testpc:~#
root@testpc:~# docker network inspect dockernet | grep 'Mac\|IPv4'
                "MacAddress": "02:42:ac:13:00:02",
                "IPv4Address": "172.19.0.2/16",
                "MacAddress": "02:42:ac:13:00:03",
                "IPv4Address": "172.19.0.3/16",
root@testpc:~#
root@testpc:~# docker container inspect nginx80 | grep NetworkID
                    "NetworkID": "07edd7f45c338ffea5667fcfcd37cd2f2408aee94d43ee9478e62e4b7c34c91f",
                    "NetworkID": "e0e64fb87c893d476c65a9cb139c802ddcc0248fffa1886fd09ec752a505de88",
root@testpc:~#
```
