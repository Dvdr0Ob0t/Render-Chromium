# Используем готовую лёгкую базу с noVNC/xvfb/x11vnc
FROM uphy/novnc-alpine-docker:latest

# Устанавливаем зависимости для запуска AppImage и небольшой окружение
RUN apk add --no-cache curl bash fuse udev

# Скачиваем Midori AppImage (x86_64). Версию можно поменять при необходимости.
# (если у тебя другой архитектуры — надо скачать соответствующий бинарник)
RUN curl -L -o /usr/local/bin/midori.AppImage \
    https://github.com/midori-browser/core/releases/download/v11.3/midori-v11.3-x86_64.AppImage && \
    chmod +x /usr/local/bin/midori.AppImage && \
    # Упакуем запускатор для простоты
    printf '#!/bin/sh\nexec /usr/local/bin/midori.AppImage \"$@\"' > /usr/local/bin/midori && \
    chmod +x /usr/local/bin/midori

# Окружение и порт (noVNC в uphy уже слушает 8080 по дефолту, но мы экспонируем для явности)
ENV DISPLAY=:0.0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    PORT=8080

EXPOSE 8080

# Копируем supervisord конфиг (см. ниже)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Запуск supervisord (в образе uphy доступен /usr/bin/supervisord)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
