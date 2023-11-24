#!/bin/bash

# Crear una VPC
AWS_ID_VPC=$(
  aws ec2 create-vpc \
    --cidr-block 192.168.0.0/22 \
    --output text \
    --query 'Vpc.VpcId'
)

# Asignar un nombre a la VPC
aws ec2 create-tags \
  --resources $AWS_ID_VPC \
  --tags Key=Name,Value=danipablo

# Función para crear una subred y una EC2 en esa subred
crear_subred_y_ec2() {
  local nombre_subred=$1
  local cantidad_trabajadores=$2
  local cidr_block=$3

  # Crear subred en la VPC
  AWS_ID_Subred=$(
    aws ec2 create-subnet \
      --vpc-id $AWS_ID_VPC \
      --cidr-block $cidr_block \
      --output text \
      --query 'Subnet.SubnetId'
  )

  # Crear grupo de seguridad en la VPC
  AWS_ID_GrupoSeguridad=$(
    aws ec2 create-security-group \
      --group-name "SecGroup$nombre_subred" \
      --description "Grupo de seguridad para $nombre_subred" \
      --vpc-id $AWS_ID_VPC \
      --output text \
      --query 'GroupId'
  )

  # Autorizar el tráfico SSH en el grupo de seguridad
  aws ec2 authorize-security-group-ingress \
    --group-id $AWS_ID_GrupoSeguridad \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

  # Crear instancia EC2 en la subred con el grupo de seguridad
  aws ec2 run-instances \
    --image-id ami-050406429a71aaa64 \
    --count $cantidad_trabajadores \
    --instance-type t2.micro \
    --region us-east-1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=ec2-$nombre_subred}]" "ResourceType=subnet,Tags=[{Key=Name,Value=subnet-$nombre_subred}]" \
    --security-group-ids $AWS_ID_GrupoSeguridad \
    --subnet-id $AWS_ID_Subred \
    --output text \
    --query 'Instances[*].InstanceId'
}

# Crear subredes y EC2 para cada red
crear_subred_y_ec2 "Desarrollo" 510 "192.168.0.0/23"
crear_subred_y_ec2 "Soporte" 254 "192.168.2.0/24"
crear_subred_y_ec2 "Ingeniaria" 126 "192.168.3.0/25"
crear_subred_y_ec2 "Mantenimiento" 30 "192.168.3.128/27"