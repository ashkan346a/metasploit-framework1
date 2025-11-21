FROM ubuntu:22.04

# تنظیم غیرتعاملی
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# نصب وابستگی‌های اولیه و Ruby
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tzdata \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    git \
    build-essential \
    libpq-dev \
    postgresql-client \
    openssh-server \
    sudo \
    screen \
    nano \
    vim \
    ruby \
    ruby-dev \
    libssl-dev \
    zlib1g-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libgdbm-compat-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# تنظیم SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:8181' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'Port 22' >> /etc/ssh/sshd_config

# ایجاد کاربر msfuser
RUN useradd -m -s /bin/bash msfuser && \
    echo 'msfuser:8181' | chpasswd && \
    usermod -aG sudo msfuser && \
    echo "msfuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# کپی کل پروژه Metasploit
WORKDIR /opt/metasploit-framework
COPY --chown=msfuser:msfuser . /opt/metasploit-framework/

# نصب bundler و وابستگی‌های Ruby
RUN gem install bundler -v '~> 2.0' && \
    bundle install --jobs=4 --retry=3

# افزودن metasploit به PATH
ENV PATH="/opt/metasploit-framework:${PATH}"

# ایجاد دایرکتوری‌های مورد نیاز
RUN mkdir -p /home/msfuser/.msf4 && \
    chown -R msfuser:msfuser /home/msfuser

# پورت‌های مورد نیاز
EXPOSE 22 443 4444 8080

# کپی اسکریپت شروع
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]