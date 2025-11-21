FROM metasploitframework/metasploit-framework:latest

# تنظیم غیرتعاملی
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# نصب SSH و ابزارهای مورد نیاز
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    screen \
    nano \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# تنظیم SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:8181' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo 'Port 22' >> /etc/ssh/sshd_config

# ایجاد کاربر msfuser
RUN useradd -m -s /bin/bash msfuser && \
    echo 'msfuser:8181' | chpasswd && \
    usermod -aG sudo msfuser && \
    echo "msfuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ایجاد دایرکتوری‌های مورد نیاز
RUN mkdir -p /home/msfuser/.msf4 && \
    chown -R msfuser:msfuser /home/msfuser

# کپی فایل‌های handler
COPY handler.rc /home/msfuser/handler.rc
COPY start.sh /start.sh
RUN chmod +x /start.sh

# پورت‌های مورد نیاز
EXPOSE 22 443 4444 8080

CMD ["/start.sh"]