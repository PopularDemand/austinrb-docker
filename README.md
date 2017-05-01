# Docker
## Prerequisites
* Install [Docker Community Edition](https://www.docker.com/community-edition)
* Clone this repo 
```git clone git@github.com:eliaslopezgt/austinrb-docker.git```

## Documentation
* [DockerFile builder reference] (https://docs.docker.com/engine/reference/builder/)


## Step 1

## Push changes to docker image
To update the docker hub repository in this case I used:

```
docker push eliaslopezgtz/ruby_test  
```

## Push changes to docker node manager myvm1
Everytime we update the docker-compose.yml is changed we need to update it in our nodes.

```
docker-machine scp docker-compose.yml myvm1:~
docker-machine ssh myvm1 "docker stack deploy -c docker-compose.yml ruby_test"
```
