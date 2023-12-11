# Crear una VPC
AWS_ID_VPC_DANIELMORALES=$(
  aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --output text
)

# Asignar un nombre a la VPC
aws ec2 create-tags \
  --resources $AWS_ID_VPC_DANIELMORALES \
  --tags Key=Name,Value=VPCDANIELMORALES

# Crear una subnet en la VPC
AWS_ID_Subnet_DANIELMORALES=$(
  aws ec2 create-subnet \
    --vpc-id $AWS_ID_VPC_DANIELMORALES \
    --cidr-block 10.0.0.0/24 \
    --availability-zone us-east-1a \
    --output text
)

# Asignar un nombre a la subnet
aws ec2 create-tags \
  --resources $AWS_ID_Subnet_DANIELMORALES \
  --tags Key=Name,Value=SubnetDANIELMORALES

# Crear un grupo de seguridad para la VPC
AWS_ID_GrupoSeguridad_VPC_DANIELMORALES=$(
  aws ec2 create-security-group \
  --group-name 'SecGroupVPCDANIELMORALES' \
  --description 'Permitir conexiones SSH en la VPC' \
  --vpc-id $AWS_ID_VPC_DANIELMORALES \
  --output text
)

# Autorizar el tráfico SSH en el grupo de seguridad de la VPC
aws ec2 authorize-security-group-ingress \
  --group-id $AWS_ID_GrupoSeguridad_VPC_DANIELMORALES \
  --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow SSH"}]}]'

# Crear una instancia EC2 en la VPC
AWS_ID_Instancia_EC2_DANIELMORALES=$(
  aws ec2 run-instances \
    --image-id ami-050406429a71aaa64 \
    --count 1 \
    --instance-type m1.small \
    --key-name vockey \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2DANIELMORALES}]' \
    --security-group-ids $AWS_ID_GrupoSeguridad_VPC_DANIELMORALES \
    --subnet-id $AWS_ID_Subnet_DANIELMORALES \
    --query 'Instances[0].InstanceId' \
    --output text
)

echo "VPC creada con ID: $AWS_ID_VPC_DANIELMORALES"
echo "Subnet creada con ID: $AWS_ID_Subnet_DANIELMORALES"
echo "Grupo de seguridad de la VPC creado con ID: $AWS_ID_GrupoSeguridad_VPC_DANIELMORALES"
echo "Instancia EC2 creada con ID: $AWS_ID_Instancia_EC2_DANIELMORALES"
