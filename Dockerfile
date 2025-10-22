FROM alpine:edge

# Добавляем репозитории и пакеты
RUN echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update --upgrade add \
      bash \
      fluxbox \
      git \
      supervisor \
      xvfb \
      x11vnc \
      midori \
      && \
    # Устанавливаем noVNC и websockify
    git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git /root/noVNC/utils/websockify/.git && \
    # Чистим кэш
    apk del git && \
    rm -rf /var/cache/apk/* && \
    sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/launch.sh

# Настройки окружения
ENV HOME=/root \
    LANG=en_US.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    PORT=8080

# Копируем supervisord конфиг
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

# Стартуем supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
