#!/bin/bash

# Crear una VPC
AWS_ID_VPC=$(
  aws ec2 create-vpc \
    --cidr-block 192.168.0.0/22 \
    --output text
)

# Asignar un nombre a la VPC
aws ec2 create-tags \
  --resources $AWS_ID_VPC \
  --tags Key=Name,Value=MiVPC

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
      --output text
  )

  # Crear grupo de seguridad en la VPC
  AWS_ID_GrupoSeguridad=$(
    aws ec2 create-security-group \
      --group-name "SecGroup$nombre_subred" \
      --description "Grupo de seguridad para $nombre_subred" \
      --vpc-id $AWS_ID_VPC \
      --output text
  )

  # Autorizar el tráfico SSH en el grupo de seguridad
  aws ec2 authorize-security-group-ingress \
    --group-id $AWS_ID_GrupoSeguridad \
    --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow SSH"}]}]'

  # Crear instancia EC2 en la subred con el grupo de seguridad
  aws ec2 run-instances \
    --image-id ami-050406429a71aaa64 \
    --count $cantidad_trabajadores \
    --instance-type t2.micro \
    --key-name tu-key-name \
    --region us-east-1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=ec2-$nombre_subred}]","ResourceType=subnet,Tags=[{Key=Name,Value=subnet-$nombre_subred}]" \
    --security-group-ids $AWS_ID_GrupoSeguridad \
    --subnet-id $AWS_ID_Subred
}

# Crear subredes y EC2 para cada red
crear_subred_y_ec2 "Red1" 510 "192.168.0.0/23"
crear_subred_y_ec2 "Red2" 254 "192.168.2.0/24"
crear_subred_y_ec2 "Red3" 126 "192.168.3.0/25"
crear_subred_y_ec2 "Red4" 30 "192.168.3.128/27"