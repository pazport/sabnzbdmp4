# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV SABNZBD_VERSION 3.3.1

# Install dependencies and Sabnzbd
RUN apt-get update && apt-get install -y \
    unzip \
    && pip install sabyenc \
    && mkdir -p /opt/sabnzbd \
    && curl -o /tmp/sabnzbd-${SABNZBD_VERSION}-src.tar.gz -L "https://github.com/sabnzbd/sabnzbd/archive/${SABNZBD_VERSION}.tar.gz" \
    && tar -xzf /tmp/sabnzbd-${SABNZBD_VERSION}-src.tar.gz -C /opt/sabnzbd --strip-components=1 \
    && rm /tmp/sabnzbd-${SABNZBD_VERSION}-src.tar.gz

RUN apt-get install -y \
	p7zip-full \
	nano \
	git \
	python3-pip \
	ffmpeg \
	python3 \
	par2-tbb \
	python-sabyenc \
	unrar \
	unzip && \
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
	qtfaststart \
    sabyenc
#mp4automator
RUN git clone https://github.com/pazport/sickbeard_mp4_automator.git mp4automator
RUN chmod -R 777 /mp4automator
RUN chown -R 1000:1000 /mp4automator
RUN ln -s /config/mp4automator /mp4automator

#update and install latest ffmpeg
RUN pip3 install -U pip --no-cache-dir
RUN apt-get update && apt-get upgrade -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:savoury1/graphics -y
RUN add-apt-repository ppa:savoury1/multimedia -y
RUN add-apt-repository ppa:savoury1/ffmpeg4 -y
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg -y
RUN apt-get update && apt-get upgrade -y

# add local files
COPY root/ /
WORKDIR /opt/sabnzbd

# ports and volumes
EXPOSE 8080 9090
VOLUME /config
VOLUME /mp4automator

# Start Sabnzbd
CMD ["python", "SABnzbd.py", "-f", "/config"]