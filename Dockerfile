FROM kalilinux/kali-rolling

LABEL maintainer="offensivehacking@gmail.com"

ENV DEBIAN_FRONTEND interactive
ENV TERM xterm-256color

# Install Kali Full
RUN apt-get update -y && apt-get clean all
RUN apt-get install -y kali-linux-full

# Install Additional Core Programs
RUN apt-get install -y git colordiff colortail unzip vim tmux xterm zsh curl telnet strace ltrace tmate less build-essential wget python3-setuptools python3-pip tor proxychains proxychains4 zstd net-tools bash-completion iputils-tracepath nodejs npm yarnpkg gobuster websploit iputils-ping software-properties-common openvas docker docker.io docker-compose docker-registry burpsuite xrdp openssh openssl default-jdk exploitdb man-db dirb nikto wpscan uniscan postgresql

# Start Postgresql For Metasploit
RUN service postgresql start && msfdb init && service postgresql stop

VOLUME /root /var/lib/postgresql
# default LPORT for reverse shell
EXPOSE 4444


Install GUI
RUN apt install -y kali-linux-xfce
RUN apt install -y xfce4
RUN apt install -y xfce4-goodies

# Install Required Pip Modules
RUN pip install scapy
RUN pip install soap
RUN pip install SimpleHTTPServer
RUN pip install http.server
RUN pip install twisted
RUN pip install pyOpenSSL
RUN pip install service_identity
RUN pip install pyftpdlib
RUN pip3 install pwntools

# Set Python Virtual Env
# virtualenv config
RUN pip install virtualenvwrapper && \
    echo 'export WORKON_HOME=$HOME/.virtualenvs' >> /etc/profile && \
    echo 'export PROJECT_HOME=$HOME/projects' >> /etc/profile && mkdir /root/projects && \
    echo 'export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh' >> /etc/profile && \
    bash /usr/local/bin/virtualenvwrapper.sh && \
    echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /etc/profile

# Tor refresh every 5 requests
RUN echo MaxCircuitDirtiness 10 >> /etc/tor/torrc && \
    update-rc.d tor enable

# Use random proxy chains / round_robin_chain for pc4
RUN sed -i 's/^strict_chain/#strict_chain/g;s/^#random_chain/random_chain/g' /etc/proxychains.conf && \
    sed -i 's/^strict_chain/#strict_chain/g;s/^round_robin_chain/round_robin_chain/g' /etc/proxychains4.conf

# Add Docker Normal User
RUN groupadd docker
RUN gpasswd -a ${USER} docker
RUN service docker restart

# Unzip Rockyou
WORKDIR /usr/share/wordlists
RUN gunzip rockyou.txt.gz

# Clone SecList
RUN git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

WORKDIR /root

# Setup ZSH
RUN apt install zsh zsh-syntax-highlighting zsh-autosuggestions
ADD ./.zshrc /root/.zshrc
RUN ln -s /data/.zsh_history /root/.zsh_history
RUN ln -s /data/.z /root/.z

#Start The Services
RUN /etc/init.d/docker start
RUN /etc/init.d/ssh start
RUN /etc/init.d/xrdp start

# Update DB and clean'up!
RUN updatedb && \
    apt-get autoremove -y && \
    apt-get clean 

# Welcome message
RUN echo "echo 'Welcome To Kali Docker!\n\n- If you need proxychains over Tor just activate tor service with:\n$ service tor start\n'" >> /etc/profile

CMD ["/bin/bash", "--init-file", "/etc/profile"]
