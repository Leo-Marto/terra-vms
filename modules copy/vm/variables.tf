variable "resource_group_name" {
    description = "Nombre del grupo de recursos"
    type = string
  
}

variable "location" {
    description = "Location del RG y solucion"
    type = string  
}

variable "name" {
    description = "Nombre de la VM"
    type = string  
}



variable "publickey" {
    description = "Nombre de la VM para la DB de psotgreSQL"
    type = string
}

variable "passvm" {
    description = "Nombre de la VM para la DB de psotgreSQL"
    type = string
}

variable "id_interface" {
    description = "ID de la interface de red a usar"
    type = string
}
