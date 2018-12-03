#!/bin/bash
CNF_DIR=/root/.getssl;
CNF_FILE="getssl.cfg";
BASE_CNF_FILE="$CNF_DIR/$CNF_FILE";
TEMPLATE_FILE="/root/template.cfg";
BASE_TEMPLATE_FILE="/root/base_template.cfg";
echo "Updating main config...";
sed -e "s/<account_email>/$ACCOUNT_EMAIL/" $BASE_TEMPLATE_FILE  > $BASE_CNF_FILE;
DOMAINS=${DOMAINS,,};
IFS=' ';
read -r -a DOMAIN_LIST <<< "$DOMAINS";
echo "Updating domain configs...";
for SANS in "${DOMAIN_LIST[@]}"
do
	echo "Checking domain block '$SANS'";
	IFS=',';
	read -r -a SAN_LIST <<< "$SANS";
	DOMAIN=${SAN_LIST[0]};
	echo "Extracted domain '$DOMAIN'";
	SAN_STR=$(printf ",%s" "${SAN_LIST[@]:1}");
	SAN_STR=${SAN_STR:1};
	echo "Extracted sans string '$SAN_STR'";
	DOMAIN_CNF_DIR="$CNF_DIR/$DOMAIN";
	DOMAIN_CNF_FILE="$DOMAIN_CNF_DIR/$CNF_FILE";
	if [ ! -d "$DOMAIN_CNF_DIR" ] 
	then
		echo "$DOMAIN dir is missing, creating one";
		mkdir $DOMAIN_CNF_DIR;
	fi
	if [ -f "$DOMAIN_CNF_FILE" ]
    then
		echo "$DOMAIN found config file"
        OLD_MD5=`md5sum ${DOMAIN_CNF_FILE}`;
	else
        echo "$DOMAIN config file is missing, creating one";
		touch $DOMAIN_CNF_FILE;
		OLD_MD5="";
    fi
	echo "$DOMAIN Old config md5sum: $OLD_MD5";
	echo "$DOMAIN generating config $DOMAIN_CNF_FILE";
	sed -e "s/<domain>/$DOMAIN/" $TEMPLATE_FILE |
	sed -e "s/<sans>/$SAN_STR/"  > $DOMAIN_CNF_FILE;
	NEW_MD5=`md5sum ${DOMAIN_CNF_FILE}`;
	echo "$DOMAIN New config md5sum: $NEW_MD5";
	if [[ $OLD_MD5 == $NEW_MD5 ]]
    then
      echo "$DOMAIN setting not changed";
    else
      echo "$DOMAIN setting changed, forcing obtaining new certificate";
	  getssl -f $DOMAIN;
  	fi
done

echo "Updating old certificates";
getssl -u -a -q

