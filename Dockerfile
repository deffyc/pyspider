FROM python:2.7
MAINTAINER binux <roy@binux.me>

ARG configparam=""
#-c config.json
ENV configparam $configparam
ENV FFMPEG_VERSION=4.1

# install phantomjs
RUN mkdir -p /opt/phantomjs \
        && cd /opt/phantomjs \
        && wget -O phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
        && tar xavf phantomjs.tar.bz2 --strip-components 1 \
        && ln -s /opt/phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
        && rm phantomjs.tar.bz2
        
WORKDIR /tmp/ffmpeg

RUN apt-get update && apt-get upgrade && apt-get -y install build-base curl nasm tar bzip2 \
  zlib-dev openssl-dev yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev && \

  DIR=$(mktemp -d) && cd ${DIR} && \

  curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
  cd ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --enable-openssl --disable-debug && \
  make && \
  make install && \
  make distclean && \

  rm -rf ${DIR} 
  #apt-get remove build-base curl tar bzip2 x264 openssl nasm && rm -rf /var/cache/apk/*

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
