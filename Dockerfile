FROM alpine:3.20

# Установка необходимых пакетов
RUN apk update && apk add --no-cache \
    xvfb \
    x11vnc \
    openbox \
    midori \
    novnc \
    websockify \
    && rm -rf /var/cache/apk/*

# Создание скрипта запуска
RUN echo '#!/bin/sh\n\
export DISPLAY=:0\n\
Xvfb :0 -screen 0 1280x800x24 &\n\
sleep 5\n\
openbox-session &\n\
sleep 5\n\
midori &\n\
x11vnc -display :0 -nopw -forever -shared &\n\
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080\n\
tail -f /dev/null' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Экспонируем порты: 5900 для VNC, 6080 для noVNC
EXPOSE 5900 6080

ENTRYPOINT ["/entrypoint.sh"]
