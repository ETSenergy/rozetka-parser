FROM python:3.12-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Создание всех необходимых директорий с правильными правами
RUN mkdir -p \
    /tmp/.X11-unix \
    /tmp/.chrome \
    /tmp/.config/chromium \
    /tmp/chrome-user-data \
    /tmp/chrome-data \
    /tmp/chrome-cache \
    /app/downloads && \
    chmod -R 1777 /tmp && \
    chmod -R 777 /app/downloads

# Переменные окружения
ENV CHROME_BIN=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    DISPLAY=:99 \
    HOME=/tmp \
    TMPDIR=/tmp \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Проверка установки Chrome
RUN chromium --version && chromedriver --version

EXPOSE 8000

CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT:-8000} --timeout-keep-alive 120"]
