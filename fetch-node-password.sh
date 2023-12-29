#!/bin/sh

read -p 'Username:' k_username
read -sp 'Password:' k_password
echo
export KUBECTL_VSPHERE_PASSWORD="$k_password"
read -p 'Cluster Name:' k_cluster_name
read -p 'Cluster Namespace:' k_cluster_namespace

login_cmd=$(kubectl vsphere login --server=10.220.55.98 --insecure-skip-tls-verify --vsphere-username "$k_username" --tanzu-kubernetes-cluster-namespace "$k_cluster_namespace" 2>login_error.txt 1>login_out.txt)

if [ -s login_error.txt ]; then
    echo "Error occured during login:"
    cat login_error.txt
    rm -f login_error.txt
    rm -f login_out.txt
    exit 1
else
    ns_context=$(kubectl config use-context "$k_cluster_namespace" 2>ns_login_error.txt 1>ns_login_out.txt ) 
    if [ -s ns_login_error.txt ]; then
        echo "Error occured while logging in to namespace context:"
        cat ns_login_error.txt
        rm -f ns_login_error.txt
        rm -f ns_login_out.txt
        exit 1
    else
        echo "Logged into Namespace Context"
        secretname=$k_cluster_name"-ssh-password"
        echo "Retrieving secret value"
        get_secret=$(kubectl get secret "$secretname" -o yaml | grep ssh-passwordkey | awk '{print $2}' | base64 -d 2>getsecret_error.txt 1>getsecret_out.txt)
        if [ -s getsecret_error.txt ]; then
            echo "Error occured while retrieving secret:"
            cat getsecret_error.txt
            rm -f getsecret_error.txt
            rm -f getsecret_out.txt
            exit 1
        else
            echo "Password for your cluster nodes: $get_secret"
            rm -f getsecret_out.txt
            rm -f getsecret_error.txt
            exit 0
        fi
        rm -f ns_login_error.txt
        rm -f ns_login_out.txt
        exit 0
    fi
    rm -f login_error.txt
    rm -f login_out.txt
    exit 0
fi