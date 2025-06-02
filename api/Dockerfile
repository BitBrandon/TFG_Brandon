FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    gcc \
    libsasl2-dev \
    python3-dev \
    libldap2-dev \
    libssl-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
