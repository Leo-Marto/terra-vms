#!/bin/bash



# Definir variables
RESOURCE_GROUP="dev2"
LOCATION="westus"
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

if [ -f "vars.tfvars" ]; then
   rm vars.tfvars
fi
touch vars.tfvars

echo 'resource_group_name="'"$RESOURCE_GROUP"'"' >> vars.tfvars
#echo $'\n'>> vars.tfvars
echo 'location="'"$LOCATION"'"' >> vars.tfvars
echo 'vm1="'"$BACK_VM"'"' >> vars.tfvars
echo 'vm2="'"$DB_VM"'"' >> vars.tfvars
cat vars.tfvars

terraform init

if [ $? -eq 0 ]; then
  echo ""
  echo "Ejecutando Terraform Plan"
  terraform plan -var-file="vars.tfvars"
  if [ $? -eq 0 ]; then
    echo ""
    echo "Ejecutando Terraform Apply"
    terraform apply -var-file="vars.tfvars" -auto-approve
    else
    exit 1
  fi
else
exit 1
fi

chmod 0600 ./ssh_$RESOURCE_GROUP\_key

IP_DIR=$(az vm show --resource-group $RESOURCE_GROUP --name $RESOURCE_GROUP-VM --show-details --query "publicIps" --output tsv)
if [ -f "inventory.ini" ]; then
   rm inventory.ini
fi
SSH_KEY="./ssh_"$RESOURCE_GROUP"_key"


echo "[back]" >> inventory.ini
echo "$IP_DIR ansible_user=$USER ansible_ssh_private_key_file=$SSH_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' " >> inventory.ini
echo "[db]" >> inventory.ini
echo "10.0.2.5 ansible_user=$USER ansible_ssh_private_key_file=$SSH_KEY "  >> inventory.ini
echo "[db:vars]" >> inventory.ini
echo "ansible_ssh_common_args='"'-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i '$SSH_KEY -W %h:%p $USER@$IP_DIR'"'"'" >> inventory.ini


# Número máximo de intentos
MAX_INTENTOS=20

# Contador de intentos
intento=1

echo "Probando conexión con el inventario en el inventario..."

# Bucle para probar la conexión
while [ $intento -le $MAX_INTENTOS ]; do
  echo "Intento $intento de $MAX_INTENTOS..."

  # Ejecuta el comando de prueba de conexión
  ansible all -m ping -i inventory.ini > /dev/null 2>&1

  # Comprueba si la conexión fue exitosa
  if [ $? -eq 0 ]; then
    echo "Conexión exitosa en el intento $intento."
    ansible-playbook microk8s.yaml -vvv
    exit 0
  else
    echo "Fallo de conexión en el intento $intento."
  fi

  # Incrementa el contador de intentos
  intento=$((intento + 1))
  echo "Esperando un minuto para realizar un nuevo intento"
  # Espera 1 minuto antes del siguiente intento
  sleep 60
done









