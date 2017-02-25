
set -u -e

[ $# -eq 1 ]
home=$1

docker build -t refind https://github.com/evanx/refind.git

docker ps -q -f name=refind | xargs -r -n 1 docker rm -f

docker run --name refind -d \
  --restart unless-stopped \
  --network=host \
  -v $home/volumes/refind/data:/data \
  -e NODE_ENV=$NODE_ENV \
  -e host=localhost \
  refind
