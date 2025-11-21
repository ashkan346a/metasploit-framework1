FROM metasploitframework/metasploit-framework:latest

# تنظیم محیط
ENV DEBIAN_FRONTEND=noninteractive

# نصب OpenSSH و ابزارها با apk (Alpine package manager)
RUN apk add --no-cache \
    openssh \
    openssh-server \
    sudo \
    screen \
    nano \
    vim \
    bash \
    procps

# تنظیم SSH
RUN mkdir -p /var/run/sshd /root/.ssh && \
    echo 'root:8181' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# ایجاد کاربر msfuser
RUN adduser -D -s /bin/bash msfuser && \
    echo 'msfuser:8181' | chpasswd && \
    addgroup msfuser wheel && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel

# ایجاد دایرکتوری‌ها
RUN mkdir -p /home/msfuser/.msf4 && \
    chown -R msfuser:msfuser /home/msfuser

# کپی فایل‌ها
COPY handler.rc /home/msfuser/handler.rc
COPY start.sh /start.sh
RUN chmod +x /start.sh

# پورت‌ها
EXPOSE 22 443 4444 8080

CMD ["/bin/bash", "/start.sh"]