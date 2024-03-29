# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest as unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
  PYTHONIOENCODING=utf-8

RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev \
	git && \
  apk add  -U --update --no-cache \
    7zip \
    libgomp \
    python3 && \
  echo "**** install sabnzbd ****" && \
  if [ -z ${SABNZBD_VERSION+x} ]; then \
    SABNZBD_VERSION=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p /app/sabnzbd && \
  curl -o \
    /tmp/sabnzbd.tar.gz -L \
    "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" && \
  tar xf \
    /tmp/sabnzbd.tar.gz -C \
    /app/sabnzbd --strip-components=1 && \
  cd /app/sabnzbd && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.18/ \
    apprise \
    pynzb \
    requests && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.18/ -r requirements.txt && \
  echo "**** install par2cmdline-turbo from source ****" && \
  PAR2_VERSION=$(curl -s https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  mkdir /tmp/par2cmdline && \
  curl -o \
    /tmp/par2cmdline.tar.gz -L \
    "https://github.com/animetosho/par2cmdline-turbo/archive/${PAR2_VERSION}.tar.gz" && \
  tar xf \
    /tmp/par2cmdline.tar.gz -C \
    /tmp/par2cmdline --strip-components=1 && \
  cd /tmp/par2cmdline && \
  ./automake.sh && \
  ./configure && \
  make && \
  make check && \
  make install && \
  echo "**** install nzb-notify ****" && \
  NZBNOTIFY_VERSION=$(curl -s https://api.github.com/repos/caronc/nzb-notify/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  mkdir -p /app/nzbnotify && \
  curl -o \
    /tmp/nzbnotify.tar.gz -L \
    "https://api.github.com/repos/caronc/nzb-notify/tarball/${NZBNOTIFY_VERSION}" && \
  tar xf \
    /tmp/nzbnotify.tar.gz -C \
    /app/nzbnotify --strip-components=1 && \
  cd /app/nzbnotify && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.18/ -r requirements.txt
#  echo "**** cleanup ****" && \
#  apk del --purge \
#    build-dependencies && \
#  rm -rf \
#    /tmp/* \
#    $HOME/.cache

#mp4automator
RUN git clone https://github.com/pazport/sickbeard_mp4_automator.git /config/mp4automator
RUN chmod -R 777 /config/mp4automator
RUN chown -R 1000:1000 /config/mp4automator
#RUN ln -s /config/mp4automator /config/mp4automator
RUN pip3 install -r /config/mp4automator/setup/requirements.txt

#update and install latest ffmpeg
RUN pip3 install -U pip --no-cache-dir
RUN apk update
#RUN apk add software-properties-common
#RUN apk add ppa:savoury1/graphics
#RUN apk add ppa:savoury1/multimedia
#RUN apk add ppa:savoury1/ffmpeg4
RUN apk update
RUN apk add ffmpeg 
RUN apk update

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080
VOLUME /config