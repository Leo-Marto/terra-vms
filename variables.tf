variable "resource_group_name" {
    description = "Nombre del grupo de recursos"
    type = string
  
}

variable "location" {
    description = "Location del RG y solucion"
    type = string  
}

variable "vm1" {
    description = "Nombre de la VM para el back"
    type = string
     
}

variable "vm2" {
    description = "Nombre de la VM para la DB de psotgreSQL"
    type = string
}
