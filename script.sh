terraform init

if [ $? -eq 0 ]; then
  echo ""
  echo "Ejecutando Terraform Plan"
  terraform plan -var-file="vars.tfvars" -lock=false
  if [ $? -eq 0 ]; then
    echo ""
    echo "Ejecutando Terraform Apply"
    terraform apply -var-file="vars.tfvars" -auto-approve -lock=false
    else
    exit 1
  fi
else
exit 1
fi