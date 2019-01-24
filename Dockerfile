FROM python:2.7
MAINTAINER binux <roy@binux.me>

ARG configparam=""
#-c config.json
ENV configparam $configparam

# install phantomjs
RUN mkdir -p /opt/phantomjs \
        && cd /opt/phantomjs \
        && wget -O phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
        && tar xavf phantomjs.tar.bz2 --strip-components 1 \
        && ln -s /opt/phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
        && rm phantomjs.tar.bz2
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:mc3man/trusty-media \ 
    && apt-get upgrade && apt-get install -y ffmpeg \ 
    && mkdir /data \ 
    && adduser --disabled-password --gecos "" ffmpeg
    
USER ffmpeg

# install requirements
RUN pip install --egg 'https://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-2.1.5.zip#md5=ce4a24cb1746c1c8f6189a97087f21c1'
COPY requirements.txt /opt/pyspider/requirements.txt
RUN pip install -r /opt/pyspider/requirements.txt

# add all repo
ADD ./ /opt/pyspider

# run test
WORKDIR /opt/pyspider
RUN pip install -e .[all]

VOLUME ["/opt/pyspider"]
CMD pyspider

EXPOSE 5000 23333 24444 25555
