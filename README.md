# Laravel homestead-docker
Create a homestead docker container for your development env.
(Adapted from laravel homestead provisionning script)

### Install docker && docker compose
please refer to these tutorials:
* install docker (https://docs.docker.com/installation/ubuntulinux/)
```shell
curl -sSL https://get.docker.com/ | sh
```
* install docker compose (https://docs.docker.com/compose/install/)
```shell
sudo curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Pull homestead image
```shell
docker pull shincoder/homestead:php7.3
```

### Clone && Edit docker-compose.yml
```shell
git clone https://github.com/shincoder/homestead-docker.git
```
rename ```docker-compose.dist.yml``` to ```docker-compose.yml``` then edit the file with you own
paths and ports.

### Start your containers
There are only two containers to run. web container ( includes everything except your database ),
and mariadb container.
```shell
sudo docker-compose up -d
```

### SSH into the container (password: secret):
```shell
ssh -p 2222 homestead@localhost
```

### Add a virtual host
Assuming you mapped your apps folder to ```/apps``` (you can change mappings in the docker-compose.yml file,
it's prefered to use absolute paths), you can do:
```shell
cd /
sudo ./serve.sh myapp.dev /apps/myapp/public
sudo supervisorctl restart all
```

**In the host**, update ``` /etc/hosts ``` to include your app domain:
```shell
127.0.0.1               myapp.dev
```

### That's it
Our web container starts nginx, php-fpm, redis, beanstalk. and has npm, gulp, bower...etc

### Notes
- Since the web and database containers are linked you can use ```mysql``` as  the host in your ```.env``` file with an empty password to properly connect to your database.
```
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=
```
