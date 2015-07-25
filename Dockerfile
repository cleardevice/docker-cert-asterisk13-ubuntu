# Version: 0.0.3 - Certified Asterisk 13.1-cert2 with sip and pjsip channels
FROM ubuntu:trusty
MAINTAINER cd "cleardevice@gmail.com"

COPY ./scripts/build.sh /tmp/
COPY ./asterisk-build/menuselect.makeopts /tmp/
COPY ./scripts/start.sh /

RUN /bin/sh /tmp/build.sh

WORKDIR /root
CMD ["/bin/sh", "/start.sh"]
