FROM alpine as builder

# Atualizando pacotes
RUN apk update

# Instalar Terraform
RUN apk add wget unzip curl

RUN wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip

RUN unzip terraform_1.8.2_linux_amd64.zip

RUN mv terraform /usr/local/bin/

 # Instalar o Python
RUN apk add python3

RUN apk add py3-pip

# instalar awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

WORKDIR /work/
COPY app/ .

# Instalar os requisitos minimos (requirements.txt)
RUN python3 -m pip install -r requirements.txt --break-system-packages

# CORRETO:
# ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} 
# ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
# ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

RUN mkdir aws


# STAGE 2
FROM alpine

WORKDIR /work

COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform 
COPY --from=builder /usr/local/bin/aws /usr/local/bin/aws
COPY --from=builder /work /work

# ARG AWS_ACCESS_KEY_ID
# ARG AWS_SECRET_ACCESS_KEY
# ARG AWS_DEFAULT_REGION

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION="us-east-1"

RUN echo "[default]" >> aws/credentials
RUN echo "aws_access_key_id = $(echo $AWS_ACCESS_KEY_ID)" >> aws/credentials 
RUN echo "aws_secret_access_key = $(echo $AWS_SECRET_ACCESS_KEY)" >> aws/credentials

RUN apk update && apk add python3 py3-pip
RUN python3 -m pip install -r requirements.txt --break-system-packages

EXPOSE 8080

# Rodar a aplicação
CMD ["python3", "app.py"]