FROM alpine:3.20

# Обновление и установка зависимостей
RUN apk add --no-cache \
    chromium \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    websockify \
    bash \
    curl \
    supervisor

# Создаём рабочие каталоги
RUN mkdir -p /root/.config /var/log/supervisor

# Настройки окружения
ENV DISPLAY=:0 \
    SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    PORT=10000

# Конфиг supervisord для автозапуска
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 10000

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
