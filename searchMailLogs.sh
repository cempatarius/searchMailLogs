#!/bin/bash

# Disable set -e as zgrep will exit 1 if search term not found in a file.
#set -e

IGNORELIST='(timeout|disconnect|NOQUEUE|connect|warning|stopping|proxy-accept)'

printhelp () {
echo "  Usage:"
echo "    $0 [-fti] <search_term>"
echo
echo "  Options:"
echo
echo "    -f"
echo "      Search for messages from <email_address>"
echo
echo "    -t"
echo "      Search for messages to <email_address>"
echo
echo "    -i"
echo "      Search for messages with Message ID"
echo
echo "    -a"
echo "      Also search through archived mail logs"
echo
echo "  Searches mail logs for anything matching specified terms"
exit 1
}

[ "$#" -lt 1 ] && printhelp

set -- "$@" _eNd_OF_lisT_
while [ "$1" != "_eNd_OF_lisT_" ]; do
  case $1 in
  -f)
    FROMTO="from"
    TERM="$2"
    shift 2
    ;;
  -t)
    FROMTO="to"
    TERM="$2"
    shift 2
    ;;
  -i)
    MID="Yes"
    TERM="$2"
    shift 2
    ;;
  -a)
    ARCHIVE="Yes"
    shift 1
    ;;
  -h|--help)
    printhelp
    ;;
  *)
    printhelp
    ;;
  esac
done

if [ "$ARCHIVE" == "Yes" ]; then
  GREPBIN=/bin/zgrep
else
  GREPBIN=/bin/grep
fi

if [ "$MID" == "Yes" ]; then
  $GREPBIN ${TERM} /var/log/mail.log*
exit 0
fi


PULLMIDS=`$GREPBIN "$FROMTO=<$TERM>" /var/log/mail.log* | /usr/bin/awk '{print $6}' | /usr/bin/tr -d : | /usr/bin/uniq | /bin/egrep -v "$IGNORELIST"`

if [ -z "$PULLMIDS" ]; then
  echo -e "\033[1mNo Messages Found\033[0m"
else
  echo -e "\033[1mMESSAGE ID LIST\033[0m"
  echo ${PULLMIDS}
  echo
fi

for i in $PULLMIDS; do echo -e "<--- \033[1m$i\033[0m --->"; $GREPBIN $i /var/log/mail.log*; echo; done

exit 0
