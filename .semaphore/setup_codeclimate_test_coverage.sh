cache restore cc-test-reporter-$(date +%F)

if [ -f 'cc-test-reporter' ]; then
  echo 'found test reporter in cache'
else
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
  chmod +x ./cc-test-reporter
  cache store cc-test-reporter-$(date +%F) cc-test-reporter
fi

./cc-test-reporter before-build
