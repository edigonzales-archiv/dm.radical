#!/bin/bash

DBUSR="stefan"
DBPWD="ziegler12"
DBHOST="192.168.50.4"
DBNAME="xanadu2"
DBSCHEMA="dm01_tmp"

echo "Import DM01:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFkIdx --createGeomIdx --defaultSrsCode 2056 --models DM01AVCH24LV95D --dbschema $DBSCHEMA --deleteData --import $1

