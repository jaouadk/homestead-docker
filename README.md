# Laravel homestead-docker
Create a homestead docker container for your development env. ( files taken from laravel settler: provision.sh (modified) + serve.sh )

### Install docker && docker compose
please refer to these tutorials:
* install docker (https://docs.docker.com/installation/ubuntulinux/)
* install docker compose (fig alternative) (https://docs.docker.com/compose/install/)

### build the homestead image
```shell
git clone https://github.com/shincoder/homestead-docker.git
cd homestead-docker
docker build -t shincoder/homestead .
```

### launch your containers
There are only two containers to run. web container ( includes everything except your database ), and mariadb container.
```shell
sudo docker-compose up -d
```
this will build the image, and start it.

### ssh into the container:
```shell
ssh -p 2222 homestead@localhost
```

### add a virtual host
assuming you mapped your apps folder to ```/app```, you can do this.
```shell
cd / && ./serve.sh myapp.dev /apps/myapp/public
```

### everything should work - Enjoy !!!
Our web container starts nginx, php5-fpm, redis, beanstalk. and has gruntjs, gulp, bower.
some relevant port have been added to docker-compose.yml ( livereload standard port, karma server port ), change them if you need to.
