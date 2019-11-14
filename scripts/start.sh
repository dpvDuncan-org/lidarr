#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID lidarr
        GROUPNAME=lidarr
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D lidarr
        USERNAME=lidarr
fi

su - $USERNAME -c 'mono /opt/lidarr/Lidarr.exe -nobrowser -data=/config'