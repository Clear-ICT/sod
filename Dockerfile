FROM clearict/odoocker
MAINTAINER Sucros Clear Information Technologies PLC

ENV BRANCH 10.0

RUN DEBIAN_FRONTEND=noninteractive && apt-get update && \
        apt-get install -y supervisor

WORKDIR /home/deploy

RUN git clone https://github.com/Clear-ICT/voodoo-template.git production && \
        cd production && \
        git checkout $BRANCH

COPY ssh/id_rsa /root/.ssh/
COPY ssh/id_rsa.pub /root/.ssh/
COPY ssh/known_hosts /root/.ssh/

RUN chmod -R go-rwx ~/.ssh

WORKDIR /home/deploy/production/parts

RUN git clone https://github.com/Clear-ICT/OCB.git odoo && \
        cd odoo && \
        git checkout $BRANCH

WORKDIR /home/deploy/production

RUN cp -R /opt/voodoo/eggs .

RUN chown -R deploy /home/deploy/production

# ak looks for buildout file in /workspace
RUN rm -rf /workspace && \
        ln -s /home/deploy/production /workspace

### Start work-arround for early clone of repo

RUN mkdir -p /tmp/template && cd /tmp/template

RUN git clone https://github.com/Clear-ICT/voodoo-template.git production && \
        cd production && \
        git checkout $BRANCH && \
        cp -R * /home/deploy/production/ && \
        cd /tmp && \
        rm -rf /tmp/template

### End work-arround for early clone of repo

USER deploy

#WORKDIR /home/deploy/production

#COPY bootstrap.py /home/deploy/production/

#RUN python bootstrap.py && \
#        bin/buildout

RUN ak build

ADD supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD supervisord -c /etc/supervisor/conf.d/supervisord.conf
