echo "Configuring Command: reply_message"
curl https://rest.fauna.org/v1/commands/reply_message/config -X PUT -u $FAUNA_PUBLISHER_KEY: -d '{ "comment": "Reply a Message", "actions":[{"method":"POST", "path":"/instances", "body":{ "class":"message", "data":{ "body":"$body" } } }]}'
