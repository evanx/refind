
set -u -e

PATH=$PATH:./node_modules/.bin

name='refind'
network="$name-network"
redisName="$name-redis"

tearDown() {
   docker-rm-redis $name
}

setUp() {
   redisHost=`docker-run-redis $name`
}

build() {
   docker build -t refind https://github.com/evanx/refind.git
}

start() {
   docker run --name refind-instance -d \
      --network=refind-network \
      -e redisHost=$redisHost \
      -v /tmp/test/volumes/refile/data:/data \
      refind
}

test() {
   curl -s http://localhost:8871/re/analytics | grep '"counts":'
}

stop() {
   docker rm -f refind-instance
}

main() {
   tearDown
   setUp
   sleep 1
   build
   start
   test
   stop
   tearDown
   echo 'OK'
}

main
