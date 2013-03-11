echo "Configuring Class"
source credentials.txt
curl https://rest.fauna.org/v1/classes/message/config -X PUT -u $FAUNA_PUBLISHER_KEY: -d '{"data" : {"desc" : "An amazing Chat Message."}}'
echo ""
echo "Done"
