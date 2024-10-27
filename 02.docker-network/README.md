Containers may need to communicate among other container running on same host or other hots and this can be done. Each Container connect to virtual private network call 'bridge' which is the default network driver of docker. All Containers on same bridge can communicate each other without -p (Port)

