echo "Preparing Command: reply_message"
#curl https://rest.fauna.org/v0/commands/reply_message -X PUT -u AQAAS6hRHMAAAABB9FVmsAAAXH9CRKgC6N801bp80lKB1g: -d '{ "comment": "Reply a Message", "actions":[{"method":"POST", "path":"/v0/instances", "body":{ "class":"message", "data":{ "body":"$body" } } }, {"method":"POST", "path":"/v0/classes/message/timelines/chat/", "body": {"resource": "$0"}}]}'
curl https://rest.fauna.org/v0/commands/reply_message -X PUT -u AQAAS6hRHMAAAABB9FVmsAAAXH9CRKgC6N801bp80lKB1g: -d '{ "comment": "Reply a Message", "actions":[{"method":"POST", "path":"/v0/instances", "body":{ "class":"message", "data":{ "body":"$body" } } }]}'
echo "Invoking Command"
curl https://rest.fauna.org/v0/commands/reply_message -X POST -u AQIAT9qymjAAAABJd3D_AAAAAEH0VWawAAABAEbK2k9gAABuUBqDLSjdEsmvUUWrxE_zAAAAAAAAAA: -d '{ "body": "My message" }'
