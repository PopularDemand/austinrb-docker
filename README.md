# AustinRB Dockerizing Ruby Applications

## Prerequisites
* Install [Docker Community Edition](https://www.docker.com/community-edition)
* Clone this repo 
```git clone git@github.com:eliaslopezgt/austinrb-docker.git```

## Documentation
* [DockerFile builder reference](https://docs.docker.com/engine/reference/builder/)
* [Get a docker hub account](https://hub.docker.com/)

## Acceptance Criteria
* As a user I want to invoke an endpoint and increment a counter stored in redis.
* This application should be served using [puma](http://puma.io/).
* This should be a rack application.

## Deliverables
* [config.ru](https://github.com/eliaslopezgt/austinrb-docker/blob/master/config.ru)

## How to run it locally
```rackup```
### Did it work?
Probably some dependencies were missing (puma, rack, redis)
### Install missing gems? probably ... not.
```
gem install rack
gem install puma
gem install redis
```
try again.
### Still missing something?
Maybe the redis server.
### Install missing services? probably ... not.
Install [redis](https://redis.io/download).

## Why not scripting it inside a [Dockerfile](https://github.com/eliaslopezgt/austinrb-docker/blob/master/Dockerfile)
```
FROM ruby:2.3.3
RUN gem install rack
RUN gem install puma
RUN gem install redis
RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
EXPOSE 80
CMD ["rackup","-s","puma","-o","0.0.0.0","-p","80"]
```
### Push changes to docker image (optional)
To update the docker hub repository in this case I used:

```
docker login
docker push eliaslopezgtz/ruby_test  
```

## How to run it with Docker
Build the Docker Image

```
docker build -t ruby_test .
```

Run the Docker Image

```
docker run -p 80:80 ruby_test
```

Go to [http://localhost](http://localhost)
The response should be something like

```
Counter:Redis not available Served from: X.X.X.X
```

### Install missing services? probably ... not.
Lets script the services instead using a docker-compose.yml file.

## Enter [docker-compose.yml](https://github.com/eliaslopezgt/austinrb-docker/blob/master/docker-compose.yml)

```
version: '3'
services:
  web: 
    image: eliaslopezgtz/ruby_test:master
    deploy:
      replicas: 1 
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
    networks:
      - webnet
    ports:
      - "80:80"
    command: rackup -s puma -o 0.0.0.0 -p 80
  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]
    networks:
      - webnet
  redis:
    image: redis
    ports:
      - "6379:6739"
    volumes:
      - ./data:/data
    deploy:
      placement:
        constraints: [node.role == manager]
    networks:
      - webnet
networks:
  webnet:
```

## Generate the local stack
```
docker stack deploy -c docker-compose.yml ruby_test
```
### Open the [visualizer](http://localhost:8080/)
### Delete the local stack
```
docker stack rm ruby_test
```

## Simulate the cloud 
From the [Docker docs](https://docs.docker.com/get-started/part4/#create-a-cluster)

Create a couple of VMs using docker-machine, using the VirtualBox driver:

```
$ docker-machine create --driver virtualbox myvm1
$ docker-machine create --driver virtualbox myvm2
$ docker-machine create --driver virtualbox myvm3
```

### Instruct myvm1 to become a swarm manager with 

```
docker-machine ssh myvm1 "docker swarm init --advertise-addr 192.168.99.100:2377"
```

Copy this command, and send it to myvm2 via docker-machine ssh to have myvm2 join your new swarm as a worker:

```
$ docker-machine ssh myvm2 "docker swarm join \
--token <token> \
<ip>:<port>"

This node joined a swarm as a worker.
```

## Push changes to docker node manager myvm1
Everytime we update the docker-compose.yml is changed we need to update it in our nodes.

```
docker-machine scp docker-compose.yml myvm1:~
docker-machine ssh myvm1 "docker stack deploy -c docker-compose.yml ruby_test"
```
