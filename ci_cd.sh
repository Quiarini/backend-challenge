#!/bin/bash

set -e  # Interrompe o script ao encontrar um erro
set -o pipefail  # Interrompe o script se um comando em um pipe falhar

# Variáveis de configuração
AWS_REGION="sa-east-1"
ECR_REPO="jwt-validator"  # Nome do repositório ECR
APPLICATION_NAME="jwtvalidator"  # Nome da sua aplicação
DOCKER_IMAGE_TAG="latest"
API_GATEWAY_NAME="jwtvalidator"
API_GATEWAY_ID="3p12ith0e8"
OPENAPI_SPEC="jwtvalidator.yaml"
AWS_PROFILE="default"  # Nome do perfil do AWS CLI, altere conforme necessário
AWS_ACCOUNT_ID="155314306528"
EKS_CLUSTER_NAME="jwt-validator-cluster"

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

# Função para configurar o kubeconfig para o EKS
function configure_kubeconfig() {
    echo "Configurando o kubeconfig para o cluster EKS..."

    # Atualizar o kubeconfig com o cluster correto
    aws eks --region "$AWS_REGION" update-kubeconfig --name "$EKS_CLUSTER_NAME"

    kubectl config use-context arn:aws:eks:sa-east-1:155314306528:cluster/jwt-validator-cluster

    if [ $? -ne 0 ]; then
        echo "Falha ao configurar o kubeconfig para o cluster EKS. Verifique suas permissões e a configuração do cluster."
        exit 1
    fi
}

# Função para validar e aplicar o Terraform
function terraform_deploy() {
    echo "Iniciando Terraform..."

    cd infra  # Direcione para o diretório do Terraform

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
    cd ../app/jwtvalidator
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

    # Certifique-se de que o kubeconfig está configurado corretamente
    kubectl config get-contexts
    if [ $? -ne 0 ]; then
        echo "Falha ao obter o contexto do kubectl. Verifique a configuração do kubeconfig."
        exit 1
    fi

    # Aplicar os manifests com validação desativada
    kubectl apply -f ../manifests/. 
}

# Função para fazer o deploy do contrato OpenAPI no API Gateway
function deploy_openapi() {
    echo "Deploying OpenAPI contract to API Gateway..."

    cd ../../

    aws apigateway put-rest-api --rest-api-id $API_GATEWAY_ID --parameters basepath=prepend --mode overwrite --body fileb://$OPENAPI_SPEC --region $AWS_REGION

    aws apigateway create-deployment --rest-api-id $API_GATEWAY_ID --stage-name prod --description 'Version 001'

    echo "API Gateway deployed successfully."
}

# Execução das funções
aws_authenticate
terraform_deploy
build_java_app
build_and_push_image
configure_kubeconfig   # Adicionado: Configura o kubeconfig para o EKS
deploy_to_eks
deploy_openapi

echo "Pipeline de CI/CD concluído com sucesso."