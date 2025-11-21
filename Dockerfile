FROM ruby:3.1-slim AS base

# تنظیم غیرتعاملی
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# نصب وابستگی‌های اولیه
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
    autoconf \
    bison \
    patch \
    rustc \
    cargo \
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

# نصب bundler
RUN gem install bundler

# تنظیم دایرکتوری کاری
WORKDIR /opt/metasploit-framework

# کپی کل پروژه (برای دسترسی به تمام فایل‌های مورد نیاز gemspec)
COPY . /opt/metasploit-framework/

# نصب gems
RUN bundle config set --local without 'development test' && \
    bundle install --jobs=4 --retry=3

# تنظیم مالکیت فایل‌ها
RUN chown -R msfuser:msfuser /opt/metasploit-framework

# افزودن metasploit به PATH
ENV PATH="/opt/metasploit-framework:${PATH}"

# ایجاد دایرکتوری‌های مورد نیاز
RUN mkdir -p /home/msfuser/.msf4 && \
    chown -R msfuser:msfuser /home/msfuser

# اسکریپت شروع را اجرایی کن
RUN chmod +x /opt/metasploit-framework/start.sh

# پورت‌های مورد نیاز
EXPOSE 22 443 4444 8080

CMD ["/opt/metasploit-framework/start.sh"]