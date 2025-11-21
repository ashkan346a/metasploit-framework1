FROM ubuntu:22.04

# تنظیم غیرتعاملی برای جلوگیری از گیر tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC  # یا Asia/Tehran اگر می‌خوای دقیق‌تر باشه

# نصب بسته‌ها بدون پرسش
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gnupg2 postgresql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# بقیه تنظیماتت برای Metasploit (اینجا handler.rc کپی کن و screen ران کن)
RUN useradd -m msfuser
USER msfuser
WORKDIR /home/msfuser

COPY handler.rc /home/msfuser/handler.rc

# ران دائمی handler با screen
CMD ["screen", "-dmS", "msf_handler", "msfconsole", "-r", "/home/msfuser/handler.rc"]