# Debian bookworm с минимальными лишними зависимостями
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=":1"
ENV USER=root

# Основные пакеты
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-common \
    fluxbox xterm x11-xserver-utils \
    firefox-esr \
    python3 python3-pip python3-websockify \
    git wget ca-certificates \
    net-tools procps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Клонируем noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc \
 && git clone --depth 1 https://github.com/novnc/websockify.git /usr/share/novnc/utils/websockify

# Создаём директорию VNC
RUN mkdir -p /root/.vnc

# Создаём xstartup с правильными правами
RUN cat > /root/.vnc/xstartup <<'XSTART' && chmod +x /root/.vnc/xstartup
#!/bin/sh
export XKL_XMODMAP_DISABLE=1
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
export XDG_SESSION_TYPE=x11
export GNOME_SHELL_SESSION_MODE=classic
export XDG_MENU_PREFIX=gnome-
export XDG_CURRENT_DESKTOP=XFCE
fluxbox &
sleep 1
firefox-esr --no-remote "about:blank" &
XSTART

# Устанавливаем пароль VNC
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd \
 && chmod 600 /root/.vnc/passwd

# Создаём скрипт запуска
RUN cat > /entrypoint.sh <<'ENTRY' && chmod +x /entrypoint.sh
#!/bin/bash
set -e

# Убиваем существующие VNC серверы
vncserver -kill :1 || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# Запускаем VNC сервер
vncserver :1 -geometry 1280x800 -depth 24 -localhost no

# Запускаем noVNC
if [ -f /usr/share/novnc/utils/novnc_proxy ]; then
    /usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &
else
    python3 /usr/share/novnc/utils/websockify/run --web /usr/share/novnc 6080 localhost:5901 &
fi

echo "VNC доступен на порту 5901"
echo "noVNC доступен на порту 6080"

# Держим контейнер живым
tail -f /dev/null
ENTRY

EXPOSE 5901 6080

ENTRYPOINT ["/entrypoint.sh"]
