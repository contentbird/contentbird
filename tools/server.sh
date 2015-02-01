if [ -f .env ]; then
  source .env
  echo ".env file found: server will use use ENV['PORT'] which is $PORT";
  zeus s -p $PORT
else
  echo "No .env found: Running zeus server on default port";
  zeus s
fi