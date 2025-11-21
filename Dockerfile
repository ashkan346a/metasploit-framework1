FROM ubuntu:22.04

# تنظیم محیط
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# نصب dependencies و Metasploit
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg2 \
    git \
    openssh-server \
    sudo \
    screen \
    nano \
    vim \
    postgresql \
    ca-certificates \
    && curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall && \
    chmod 755 /tmp/msfinstall && \
    /tmp/msfinstall && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# تنظیم SSH
RUN mkdir -p /var/run/sshd /root/.ssh && \
    echo 'root:8181' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 443/' /etc/ssh/sshd_config

# ایجاد کاربر
RUN useradd -m -s /bin/bash msfuser && \
    echo 'msfuser:8181' | chpasswd && \
    usermod -aG sudo msfuser && \
    echo "msfuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ایجاد دایرکتوری‌ها
RUN mkdir -p /home/msfuser/.msf4 && \
    chown -R msfuser:msfuser /home/msfuser

# کپی فایل‌ها
COPY handler.rc /home/msfuser/handler.rc
COPY start-simple.sh /start.sh
RUN chmod +x /start.sh

# پورت‌ها
EXPOSE 22 443 4444 8080

CMD ["/start.sh"]