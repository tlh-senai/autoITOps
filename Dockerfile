FROM ubuntu:22.04 as builder

# Atualizando pacotes
RUN apt update -y 

# Instalar Terraform
RUN apt-get install wget unzip curl -y

RUN wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip

RUN unzip terraform_1.8.2_linux_amd64.zip

RUN mv terraform /usr/local/bin/

 # Instalar o Python
RUN apt-get install python3.9 -y 

RUN apt install python3-pip -y

# instalar awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

WORKDIR /work/
COPY app/ .

# Instalar os requisitos minimos (requirements.txt)
RUN python3 -m pip install -r requirements.txt

# CORRETO:
# ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} 
# ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
# ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

RUN mkdir aws


# STAGE 2
FROM ubuntu:22.04

WORKDIR /work

COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform 
COPY --from=builder /usr/local/bin/aws /usr/local/bin/aws
COPY --from=builder /work /work

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

# ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
# ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
# ENV AWS_DEFAULT_REGION="us-east-1"

RUN echo "[default]" >> aws/credentials
RUN echo "aws_access_key_id = $(echo $AWS_ACCESS_KEY_ID)" >> aws/credentials FROM alpine:latest as builder

# Instalando dependências
RUN apk add --no-cache wget unzip curl build-base libffi-dev openssl-dev

# Instalando Terraform
RUN wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip && \
    unzip terraform_1.8.2_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.8.2_linux_amd64.zip

# Configurando diretório de trabalho
WORKDIR /work

# STAGE 2: Final
FROM alpine:latest

WORKDIR /work

COPY app/ .

# Copiando binários e arquivos da STAGE 1
COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform
COPY --from=builder /work /work

RUN apk add --no-cache aws-cli

RUN apk add --no-cache python3 py3-pip

# Copiando credenciais da AWS
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG AWS_SESSION_TOKEN

# RUN mkdir aws
RUN touch aws/credentials
RUN echo "[default]" >> aws/credentials && \
    echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> aws/credentials && \
    echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> aws/credentials && \
    echo "aws_session_token = $AWS_SESSION_TOKEN" >> aws/credentials

# Instalando dependências Python
RUN apk add --no-cache python3 py3-pip

RUN pip3 install --no-cache-dir --user --break-system-packages -r requirements.txt

RUN terraform init

# Configurando o diretório de trabalho


# Expondo a porta 8080
EXPOSE 8080

# Executando a aplicação
CMD ["python3", "app.py"]
RUN echo "aws_secret_access_key = $(echo $AWS_SECRET_ACCESS_KEY)" >> aws/credentials

RUN apt-get update && apt-get install -y python3.9 python3-pip
RUN python3 -m pip install -r requirements.txt

EXPOSE 8080

# Rodar a aplicação
CMD ["python3", "app.py"]