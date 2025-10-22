FROM debian:bookworm

# Обновление системы и установка зависимостей
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    midori \
    novnc \
    websockify \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Создаём директорию для noVNC (на случай если пакет пустой)
RUN if [ ! -d /usr/share/novnc ]; then \
      git clone https://github.com/novnc/noVNC.git /usr/share/novnc && \
      ln -s /usr/share/novnc/utils/novnc_proxy /usr/bin/novnc_proxy; \
    fi

# Скрипт запуска
RUN echo '#!/bin/bash\n\
export DISPLAY=:0\n\
Xvfb :0 -screen 0 1280x800x24 &\n\
sleep 3\n\
fluxbox &\n\
sleep 3\n\
midori &\n\
x11vnc -display :0 -nopw -forever -shared -rfbport 5900 &\n\
/usr/bin/novnc_proxy --vnc localhost:5900 --listen 6080\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 5900 6080

ENTRYPOINT ["/entrypoint.sh"]
