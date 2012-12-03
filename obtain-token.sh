#!/bin/bash

#set -x
# Import Settings
#. settings

USERNAME="admin"
PASSWORD="admin"
TENANTID="b2a6723edabf42b28d535d58ffbadcd2"  #project id:must be setted
KEYSTONE_IP="10.1.199.7"
NOVA_API_IP="10.1.199.7"

REQUEST="{\"auth\": {\"passwordCredentials\": {\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"},\"tenantId\":\"$TENANTID\"}}"
#REQUEST="{\"auth\": {\"passwordCredentials\": {\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}}}"
echo $REQUEST
RAW_TOKEN=`curl -s -d "$REQUEST" -H "Content-type: application/json" "http://$KEYSTONE_IP:5000/v2.0/tokens"`
TOKEN=`echo $RAW_TOKEN | python -c "import sys; import json; tok = json.loads(sys.stdin.read()); print tok['access']['token']['id'];"`
echo $TOKEN

#RAW=`curl -k -D - -H "X-Auth-Token: a8856c16a7764dde835e228df35693bf" -X 'GET' -v 'http://10.1.199.8:8774/v2/0f3cb125bcc845b9a3736d287ddc5d5a/os-security-groups' -H 'Content-type: application/json'`
RAW=`curl -k -H "X-Auth-Token: $TOKEN" -X 'GET' -v "http://$NOVA_API_IP:8774/v2/$TENANTID/os-security-groups" -H 'Content-type: application/json'`
#echo $RAW
echo $RAW | python -c "import sys; import json; tok = json.loads(sys.stdin.read()); print tok;"
