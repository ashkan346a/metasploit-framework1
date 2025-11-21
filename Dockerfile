FROM ubuntu:22.04

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
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# نصب Ruby 3.1 از PPA
RUN add-apt-repository -y ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby3.1 ruby3.1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# تنظیم Ruby 3.1 به عنوان نسخه پیش‌فرض
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby3.1 1 && \
    update-alternatives --install /usr/bin/gem gem /usr/bin/gem3.1 1 && \
    ruby --version

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

# کپی Gemfile ها برای cache بهتر
COPY Gemfile Gemfile.lock metasploit-framework.gemspec ./
COPY lib/metasploit/framework/version.rb ./lib/metasploit/framework/version.rb

# نصب gems
RUN bundle config set --local without 'development test' && \
    bundle install --jobs=4 --retry=3

# کپی بقیه پروژه
COPY . /opt/metasploit-framework/

# تنظیم مالکیت فایل‌ها
RUN chown -R msfuser:msfuser /opt/metasploit-framework

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