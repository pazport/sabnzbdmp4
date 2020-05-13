once you have installed sabnzbd you will need to bash into sabnzd with

docker exec -it sabnzbd /bin/bash

then `` cd /mp4automator/config``
then ``nano autoProcess.ini``
and make changes that meet your needs


## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=sabnzbd \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -p 8080:8080 \
  -p 9090:9090 \
  -v <path to data>:/config \
  -v <path to downloads>:/downloads \
  -v <path to incomplete downloads>:/incomplete-downloads `#optional` \
  --restart unless-stopped \
 man1234/sabnzbdmp4
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | HTTP port for the WebUI. |
| `-p 9090` | HTTPS port for the WebUI. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-v /config` | Local path for sabnzbd config files. |
| `-v /downloads` | Local path for finished downloads. |
| `-v /incomplete-downloads` | Local path for incomplete-downloads. |
