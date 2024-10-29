# #!/bin/bash

 source ./variable.env



# # Cargamos los argumentos a las variables

#  while getopts ":r:l:b:d" opt; do
#     case $opt in
#            r)
#              RESOURCE_GROUP="$OPTARG";;
#            l)
#              LOCATION="$OPTARG";;
#            b)
#              BACK_VM="$OPTARG";;
#            d)
#              DB_VM="$OPTARG";;
#     esac
#  done





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
 echo 'pucblickey="'"$PUBLICkey"'"' >> var.tfvars
 echo 'crear="'"$CREAR"'"' >> var.tfvars
 cat var.tfvars
