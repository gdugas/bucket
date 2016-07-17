#!/bin/sh

here_path=`pwd`
pwd=`pwd`
bucket_path=`dirname $pwd/$0`

image_dir=$bucket_path/image.d
container_dir=$bucket_path/container.d


cd $image_dir
for module in `ls -d1 *`; do
    if [ -f $module/Dockerfile ]; then
        tags=
        for tag in `cat $module/tags`; do
            tags="$tags -t $tag"
        done
        docker build $tags --pull $module
    fi
done


cd $container_dir
if [ ! -f docker-compose ]; then
    curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > ./docker-compose
    chmod +x ./docker-compose
fi

if [ ! -f docker-compose.yml ]; then
    echo 'version: "2"' > docker-compose.yml
fi

compose_args="-f ./docker-compose.yml"
for module in `ls -d1 *`; do
    if [ -f $module/docker-compose.yml ]; then
        compose_args="$compose_args -f $module/docker-compose.yml"
    fi
done

cmd="./docker-compose $compose_args $@"
echo $cmd && $cmd

cd $here_path
