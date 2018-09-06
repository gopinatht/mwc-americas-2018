#! /bin/bash
set -e

#TOSCA_URL=`minikube service xos-tosca --url`


# NOTE: probably could have used localhost:30007...

#TOSCA_ADDR=`kubectl get services | grep -i xos-tosca | awk '{print $3}'`
#TOSCA_PORTMAP=`kubectl get services | grep -i xos-tosca | awk '{print $5}'`
#TOSCA_PORT=`echo $TOSCA_PORTMAP | cut -d ":" -f 1`
#TOSCA_URL="http://$TOSCA_ADDR:$TOSCA_PORT"


ACCOUNT=admin@opencord.org
PASSWORD=letmein
RECIPE=$1

#echo "Tosca URL is $TOSCA_URL"
#curl -H "xos-username: $ACCOUNT" -H "xos-password: $PASSWORD" -X POST --data-binary @$RECIPE $TOSCA_URL/run
# For creation
curl -H "xos-username: $ACCOUNT" -H "xos-password: $PASSWORD" -X POST --data-binary @$RECIPE http://10.90.0.215:30007/run
