## Managing Sensitive data with docker swarm: Docker Swarm Secrets

A secred be any sensetive data like password, ssh private keys, SSL certificate or any piece of data that should not be transmitted over a network or store unencrypted in a Dockerfile or in your application's source code. Docker secrets can help on on this. Docker centrally Manage this Data and sotre them in their own disk in encrypted form and send to only container that need it and only the granted container can access the granted secrets. DOcker Secrets are only available in Docker Swarm not in standalone. During transmission on network it will go through encrypted.

When a new secret is added to a Swarm cluster, this secret is send to a manager using a TLS connection. When we have multiple managers, RAFT manage the secrets on all managers.

Containers work on mounted decrypted secrets, which store at /run/secrets/<secret_name> in containers.

And user can manipulated secrets at any time. When a container task stops running, the decrypted secrets shared to it are unmounted from the in-memory filesystem for that container and flushed from the node's memory.

### Cerating Secrets
```
root@testpc:~/docker-repo# docker secret --help

Usage:  docker secret COMMAND

Manage Docker secrets

Commands:
  create      Create a secret from a file or STDIN as content
  inspect     Display detailed information on one or more secrets
  ls          List secrets
  rm          Remove one or more secrets

Run 'docker secret COMMAND --help' for more information on a command.
root@testpc:~/docker-repo#
```

Ways to create Secret:
By File:
```docker secret create <secret_name> <file_name>```
By CLI:
```echo "secret string" | docker secret create <secret_name> -```
Now lets do a demo, we will create a directory first and a file containing the secret:
```
root@testpc:~/docker-repo/10.docker-swarm-secrets# mkdir dockSecrets
root@testpc:~/docker-repo/10.docker-swarm-secrets# cd dockSecrets/
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# echo "Hello@2025" > sercrets.txt        
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# cat sercrets.txt
Hello@2025
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets#
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# docker secret create db_pass sercrets.txt 
qje6jcyprzprfhvbmhjo1bv5n
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# 
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# docker secret create db_pass sercrets.txt 
qje6jcyprzprfhvbmhjo1bv5n
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# echo "dralmotright" | docker secret create dbuser -
ybt6ggxqzimaie22b41w1r5a5
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# docker secret ls
ID                          NAME      DRIVER    CREATED              UPDATED
qje6jcyprzprfhvbmhjo1bv5n   db_pass             About a minute ago   About a minute ago
ybt6ggxqzimaie22b41w1r5a5   dbuser              6 seconds ago        6 seconds ago
root@testpc:~/docker-repo/10.docker-swarm-secrets/dockSecrets# 
```

How to inspect the secret:
```
root@testpc:~# docker secret inspect db_pass
[
    {
        "ID": "qje6jcyprzprfhvbmhjo1bv5n",
        "Version": {
            "Index": 4302
        },
        "CreatedAt": "2024-11-08T03:59:03.462854512Z",
        "UpdatedAt": "2024-11-08T03:59:03.462854512Z",
        "Spec": {
            "Name": "db_pass",
            "Labels": {}
        }
    }
]
root@testpc:~# 
```

How to remove the secrets:
```
root@testpc:~/docker-repo# docker secret ls
ID                          NAME      DRIVER    CREATED          UPDATED
qje6jcyprzprfhvbmhjo1bv5n   db_pass             16 minutes ago   16 minutes ago
ybt6ggxqzimaie22b41w1r5a5   dbuser              15 minutes ago   15 minutes ago
root@testpc:~/docker-repo# docker secret rm db_pass 
db_pass
root@testpc:~/docker-repo# docker secret rm dbuser 
dbuser
root@testpc:~/docker-repo# docker secret ls
ID        NAME      DRIVER    CREATED   UPDATED
root@testpc:~/docker-repo# 
```

Now lets cerate a postgres service with secrets:
```docker service create --name <service_name> --secret <username_secret> --secret <pass_secret> -e POSTGRES_PASSWORD_FILE=/run/secrets/<pass_secret> -e POSTGRES_USER_FILE=/run/secrets/<user_secret> <IMAGE>:TAG```
```
root@testpc:~/docker-repo# docker service create --name postgress --secret dbuser --secret db_pass -e POSTGRES_PASSWORD_FILE=/run/secrets/db_
pass -e POSTGRES_USER_FILE=/run/secrets/dbuser postgres
qsqea3ko4pryqws0equleorkp
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
root@testpc:~/docker-repo# 
root@testpc:~/docker-repo# docker service ls | grep -B 2 postgress
ID             NAME                      MODE         REPLICAS   IMAGE                                          PORTS
qsqea3ko4pry   postgress                 replicated   1/1        postgres:latest
root@testpc:~/docker-repo#
root@testpc:~/docker-repo# docker service ps postgress
ID             NAME          IMAGE             NODE                  DESIRED STATE   CURRENT STATE                ERROR     PORTS
uj32nx5cxb4q   postgress.1   postgres:latest   testpc1.localdomain   Running         Running about a minute ago
root@testpc:~/docker-repo#
root@testpc1:~# docker exec -it postgress.1.uj32nx5cxb4qsfw6r5wul62io bash
root@f9e8bc57a46c:/# cat /run/secrets/db
db_pass  dbuser   
root@f9e8bc57a46c:/# cat /run/secrets/dbuser 
dralmotright
root@f9e8bc57a46c:/# cat /run/secrets/db_pass 
Hello@2025
root@f9e8bc57a46c:/# 
```
Deploying Docker stack using docker secrets:
```
version: "3.1"
services:
  # Service Name Defined as web
  postgresDB:
    # Pull the Image from Repository.
    image: postgres:latest
    # Command to use secrects in 
    secrets:
      # define Secrets name
      - db_username
      - db_password
    environment:
        # Define environment varaibles
        POSTGRES_PASSWORD_FILE: /run/secrets/db_password
        POSTGRES_USER_FILE: /run/secrets/db_username

secrets:
  db_username:
    file: ./dockSecrets/user.txt
  db_password:
    file: ./dockSecrets/pass.txt
  my-secret:
    external: true
```
Here we are creating secrets using the file.

```
root@testpc:~/docker-repo/10.docker-swarm-secrets# docker stack deploy -c docker-compose.yml postgresdb
Creating network postgresdb_default
Creating secret postgresdb_db_password
Creating secret postgresdb_db_username
Creating service postgresdb_postgresDB
root@testpc:~/docker-repo/10.docker-swarm-secrets# 
root@testpc:~/docker-repo/10.docker-swarm-secrets# docker stack ls
NAME         SERVICES   ORCHESTRATOR
postgresdb   1          Swarm
root@testpc:~/docker-repo/10.docker-swarm-secrets# docker stack services postgresdb
ID             NAME                    MODE         REPLICAS   IMAGE             PORTS
y32yh6g74pan   postgresdb_postgresDB   replicated   1/1        postgres:latest
root@testpc:~/docker-repo/10.docker-swarm-secrets# docker service ps postgresdb_postgresDB
ID             NAME                      IMAGE             NODE                  DESIRED STATE   CURRENT STATE           ERROR     PORTS
uvf9bxvbof0w   postgresdb_postgresDB.1   postgres:latest   testpc1.localdomain   Running         Running 3 minutes ago
root@testpc:~/docker-repo/10.docker-swarm-secrets#
root@testpc1:~# docker exec -it 005131efc140 bash
root@005131efc140:/# cat /run/secrets/db_password 
Hello@2025
root@005131efc140:/# cat /run/secrets/db_username 
dralmostright
root@005131efc140:/#
```

