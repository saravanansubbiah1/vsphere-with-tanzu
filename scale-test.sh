#!/bin/bash
read -p 'Enter the number of VMs to be deployed: ' vmcount
for (( c=1; c<=$vmcount; c++ ))
do
    filename="deployvm_${c}.yaml"
    cat <<EOF > "$filename"
apiVersion: vmoperator.vmware.com/v1alpha1
kind: VirtualMachine
metadata:
  name: scale-test-vm-$c
  namespace: scale-test
spec:
  imageName: ubuntuova
  className: best-effort-xsmall
  powerState: poweredOn
  storageClass: vwt-storage-policy
  networkInterfaces:
  - networkName: vlan-20-pg
    networkType: vsphere-distributed
  vmMetadata:
      configMapName: scale-test-cm  ---> update your config-map name
      transport: CloudInit
EOF
    echo "Created $filename"
#    echo "Creating VM using kubectl apply"
    k apply -f $filename
done
