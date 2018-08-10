#!/bin/bash

dockerRepo=""
imagePath="andresvilla/utility-image"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -d|--docker-repo)
    dockerRepo="$2"
    shift # past argument
    ;;
    -p|--image-path)
    imagePath="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

date=$(date +%s)
buildVersion="$date"
imageName=${dockerRepo}${imagePath}

#Build regular image
docker build -t "${imageName}:${buildVersion}" -t "${imageName}:latest" .
buildResult=$?
printf "\n\n\n\n==============FINISHED REGULAR BUILD==============\n\n\n\n"

#Build gpu image
docker build -t "${imageName}-gpu:${buildVersion}" -t "${imageName}-gpu:latest" ./gpu
gpuBuildResult=$?
printf "\n\n\n\n==============FINISHED GPU BUILD==============\n\n\n\n"


if [[ ($buildResult -ne 0 || $gpuBuildResult -ne 0)]]; then
  echo "Docker build failed"
  exit 1
fi

echo "image: ${imageName}:${buildVersion}"
echo "image: ${imageName}-gpu:${buildVersion}"

while true; do
    read -p "Do you want to push these versions?:" yn
    case $yn in
        [Yy]* ) docker push "${imageName}:${buildVersion}"
                docker push "${imageName}-gpu:${buildVersion}"
                exit;;
        [Nn]* ) break;;
        * ) echo "Please answer y or n.";;
    esac
done