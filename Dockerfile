FROM lsiobase/mono

# set version label
ARG BUILD_DATE
ARG VERSION
ARG radarr_tag
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
 echo "**** install radarr ****" && \
 mkdir -p \
	/opt/radarr && \
 curl -o \
 /tmp/radar.tar.gz -L \
	"https://github.com/galli-leo/Radarr/releases/download/${radarr_tag}/Radarr.develop.${radarr_tag#v}.linux.tar.gz" && \
 tar ixzf \
 /tmp/radar.tar.gz -C \
	/opt/radarr --strip-components=1 && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 7878
VOLUME /config /downloads /movies
