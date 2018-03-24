#/bin/bash


# [REWHOIS] REGISTRANT


USER_AGENT="Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1"

HTTP_REQUEST="http://viewdns.info/reversewhois/?q="

REGISTRANT_NAME=""
REGISTRANT_EMAIL=""

FILE1=""
FILE2=""


get_domains () {
	# arg1: Registrant name or email.

	# Remove space in name argument.
	FILE1="${1/+/_}_reverse_whois_1.html"
	FILE2="${1/+/_}_reverse_whois_2.html"

	echo "$HTTP_REQUEST$1"

	if [ -f $FILE2 ]
	then
		mv $FILE2 $FILE1
	fi

	if [ ! -f $FILE1 ]
	then
		curl -A "$USER_AGENT" $HTTP_REQUEST$1 > $FILE1
		sed -i 's/<\/td>/&\n/g' $FILE1
	fi

	curl -A "$USER_AGENT" $HTTP_REQUEST$1 > $FILE2
	sed -i 's/<\/td>/&\n/g' $FILE2
}


while getopts n:e: option 
do
	case "${option}" in
		n) 	REGISTRANT_NAME=${OPTARG/ /+}
			# Format html string.
			# sed 's/\ /\+/g'
			get_domains "$REGISTRANT_NAME"
			;;
		e) 	REGISTRANT_EMAIL=${OPTARG}
			# Format html string.
			# sed 's/@/%40/g'
			get_domains "$REGISTRANT_EMAIL"
			;;
	esac
done


# Ignore the page generation time information.
diff_files=$(diff -I '^<!-- page generated in*' $FILE1 $FILE2)


if [ "$diff_files" != "" ]
then
	echo "[RESULT] $diff_files"
else
	echo "[RESULT] No new registered domain found."
fi


exit 0
