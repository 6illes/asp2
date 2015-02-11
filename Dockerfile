FROM        debian
MAINTAINER  Gilles

# Update the package repository

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl locales nano


# Configure timezone and locale

# RUN echo "Europe/Paris" > /etc/timezone && \
#    dpkg-reconfigure -f noninteractive tzdata

# RUN export LANGUAGE=C && \
#    export LANG=C && \
#    export LC_ALL=C && \
#    locale-gen C && \
#    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales


# Added prerequisites

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools


RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
EXPOSE 22/tcp
# recommended ASPERA page 10
EXPOSE 33001/tcp

# Configure SSH server for PasswordAuthentication

RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config
RUN /etc/init.d/ssh restart

RUN echo AllowTcpForwarding     >> /etc/ssh/sshd_config
RUN echo Match Group root       >> /etc/ssh/sshd_config
RUN echo AllowTcpForwarding yes >> /etc/ssh/sshd_config


RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
EXPOSE 80/tcp

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
EXPOSE 3306/tcp


# ASPERA

ENV ASPERA aspera
ENV ASPERADIR /opt/$ASPERA

ENV ASPERAURL https://storage.fr1.cloudwatt.com/v1/AUTH_f462168636b34441ac49c9dbf6d9f57d/ASPERA
ENV ASPERAPKG aspera-server.deb
ENV ASPERALIC aspera-license

RUN mkdir -p $ASPERADIR
RUN mkdir -p $ASPERADIR/etc

ADD $ASPERAURL/$ASPERAPKG $ASPERADIR/$ASPERAPKG
ADD $ASPERAURL/$ASPERALIC $ASPERADIR/etc/$ASPERALIC

WORKDIR $ASPERADIR
RUN dpkg -i $ASPERAPKG 

WORKDIR $ASPERADIR/etc
RUN ascp -A

EXPOSE 33001/udp

RUN echo ------------ ASPERA CONNECT SERVER ------------









#RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Stockholm/g' /etc/php5/apache2/php.ini

#ADD ./001-docker.conf /etc/apache2/sites-available/
#RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/

# Set Apache environment variables (can be changed on docker run with -e)
#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2
#ENV APACHE_PID_FILE /var/run/apache2.pid
#ENV APACHE_RUN_DIR /var/run/apache2
#ENV APACHE_LOCK_DIR /var/lock/apache2
#ENV APACHE_SERVERADMIN admin@localhost
#ENV APACHE_SERVERNAME localhost
#ENV APACHE_SERVERALIAS docker.localhost
#ENV APACHE_DOCUMENTROOT /var/www

#EXPOSE 80
#ADD start.sh /start.sh
#RUN chmod 0755 /start.sh
#CMD ["bash", "start.sh"]
