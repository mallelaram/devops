#!/bin/bash
service=$1
env=$2
cd /home/ubuntu/vigo/services/$env/$service
git pull
git checkout development
git pull origin development
commitid=`git rev-parse --short HEAD`


docker build -t 751394677851.dkr.ecr.ap-south-1.amazonaws.com/$service:$commitid .
docker tag  751394677851.dkr.ecr.ap-south-1.amazonaws.com/$service:$commitid 751394677851.dkr.ecr.ap-south-1.amazonaws.com/$service:$env-latest 
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 751394677851.dkr.ecr.ap-south-1.amazonaws.com 
docker push 751394677851.dkr.ecr.ap-south-1.amazonaws.com/$service:$commitid
docker push 751394677851.dkr.ecr.ap-south-1.amazonaws.com/$service:$env-latest



#for deploying
echo $service
cd /home/ubuntu/vigo/devops/helm/
git pull
# # echo "helm install $service ./$service/ -f ./$service/prod.yaml --set image.tag=$commitid" 
serviceStatus=`helm ls -n $env | grep $service `
if [ "$serviceStatus" == "" ]
then
    echo "service is not there so deploying"
    helm install $service ./$service/ -f ./$service/$env.yaml --set image.tag=$commitid -n $env
else
    echo "service is already there so upgrading it"
    helm upgrade $service ./$service/ -f ./$service/$env.yaml --set image.tag=$commitid -n $env
fi


