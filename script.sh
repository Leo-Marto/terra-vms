#!/bin/bash

source ./variable.env



# Definir variables

USER="adminUser"
BACK_VM="back"
DB_VM="db"
IP_DIR=""


# Cargamos los argumentos a las variables

while getopts ":r:l:b:d" opt; do
   case $opt in
          r)
            RESOURCE_GROUP="$OPTARG";;
          l)
            LOCATION="$OPTARG";;
          b)
            BACK_VM="$OPTARG";;
          d)
            DB_VM="$OPTARG";;
   esac
done

if [ -z "$RESOURCE_GROUP" ]; then
  echo " Para el uso correcto del comando se debe carga de forma obligatoria"
  echo " -r <NOMBRE_RESOURCE_GROUP> "

fi
# if [ -z "$VM_NAME" ]; then
#   echo " Se debe cargar el nombre del de la VM"
#   exit 1
# fi
# if [ -z "$USER" ]; then
#   echo " Se debe cargar el nombre de usuario"
#   exit 1
# fi
# if [ -z "$INVENTORY_FILE" ]; then
#   echo " Se debe cargar el nombre del grupo de recursos"
#   exit 1
# fi

echo "las variables tomadas son Grupo de recursos: "
echo "Grupo de recursos: $RESOURCE_GROUP "
echo "Ubicacion: $LOCATION "
echo "Nombre maquina virtual Back: $BACK_VM "
echo "Nombre maquina virtual Base de datos: $DB_VM "

if [ -f "var.tfvars" ]; then
   rm var.tfvars
fi
touch var.tfvars

echo 'resource_group_name="'"$RESOURCE_GROUP"'"' >> var.tfvars
#echo $'\n'>> var.tfvars
echo 'location="'"$LOCATION"'"' >> var.tfvars
echo 'vm1="'"$BACK_VM"'"' >> var.tfvars
echo 'vm2="'"$DB_VM"'"' >> var.tfvars
cat var.tfvars

terraform init

if [ $? -eq 0 ]; then
  echo ""
  echo "Ejecutando Terraform Plan"
  terraform plan -var-file="var.tfvars"
  if [ $? -eq 0 ]; then
    echo ""
    echo "Ejecutando Terraform Apply"
    terraform apply -var-file="var.tfvars" -auto-approve
    else
    exit 1
  fi
else
exit 1
fi
