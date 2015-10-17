FROM laforet/ooidocker:v1
MAINTAINER Laforet <la-foret.me>

#Force bash!!!
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#Pull the lastest version of ooi
WORKDIR /srv/ooi2
RUN git pull

#Prefetch files from game server
RUN	mkdir /srv/_kcs
WORKDIR /srv/_kcs
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_184_015_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_184_015_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_184_016_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_184_016_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_205_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_205_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_229_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_229_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_253_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_187_253_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_188_025_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_188_025_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_007_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_007_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_039_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_039_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_071_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_071_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_103_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_103_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_135_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_135_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_167_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_167_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_215_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_215_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_247_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/125_006_189_247_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_105_167_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_105_167_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_023_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_023_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_039_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_039_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_055_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_055_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_071_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_071_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_102_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_209_102_s.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_248_135_l.png
RUN wget http://203.104.209.102/kcs/resources/image/world/203_104_248_135_s.png
RUN wget http://203.104.209.102/kcs/mainD2.swf

#Build supervisor config file from scratch with random OOI_SECRET
WORKDIR /etc/supervisor
RUN sed  '/\[supervisord\]/a nodaemon=true' supervisord.conf
RUN echo "[program:ooi2]" >> supervisord.conf
RUN echo "command=/srv/ooi2/bin/python3 /srv/ooi2/ooi.py" >> supervisord.conf
RUN echo "environment=OOI_SECRET=$(awk -v min=1000000000 -v max=9999999999 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')" >> supervisord.conf
RUN echo "directory=/srv/ooi2" >> supervisord.conf
RUN echo "autostart=true" >> supervisord.conf
RUN echo "autorestart=true" >> supervisord.conf
RUN echo "user=www-data" >> supervisord.conf
RUN echo "[program:nginx]" >> supervisord.conf
RUN echo "command=/usr/sbin/nginx" >> supervisord.conf
RUN echo "stdout_events_enabled=true" >> supervisord.conf
RUN echo "stderr_events_enabled=true" >> supervisord.conf

#Prepend nginx.conf no NOT run as daemon
WORKDIR /etc/nginx
RUN sed -i "1s/^/daemon off;\n/" nginx.conf

#Add nginx config files
COPY kcs_upstream.conf /etc/nginx/kcs_upstream.conf
COPY ooi2_proxy.conf /etc/nginx/ooi2_proxy.conf
COPY ooi2.conf /etc/nginx/sites-enabled/ooi2.conf

#Issue a self-signed TLS certificate
RUN openssl req -x509 -newkey rsa:2048 -keyout /srv/key.pem -out /srv/cert.pem -days 180 -nodes -subj /C=NA/ST=Nowhere/L=Nowhere/O=OnlineObjectsIntegration/OU=InstallationEphemeral/CN=OOI.system/emailAddress=private.use.only@destroy.after.use

#Restart nginx
RUN service nginx restart

#Expose external ports
EXPOSE 80 443

#Start supervisor
CMD ["/usr/bin/supervisord"]
