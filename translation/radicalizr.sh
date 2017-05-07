#!/bin/bash

DBUSR="stefan"
DBPWD="ziegler12"
DBHOST="192.168.50.4"
DBNAME="xanadu2"
DBSCHEMA="dm01_tmp"

echo "Import DM01:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFkIdx --createGeomIdx --defaultSrsCode 2056 --models DM01AVCH24LV95D --dbschema $DBSCHEMA --disableValidation --deleteData --import $1


echo "Control Points:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHCP_20170503 --dbschema dm_cs_ch_cp --deleteData --schemaimport

psql -h $DBHOST -d $DBNAME -f ../sql/DM-CS-CH-CP.sql 2>&1 > /dev/null

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHCP_20170503 --dbschema dm_cs_ch_cp --export output/control_points.xtf

xmllint --format output/control_points.xtf -o output/control_points.xtf


echo "Local Names:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHLN_20170503 --dbschema dm_cs_ch_ln --deleteData --schemaimport

psql -h $DBHOST -d $DBNAME -f ../sql/DM-CS-CH-LN.sql 2>&1 > /dev/null

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHLN_20170503 --dbschema dm_cs_ch_ln --export output/local_names.xtf

xmllint --format output/local_names.xtf -o output/local_names.xtf


echo "Ownership:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHOS_20170503 --dbschema dm_cs_ch_os --deleteData --schemaimport

psql -h $DBHOST -d $DBNAME -f ../sql/DM-CS-CH-OS.sql 2>&1 > /dev/null

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHOS_20170503 --dbschema dm_cs_ch_os --export output/ownership.xtf

xmllint --format output/ownership.xtf -o output/ownership.xtf


echo "Territorial Boundaries:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHTB_20170503 --dbschema dm_cs_ch_tb --deleteData --schemaimport

psql -h $DBHOST -d $DBNAME -f ../sql/DM-CS-CH-TB.sql 2>&1 > /dev/null

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHTB_20170503 --dbschema dm_cs_ch_tb --export output/territorial_boundaries.xtf

xmllint --format output/territorial_boundaries.xtf -o output/territorial_boundaries.xtf


echo "Ground Displacements:"

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHGD_20170503 --dbschema dm_cs_ch_gd --deleteData --schemaimport

psql -h $DBHOST -d $DBNAME -f ../sql/DM-CS-CH-GD.sql 2>&1 > /dev/null

java -jar ../apps/ili2pg-3.8.1/ili2pg.jar --dbhost $DBHOST --dbdatabase $DBNAME --dbusr $DBUSR --dbpwd $DBPWD --nameByTopic --strokeArcs --createFk --createEnumTabs --createGeomIdx --createNumChecks --createFkIdx --defaultSrsCode 2056 --modeldir "http://models.interlis.ch;../models/" --models DMCSCHGD_20170503 --dbschema dm_cs_ch_tb --export output/ground_displacements.xtf

xmllint --format output/ground_displacements.xtf -o output/ground_displacements.xtf
