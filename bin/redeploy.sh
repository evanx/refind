
set -u -e -x

home=${1-$HOME/tmp/test}

docker build -t refind https://github.com/evanx/refind.git

docker ps -q -f name=refind | xargs -r -n 1 docker rm -f

container=`docker run --name refind -d \
  --restart unless-stopped \
  --network=host \
  -v $home/volumes/refind/data:/data:ro \
  -e NODE_ENV=$NODE_ENV \
  -e host=localhost \
  refind | cut -b1-6`

echo "docker logs $container"

docker logs -f `docker ps -q -f name=refind`
