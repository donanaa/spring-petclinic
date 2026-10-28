# Jenkins내에 Docker 설치 시 주석 해제
#COPY ./jenkins-in-docker-install.sh jenkins-in-docker-install.sh
#RUN chmod u+x jenkins-in-docker-install.sh && ./jenkins-in-docker-install.sh
FROM jenkins/jenkins:lts-jdk21

USER root
RUN apt-get update && apt-get install -y git curl sudo wget maven && apt-get clean

COPY jenkins-in-docker-install.sh /tmp/jenkins-in-docker-install.sh
RUN chmod +x /tmp/jenkins-in-docker-install.sh && /tmp/jenkins-in-docker-install.sh


COPY install-awscli.sh /tmp/install-awscli.sh
RUN chmod +x /tmp/install-awscli.sh && cd /tmp && ./install-awscli.sh \
    && rm -rf /tmp/aws /tmp/awscliv2.zip /tmp/install-awscli.sh



RUN curl -fsSLo /usr/local/bin/kubectl \
    https://dl.k8s.io/release/v1.28.15/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

USER jenkins
RUN jenkins-plugin-cli --plugins "docker-workflow"
