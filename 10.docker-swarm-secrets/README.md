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