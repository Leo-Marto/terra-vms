# #!/bin/bash

 source ./variable.env


 if [ -f "var.tfvars" ]; then
    rm var.tfvars
 fi
 touch var.tfvars

 echo 'resource_group_name="'"$RESOURCE_GROUP"'"' >> var.tfvars
 # echo $'\n'>> var.tfvars
 echo 'location="'"$LOCATION"'"' >> var.tfvars
 echo 'vm1="'"$VM1"'"' >> var.tfvars
 echo 'vm2="'"$VM2"'"' >> var.tfvars
 echo 'passvm="'"$PASSVM"'"' >> var.tfvars
 echo 'publickey="'"$PUBLICKEY"'"' >> var.tfvars
 echo 'crear="'"$CREAR"'"' >> var.tfvars
 cat var.tfvars
