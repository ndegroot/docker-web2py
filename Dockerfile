# Version: 0.0.1
FROM debian:stable
LABEL org.opencontainers.image.authors="nico@ocinet.nl"

ENV REFRESHED_AT=2024-09-12

# env vars
ENV PW=admin
ENV INSTALL_DIR=/home/www-data
ENV W2P_DIR=$INSTALL_DIR/web2py
ENV CERT_PASS=web2py
ENV CERT_DOMAIN=www.example.com

EXPOSE 80 443 8000

CMD ["supervisord", "-n"]

WORKDIR $INSTALL_DIR

USER root

# update ubuntu and install necessary packages
RUN apt-get update && \
	apt-get autoremove && \
	apt-get autoclean && \
	apt-get -y install nginx-full && \
	apt-get -y install build-essential libssl-dev libffi-dev python3-dev libxml2-dev python3-pip python3-pil unzip wget supervisor

RUN pip3 install uwsgi --break-system-packages
# above return error externally managed
#RUN apt-get install python3-uwsgi
#RUN apt-get -y install uwsgi
# puts (old?) binary in /usr/bin/uswgi
# packages for dibsa ----
RUN pip3 install python-statemachine --break-system-packages
RUN apt-get -y install python3-acme && \
    apt-get -y install python3-apt && \
    apt-get -y install python3-attr
RUN apt-get -y install python3-bcrypt && \
    apt-get -y install python3-bs4 && \
    apt-get -y install python3-certbot
# RUN apt-get -y install python3-certifi && \
RUN apt-get -y install python3-chardet && \
    apt-get -y install python3-colorama && \
    apt-get -y install python3-commonmark
RUN apt-get -y install python3-configargparse && \
    apt-get -y install python3-dateutil && \
    apt-get -y install python3-decorator
RUN apt-get -y install python3-keyring && \
    apt-get -y install python3-ldap3 && \
    apt-get -y install python3-levenshtein
RUN apt-get -y install python3-lxml && \
    apt-get -y install python3-numpy && \
    apt-get -y install python3-openpyxl && \
    apt-get -y install python3-openssl
RUN apt-get -y install python3-psutil && \
    apt-get -y install python3-psycopg2
RUN apt-get -y install python3-pyasn1 && \
    apt-get -y install python3-pygments && \
    apt-get -y install python3-pyodbc && \
    apt-get -y install python3-pyparsing && \
    apt-get -y install python3-regex
RUN apt-get -y install python3-reportlab && \
    apt-get -y install python3-reportlab-accel
#    apt-get -y install python3-requests && \
#    apt-get -y install python3-requests-toolbelt
# RUN apt-get -y install python3-selenium
RUN apt-get -y install python3-six
RUN apt-get -y install python3-soupsieve && \
    apt-get -y install python3-typing-extensions && \
    apt-get -y install python3-tz && \
    apt-get -y install python3-urllib3 && \
    apt-get -y install python3-wheel
RUN apt-get -y install python3-yaml
RUN apt-get -y install python3-pandas
RUN apt-get -y install python3-matplotlib
RUN apt-get -y install python3-authlib
RUN apt-get -y install python3-blinker
#RUN apt-get -y install python3-dill # older vwrsion, not working use recent pypi version instead
RUN pip3 install dill --break-system-packages
RUN pip3 install geraldo3 --break-system-packages



#RUN apt-get clean
RUN mkdir /etc/nginx/conf.d/web2py

# copy nginx config files from repo
ADD gzip_static.conf /etc/nginx/conf.d/web2py/gzip_static.conf
ADD gzip.conf /etc/nginx/conf.d/web2py/gzip.conf
ADD web2py /etc/nginx/sites-available/web2py

# setup nginx
RUN ln -s /etc/nginx/sites-available/web2py /etc/nginx/sites-enabled/web2py && \
	rm /etc/nginx/sites-enabled/default && \
	mkdir /etc/nginx/ssl && cd /etc/nginx/ssl && \
	openssl genrsa -passout pass:$CERT_PASS 4096 > web2py.key && \
	chmod 400 web2py.key && \
	openssl req -new -x509 -nodes -sha1 -days 1780 -subj "/C=US/ST=Denial/L=Chicago/O=Dis/CN=$CERT_DOMAIN" -key web2py.key > web2py.crt && \
	openssl x509 -noout -fingerprint -text < web2py.crt > web2py.info && \
	mkdir -p /etc/uwsgi && \
	mkdir -p /var/log/uwsgi

# copy Emperor config files from repo
ADD web2py.ini /etc/uwsgi/web2py.ini
ADD uwsgi-emperor.conf /etc/init/uwsgi-emperor.conf

# copy Supervisor config file from repo
ADD supervisor-app.conf /etc/supervisor/conf.d/

# get and install web2py
RUN wget https://web2py.com/examples/static/web2py_src.zip && \
    mkdir tmp && \
	unzip web2py_src.zip -d tmp && \
	mv tmp/web2py web2py && \
	rm web2py_src.zip && \
	rm -rf tmp && \
	mv web2py/handlers/wsgihandler.py web2py/wsgihandler.py && \
	chown -R www-data:www-data web2py
RUN    rm -rf web2py/applications/welcome
RUN    rm -rf web2py/applications/examples 

# Copy the routes file so web2py routes stuff to default app 
ADD routes.py /home/www-data/web2py/

USER www-data

WORKDIR $W2P_DIR

RUN python3 -c "from gluon.main import save_password; save_password('$PW',80)" && \
	python3 -c "from gluon.main import save_password; save_password('$PW',443)"

USER root
