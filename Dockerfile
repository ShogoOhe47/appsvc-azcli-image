FROM debian:stable-20230411-slim

# ssh
ENV SSH_PASSWD "root:Docker!"
RUN apt update \
        && apt install -y --no-install-recommends dialog \
        && apt update \
	&& apt install -y --no-install-recommends openssh-server apache2 tmux \
	&& apt install -y ca-certificates curl apt-transport-https lsb-release gnupg \
    && apt clean \
	&& echo "$SSH_PASSWD" | chpasswd

# install Azure CLI
# https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli-linux?utm_source=pocket_saves&pivots=apt
RUN  mkdir -p /etc/apt/keyrings \
     && curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor | \
      tee /etc/apt/keyrings/microsoft.gpg > /dev/null \
     && chmod go+r /etc/apt/keyrings/microsoft.gpg

RUN AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
     tee /etc/apt/sources.list.d/azure-cli.list

RUN apt update \
    && apt install -y azure-cli \
    && apt clean

# COPY sshd_config /etc/ssh/
RUN echo "Port 2222" >> /etc/ssh/sshd_config \
 && echo "PermitRootLogin 	yes" >> /etc/ssh/sshd_config \
 && echo "Ciphers aes128-cbc,3des-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config \
 && echo "MACs hmac-sha1,hmac-sha1-96" >> /etc/ssh/sshd_config

# COPY FILES
COPY hostingstart.html /var/www/html/index.html
COPY init.sh /usr/local/bin/

RUN chmod 644 /var/www/html/index.html \
 && chmod u+x /usr/local/bin/init.sh
EXPOSE 80 2222

# change home dir -> App Service FileSystem
RUN sed -i "s#root:x:0:0:root:/root:#root:x:0:0:root:/home/root:#" /etc/passwd

#CMD ["python", "/code/manage.py", "runserver", "0.0.0.0:8000"]
ENTRYPOINT ["init.sh"]