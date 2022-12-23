#!/bin/bash

minikube version > /dev/null 2>&1 || {
echo "Please install minikube https://minikube.sigs.k8s.io/docs/start/" 
exit 
};

hyperkit -v > /dev/null 2>&1 || { 
echo "Please install minikube https://minikube.sigs.k8s.io/docs/drivers/hyperkit/"
exit 
};

making hyperkit the default driver for minikube
if [[ $(minikube config get driver) != 'hyperkit' ]]
	then
		minikube config set driver hyperkit
fi

# starting cluster
minikube start

# creating separate namespace 
kubectl create ns asset

# declaring function to apply yaml config
function applyYaml(){
    for FILE in $1; 
		do
			if [[ $FILE =~ yaml$ ]]
				then
					kubectl apply -f $FILE
			fi
	done
}

# calling function for config maps
applyYaml "./config-maps/*"

# calling function for deployments maps
applyYaml "./deployments/*"

# calling function for services maps
applyYaml "./services/*"

# enabling ingress
minikube addons enable ingress

# wait 30 secs
echo "Waiting 30 secs...";
sleep 30;

# calling function for ingress maps
applyYaml "./ingress/*"

# mapping hostname to minikube's IP address
echo "$(minikube ip) asset-management.com" | sudo tee -a /etc/hosts

echo "Visit http://asset-management.com for the application"