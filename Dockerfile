FROM ubuntu:14.04
MAINTAINER Jaouad K. <jaouad.kay@gmail.com>

# Install packages
ADD provision.sh /provision.sh
ADD serve.sh /serve.sh
ADD run.sh /run.sh

RUN chmod +x /*.sh

RUN ./provision.sh

EXPOSE 80 22 35729 9876
CMD ["/run.sh"]
