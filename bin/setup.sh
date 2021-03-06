#!/usr/bin/env bash
 
# define your schema file name here
SCHEMA=schema/Schema.xml 
# define your database name here, will be overriden by 
# FIRST command line argument if given
#DBNAME=netivism_civicrm
# define your database usernamename here, will be overriden by 
# SECOND command line argument if given
#DBUSER=netivism
# define your database password here, will be overriden by 
# THIRD command line argument if given
#DBPASS=netivism123
# any extra args you need in your mysql connect string
# number of arguments should be specified within "" 
# FOURTH command line argument if given
DBARGS=""
# set your PHP5 bin dir path here, if it's not in PATH
# The path should be terminated with dir separator!
PHP5PATH=
# Set a special DB load filename here for custom installs
# If a filename is passed, civicrm_data.mysql AND the 
# passed file will be loaded instead of civicrm_generated.mysql.
# The DBLOAD file must be in the sql directory.
DBLOAD=
# Set a special SQL filename here which you want to load
# IN ADDITION TO either civicrm_generated or civicrm_data.
# The DBADD file must be in the sql directory.
DBADD="civicrm_data.zh_TW.mysql"

# ==========================================================
# No changes below, please.
# ==========================================================

CALLEDPATH=`dirname $0`

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	echo; echo Usage: setup.sh [schema file] [database data file] [database name] [database user] [database password] [additional args]; echo
	exit 0
fi


# fetch command line arguments if available
if [ ! -z $1 ] ; then SCHEMA=$1; fi
if [ ! -z $2 ] ; then DBLOAD=$2; fi
if [ ! -z $3 ] ; then DBNAME=$3; fi
if [ ! -z $4 ] ; then DBUSER=$4; fi
if [ ! -z $5 ] ; then DBPASS=$5; fi

# verify if we have at least DBNAME given
if [ -z $DBNAME ] ; then
	echo "No database name defined!"
	exit 1
fi
if [ -z $DBUSER ] ; then
	echo "No database username defined!"
	exit 1
fi
if [ -z $DBPASS ] ; then
	read -p "Database password:"
	DBPASS=$REPLY
fi

# run code generator if it's there - which means it's
# checkout, not packaged code
if [ -d $CALLEDPATH/../xml ]; then
	cd $CALLEDPATH/../xml
	"$PHP5PATH"php GenCode.php $SCHEMA
fi

# someone might want to use empty password for development,
# let's make it possible - we asked before.
if [ -z $DBPASS ]; then # password still empty
	PASSWDSECTION=""
else
	PASSWDSECTION="-p$DBPASS"
fi

cd $CALLEDPATH/../sql
echo; echo Dropping $DBNAME database
mysqladmin -f -u $DBUSER $PASSWDSECTION $DBARGS drop $DBNAME
echo; echo Creating $DBNAME database
mysqladmin -f -u $DBUSER $PASSWDSECTION $DBARGS create $DBNAME
echo; echo Creating database structure
mysql -u $DBUSER $PASSWDSECTION $DBARGS $DBNAME < civicrm.mysql
#mysql -u $DBUSER $PASSWDSECTION $DBARGS $DBNAME < trigger.mysql

# load civicrm_generated.mysql sample data unless special DBLOAD is passed
#if [ -z $DBLOAD ]; then
#    echo; echo Populating database with example data - civicrm_generated.mysql
#    mysql -u $DBUSER $PASSWDSECTION $DBNAME < civicrm_generated.mysql
#else
#    echo; echo Populating database with required data - civicrm_data.mysql
#    mysql -u $DBUSER $PASSWDSECTION $DBNAME < civicrm_data.mysql
#    echo; echo Populating database with $DBLOAD data
#    mysql -u $DBUSER $PASSWDSECTION $DBNAME < $DBLOAD
#fi

# load additional script if DBADD defined
if [ ! -z $DBADD ]; then
    echo; echo Loading $DBADD
    mysql -u $DBUSER $PASSWDSECTION $DBNAME < $DBADD
fi
    

echo; echo "DONE!"

# to generate a new data file do the following from the sql directory:
# mysqladmin -f -u $DBUSER $PASSWDSECTION drop $DBNAME
# mysqladmin -f -u $DBUSER $PASSWDSECTION create $DBNAME
# mysql -u $DBUSER $PASSWDSECTION $DBNAME < civicrm.mysql
# mysql -u $DBUSER $PASSWDSECTION $DBNAME < civicrm_data.mysql
# mysql -u $DBUSER $PASSWDSECTION $DBNAME < civicrm_sample.mysql
# mysql -u $DBUSER $PASSWDSECTION $DBNAME < zipcodes.mysql
# php GenerateData.php
# echo "drop table zipcodes ; update civicrm_domain set config_backend = null" | mysql -u $DBUSER $PASSWDSECTION $DBNAME
# mysqldump -c -e -t -n -u $DBUSER $PASSWDSECTION $DBNAME  > civicrm_generated.mysql
# add sample custom data 
# cat civicrm_sample_custom_data.mysql >> civicrm_generated.mysql
# cat ../CRM/Case/xml/configuration.sample/SampleConfig.mysql >> civicrm_generated.mysql
