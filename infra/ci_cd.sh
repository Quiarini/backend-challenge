#!/bin/bash

set -e  # Interrompe o script ao encontrar um erro
set -o pipefail  # Interrompe o script se um comando em um pipe falhar

# Variáveis de configuração
AWS_REGION="sa-east-1"
ECR_REPO="your-ecr-repo"  # Nome do repositório ECR
APPLICATION_NAME="your-java-app"  # Nome da sua aplicação
DOCKER_IMAGE_TAG="latest"
API_GATEWAY_NAME="your-api-gateway"
OPENAPI_SPEC="./jwtvalidator.yaml"
AWS_PROFILE="default"  # Nome do perfil do AWS CLI, altere conforme necessário

# Função para autenticar na AWS
function aws_authenticate() {
    echo "Autenticando na AWS com o perfil $AWS_PROFILE..."

    # Verifica se o perfil existe
    if ! aws configure list-profiles | grep -q "$AWS_PROFILE"; then
        echo "Perfil $AWS_PROFILE não encontrado. Verifique suas credenciais."
        exit 1
    fi

    # Definir a variável de ambiente para o perfil
    export AWS_PROFILE
}

# Função para validar e aplicar o Terraform
function terraform_deploy() {
    echo "Iniciando Terraform..."

    cd terraform  # Direcione para o diretório do Terraform

    echo "Executando Terraform Init..."
    terraform init

    echo "Executando Terraform Validate..."
    terraform validate

    echo "Executando Terraform Plan..."
    terraform plan

    echo "Executando Terraform Apply..."
    terraform apply -auto-approve
}

# Função para construir a aplicação Java
function build_java_app() {
    echo "Construindo a aplicação Java com Maven..."
    mvn clean package

    echo "Executando testes unitários..."
    mvn test
}

# Função para criar e enviar a imagem para o ECR
function build_and_push_image() {
    echo "Autenticando no ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

    echo "Construindo a imagem Docker..."
    docker build -t $APPLICATION_NAME .

    echo "Tagueando a imagem..."
    docker tag $APPLICATION_NAME:latest "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$DOCKER_IMAGE_TAG"

    echo "Enviando a imagem para o ECR..."
    docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$DOCKER_IMAGE_TAG"
}

# Função para realizar o deploy da imagem no EKS
function deploy_to_eks() {
    echo "Realizando o deploy da imagem no EKS..."

    kubectl set image deployment/$APPLICATION_NAME $APPLICATION_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$DOCKER_IMAGE_TAG"
}

# Função para fazer o deploy do contrato OpenAPI no API Gateway
function deploy_openapi() {
    echo "Deploying OpenAPI contract to API Gateway..."

    aws apigateway import-rest-api --parameters endpointConfigurationTypes=REGIONAL --body file://$OPENAPI_SPEC --region $AWS_REGION

    echo "API Gateway deployed successfully."
}

# Execução das funções
aws_authenticate
terraform_deploy
build_java_app
build_and_push_image
deploy_to_eks
deploy_openapi

echo "Pipeline de CI/CD concluído com sucesso."