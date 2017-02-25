
set -u -e

PATH=$PATH:./node_modules/.bin

name='resend'
network="$name-network"
redisName="$name-redis"

tearDown() {
  docker-rm-redis $name
}

setUp() {
  redisHost=`docker-run-redis $name`
}

build() {
  docker build -t resend https://github.com/evanx/resend.git
}

start() {
  docker run --name resend-instance -d \
    --network=resend-network \
    -e redisHost=$redisHost \
    resend
}

stop() {
  docker rm -f resend-instance
}

main() {
    tearDown
    setUp
    sleep 1
    build
    start
    stop
    tearDown
    echo 'OK'
}

main
