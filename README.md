
## Bem-vindo

Estamos muito felizes por você estar pensando em se juntar a nós! Esse é um teste feito para conhecer um pouco mais de cada candidato. Não se trata de um teste objetivo, capaz de gerar uma nota ou uma taxa de acerto, mas sim de um estudo de caso com o propósito de conhecer os conhecimentos, experiências e modo de trabalhar de um candidato. Não experamos que tudo seja feito perfeitamente, pois valorizamos o seu tempo. Sinta-se livre para desenvolver sua solução para o problema proposto.

Este desafio está dividido em 4 partes:

1. Implementação
2. Depuração
3. Melhorias
4. Perguntas

## Requisitos para o desafio

- Github Account

Se você encontrar possíveis melhorias a serem feitas neste desafio, fique a vontade para descreve-lás.

## Sobre o Desafio:

A ELO executa a maior parte de sua infraestrutura em Kubernetes. É um monte de microserviços conversando entre si e realizando diversas tarefas.

Nesse repositório, fornecemos a você:

- 'sre-challenge-app/': Uma aplicação com CRUD que armazena dados de funcionários em um Banco de dados MySQL 8.

## Configure o ambiente do desafio

1. Instale qualquer cluster K8s local (ex: Minikube) em sua máquina e documente sua configuração, para que possamos executar sua solução.


## Instalação Minikube

Configuração mínima local para rodar:
```
Processamento: 2 core;
Memória: 6 GB;
HD: 50 GB.
Oracle Virtual Box com CentOS Linux 8, imagem pronta (osboxes) para lab.
Server: Docker Engine - Community Version:24.0.6
```

Devido a uma limitação de HW tive que subir o cluster com um node e toda a solução foi configurada setando recursos unicos mas, apenas para efeito de lab.
Em produção o mínimo para subir um cluster k8s são 3 nodes.


## Garantir que o Docker esteja no ar:
```
$sudo systemctl start docker
$sudo systemclt status docker
```
## Proceddimento de instalação do Minikube (k8s)
```
$cd /tmp

$curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

$chmod +x ./minikube

$sudo mv ./minikube /usr/local/bin/minikube

$minikube version

$minikube start
```

## Ao chegar no final, se tudo ocorrer bem vai visualizar uma mensagem como esta:

* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

Para validar, rode o seguinte comando e veja se a saída será próxima disso:
```
[osboxes@osboxes k8s]$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   41m   v1.28.3
```

## Parte 1 - Configure os aplicativos

Gostariamos que essa aplicação sre-challenge-app e seu banco de dados fossem executados em um cluster K8s.

Requisitos

1. A aplicação deve ser acessível de fora do cluster.
2. Manifestos de implantação do kubernetes para executar com limitação de requests e usando HPA.

## Subindo o mysql com docker-compose para teste:

$docker-compose up -d

Neste ponto tive que adicionar a rede para comunicação interna entre aplicação e banco de dados e declarar a rede para os serviços:
```
#networks:
#  rotten_net:
#            driver: bridge
```

 - Remoção da váriavel de usuário root do bloco "environment" pois, após a primeira subinda do banco é validado se no deployment foi passado variável com usuário root, sendo considerado falta grave de segurança.

 - Realizado também o ajuste da variável "image" que estava fora do padrão.

 - Com isso o mysql subiu e foi possível rodar um #docker container ls para garantir que estava no ar.


## Build da aplicação
# Dentro do diretorio raiz do projeto:

 1 - $docker build -t arlindomcorrea/sre-challange-elo:v1 .

 2 - $docker login (logar no docker hub com credenciais validas para que seja possível subir e baixar imagens)

 3 - $docker push arlindomcorrea/sre-challange-elo:v1 (Envidando a imagem para o Docker Hub)

Concluido essa fase com sucesso, basta acessar o console web do Docker Huber e garantir que o repositório e a imagem estão refletidos na ferramenta.
Com isso podemos rodar o comando: $docker-compose up -d para subir a aplicação e banco de dados.


Para validar, rode o seguinte comando:
$docker container ls
$curl localhost:8080 (chamando a url/porta da aplicação)

Vai visualizar os containers que estão no ar com seus respectivos nomes.

