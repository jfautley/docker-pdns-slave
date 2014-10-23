FROM centos:centos7
MAINTAINER Jon Fautley <jon@dead.li>

EXPOSE 53 53/udp

RUN yum -y upgrade && \
    yum -y install epel-release && \
    yum -y install pdns && \
    yum clean all

ADD pdns /etc/pdns

VOLUME ["/zones"]

ENTRYPOINT ["/usr/sbin/pdns_server", "--guardian=yes"]
