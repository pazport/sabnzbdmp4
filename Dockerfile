FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
 echo "***** install gnupg ****" && \
 apt-get update && \
 apt-get install -y \
        gnupg && \
 echo "***** add sabnzbd repositories ****" && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F && \
 echo "deb http://ppa.launchpad.net/jcfp/nobetas/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb-src http://ppa.launchpad.net/jcfp/nobetas/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb http://ppa.launchpad.net/jcfp/sab-addons/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb-src http://ppa.launchpad.net/jcfp/sab-addons/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "**** install packages ****" && \
 if [ -z ${SABNZBD_VERSION+x} ]; then \
	SABNZBD="sabnzbdplus"; \
 else \
	SABNZBD="sabnzbdplus=${SABNZBD_VERSION}"; \
 fi && \
 apt-get update && apt-get upgrade -y && \
 apt-get install -y \
	p7zip-full \
	par2-tbb \
	python-pip \
	python3-pip \
	build-essential \
	python3 \
	${SABNZBD} \
	ffmpeg \
	nano \
	unrar \
	unzip \
	build-essential \
    libssl-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
	git && \
 pip install --no-cache-dir \
	apprise \
	chardet \
	pynzb \
	requests \
	sabyenc && \
 pip3 install --no-cache-dir \
        apprise \
        chardet \
        pynzb \
        requests \
		requests[security] \
		requests-cache \
		babelfish \
		tmdbsimple \
		idna \
		mutagen \
		guessit \
		subliminal \
		python-dateutil \
		stevedore \
		qtfaststart\
        sabyenc && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# Install MP4 Automator
RUN git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git mp4automator
VOLUME /mp4automator

#Set script file permissions
RUN chmod 775 -R /mp4automator
RUN chown 1000:1000 -R /mp4automator

#update ffmpeg
RUN apt-get update && apt-get upgrade -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:savoury1/graphics -y
RUN add-apt-repository ppa:savoury1/multimedia -y
RUN add-apt-repository ppa:savoury1/ffmpeg4 -y
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg -y
RUN apt-get update && apt-get upgrade -y

#install mp4automator requirements
RUN chmod -R 777 /mp4automator
RUN chown -R 1000:1000 /mp4automator


# add local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config
VOLUME /mp4automator