## Teste UP/Down do docker-compose
$docker-compose up -d (Sobe todos os containers declarados exibindo o nome do container com o status "Started"
$docker-compose down baixa todos os containers novamente.


## Iniciando a implementação do k8s com o Minikube

## Crie um diretório local para fazer o git clone e organizar os projetos localmente
#Para fazer o git clone via ssh é necessário criar uma chave ssh da seguinte forma:
```
$ssh-keygen -t ed25519 -C "<email@git>"
$ssh-add path/id_ed25519
$cat path//id_ed25519.pub
```
Cadastrar a chave nas configurações de chave ssh do git.

#Criei a seguinte estrutura local, para baixar o projeto:
```
$mkdir /home/osboxes/ELO-SRE
$git clone git@github.com:ELO-SRE/sre-challenge-elo.git
```

# O diretorio k8s é onde estão os manifestos do cluster.
```
/home/osboxes/ELO-SRE/sre-challenge-elo
[osboxes@osboxes sre-challenge-elo]$ ls
ca.jpg  docker-compose.yml  Dockerfile  k8s  mvnw  mvnw.cmd  pom.xml  README.md  src
```
```
[osboxes@osboxes k8s]$ pwd
/home/osboxes/ELO-SRE/sre-challenge-elo/k8s
[osboxes@osboxes k8s]$ ls -larth
total 20K
-rw-rw-r--. 1 osboxes osboxes  235 Mar 21 21:11 mysql-pv.yaml
-rw-rw-r--. 1 osboxes osboxes  219 Mar 21 22:31 mysql-pvc.yaml
-rw-rw-r--. 1 osboxes osboxes  172 Mar 22 05:21 creds.yaml
-rw-rw-r--. 1 osboxes osboxes 2.1K Mar 22 05:29 web.yaml
-rw-rw-r--. 1 osboxes osboxes 1.6K Mar 22 07:34 mysql.yaml
drwxrwxr-x. 2 osboxes osboxes  101 Mar 22 07:34 .
drwxrwxr-x. 6 osboxes osboxes  249 Mar 22 09:34 ..
[osboxes@osboxes k8s]$
```
 1 -       web.yaml - app
 2 -     mysql.yaml - DB
 3 -  mysql-pv.yaml - Vol.DB
 4 - mysql-pvc.yaml - Req. Vol.DB
 5 -     creds.yaml - Secrets (não habilitado)


# Deployment Mysql

 1 - 
    name: mysqldb
    image: mysql:8.0.23
 2 -
    Foi necessário postergar a configurção das Secrets pois, estava enfrentando muitos problemas com o ambiente e vou colocar essa atividade no backlog para refinamento.

 3 - O kind de Secrets foi criado, as variaveis definidas e senhas base64 porém, ficou para a proxima sprint. :)

 4 - Configurado limits e requests conforme pré requisitos de subida do ambiente e limitação do HW do lab.

 5 - Criado os manifestos dos volumes, pv e pvc.

 6 - Service configurado conforme os requisitos do mysql.

Foi necessário troubleshooting para subir o pod devido a requisitos de segurança e warnings de variaveis com usuáiro root.
Não é uma boa prática então, vou registrar no backlog esse ponto de melhoria para ajustar usuários e subir o kind de Secret do k8s.

Entendo também que não é uma boa prática subir um banco de dados no k8s, a sugestão é que a instancia de banco seja uma instancia apartada na AWS ou AZURE e se for viavél uma instancia auto gerenciada melhor ainda.


# Deployment APP

 1 - Configrado HPA, apesar da limitação de HW do meu lab não permitir subir mais nodes, pods, a configuração foi realizada e está disponivel para ajustes conforme a disponibilidade da capacidade do cluster como um todo. A configuração está com o averageUtilization: 50 baseado nos requests.

    name: hpa-sre-challenge-app

 2 - Resources com limits e requests configurados.

 3 - Não habilitei as secrets pelos motivos já mencionados anteriormente, ficando no backlog essa melhoria priorizada devido a criticidade.

 4 - Foi configurado um kind do tipo NodePort, foi realizado as configurações de Port-Foward e outras tentativas de expor a aplicação para fora do cluster porém, até o momento essa configuração não funcionou da forma esperada. Com isso, será necessário refinamento técnico para solucionar este ponto.

Foi necessário troubleshooting devido a aplicação está tentando subir na porta 8080 conflitando com o apache que já estava ocupando a mesma.
Após o ajuste para a aplicação subir na porta 8081, realizado e gerado novamente o build e deploy a aplicação subiu 100% ready no pod.

   imagem: arlindomcorrea/sre-challenge-elo:v1

Foi realizado o upload da imagem para o Docker Hub de forma publica.
 


## Criando um namespace para subir o ambiente

$kubectl create ns challenge



## Parte 2 - Corrigir o problema

A aplicação tem um problema. Encontre e corrija! Você saberá que corrigiu o problema quando o estado dos pods no namespaces for semelhante a este:

