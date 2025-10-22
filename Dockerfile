FROM alpine:edge

# Устанавливаем базу с X11, VNC, supervisor, и легкий WM (fluxbox)
RUN echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update --upgrade add \
      bash \
      fluxbox \
      supervisor \
      xvfb \
      x11vnc \
      git \
      curl \
      fuse \
      udev && \
    # Ставим noVNC и websockify вручную
    git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git /root/noVNC/utils/websockify/.git && \
    apk del git && \
    rm -rf /var/cache/apk/* && \
    sed -i 's/ps -p/ps -o pid | grep/' /root/noVNC/utils/launch.sh

# Скачиваем Midori AppImage (легкий браузер)
RUN curl -L -o /usr/local/bin/midori.AppImage \
    https://github.com/midori-browser/core/releases/download/v11.3/midori-v11.3-x86_64.AppImage && \
    chmod +x /usr/local/bin/midori.AppImage && \
    printf '#!/bin/sh\nexec /usr/local/bin/midori.AppImage "$@"' > /usr/local/bin/midori && \
    chmod +x /usr/local/bin/midori

# Окружение
ENV HOME=/root \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    PORT=8080

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