```
NAME                                 READY   STATUS    RESTARTS   AGE
db-5877fd4d4d-qmngl                  1/1     Running   0          6m50s
sre-challenge-app-59fd5ffc57-lm2xs   1/1     Running   0          7s
```

Requisitos

Escreva aqui sobre o problema, a solução, como você a encontrou e qualquer outra coisa que queira compartilhar sobre ela.


## Resultado do troubleshooting da aplicação
```
[osboxes@osboxes k8s]$ kubectl get pods -n challenge
NAME                                READY   STATUS    RESTARTS         AGE
mysqldb-66cdbc7cc9-jzk9d            1/1     Running   1 (106m ago)     3h11m
sre-challenge-app-99b9f4cb6-qbd96   1/1     Running   12 (5m23s ago)   54m
```
Durante o lab encontrei diversos problemas e fui corrigindo conforme a detecção e requisitos, porém, em um momento que tentei subir a APP peguei nos logs do pod conflito de porta com o apache, usei o comando netstat para identificar o conflito e tomei a decisão de alterar a porta da aplicação de 8080 para 8081.

Com isso refiz o build, atualizei o registry e a aplicação subiu normalmente.

## Parte 3 - Melhores práticas

Essa aplicação tem uma falha de segurança e gostariamos que as credenciais do MYSQL fossem armazenadas em uma secret do Kubernetes.

Requisitos
1. Manifesto do kubernetes usando a API de secret com as credenciais do Banco para implantação.
Deixei essa atividade em backlog para continuar com mais calma devido a problemas de indisponibilidade do cluster, crashs e demais problemas enfrentados durante o lab. Porém, o kind de Secret já está configurado e as variáveis setadas, restando apenas subir e testar.
2. Manifesto do kunernetes da aplicação com as informações da secret criada anteriormente.
Mantive apenas um manifesto criado, porém, desabilitado para continuar o setup nas próximas horas.
3. Configuração do código da aplicação utilizando uma variável que foi referenciada no secrets do K8s (Application Properties do Java)
Como não subi o kind de Secrets o properties foi mantido sem alteração, entendo a falha de segurança, porém a atividade está em andamento e priorizada.
Foi necessário quebrar a atividade devido as intercorrencias encontradas pelo caminho.

## Parte 4 - Perguntas

Sinta-se à vontade para expressar seus pensamentos e compartilhar suas experiências com exemplos do mundo real com os quais você trabalhou no passado.

Requisitos
O que você faria para melhorar essa configuração e torná-la “pronta para produção”?

Vejo a necessidade de levar o banco para uma instancia apartada do cluster, sugestão seria levar para um serviço gerenciado na AWS ou AZURE, porque questões de boas práticas, performance, escalabidade e disponibilidade.

Colocaria no mínimo 3 nodes no cluster para conseguir subir replicas dos pods da aplicação e conseguir resiliência, escalabilidade e disponibilidade, além de melhorar a orquestração e conseguir ganhos em termos de Self-healing que o k8s nos proporciona.

A parte da seguranção é um item priorizado, sem essa parte aplicada é impossível subir a solução para produção.

Realizaria um teste de carga com alguma ferramenta disponivel e colocaria um nível mínimo de Observabilidade com Traces, Métricas e logs e monitores de golden signals trafego, latência, erros e saturação, com alertas estrategicos para sermos avisados de intercorrências em produção.

Existem 2 microsserviços mantidos por 2 equipes diferentes. Cada equipe deve ter acesso apenas ao seu serviço dentro do cluster. Como você abordaria isso?
Como você evitaria que outros serviços em execução no cluster se comunicassem com o sre-challenge-app?

Para os acesso apartado os serviços poderiam rodar em namespaces diferentes e poderiamos subir roles diferencias para cada equipe portar a sua role com os devidos limites. Para a questão da comunicação, podemos seguir com a estrategia de apartar os serviços em namespaces diferentes e ainda utilizar SGs para limitar o trafego de ingress e egress.


## O que é importante para nós?

É claro que esperamos que a solução funcione, mas também queremos saber como você trabalha e o que é importante para você como engenheiro. Portanto, fique à vontade para criar novos arquivos, refatorar, renomear, ...

Idealmente, gostaríamos de ver sua progressão através de commits, verbosidade em suas respostas e todos os requisitos atendidos. Não se esqueça de atualizar o README.md para explicar seu processo de pensamento.

## Entrega do desafio:

Ao terminar o desafio, convide o 'ELO-SRE' para contribuir com o seu repositório de desafios para que possamos fazer a avaliação. Boa Sorte

<p align="center">
  <img src="ca.jpg" alt="Challange accepted" />
</p>
