FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
  gcc \
  default-libmysqlclient-dev \
  pkg-config \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Install uv using pip
RUN pip install --no-cache-dir uv

# Copy dependency files
COPY pyproject.toml .
COPY requirements.txt .

# Install Python dependencies using uv
RUN uv pip install --system -r requirements.txt

# Install debugpy for debugging
RUN uv pip install --system debugpy

# Copy application code
COPY app/ /app/

# Expose ports
EXPOSE 8000
EXPOSE 5678

# Run the application with debug support
CMD ["sh", "-c", "if [ \"$DEBUG\" = \"true\" ]; then python3 -m debugpy --listen 0.0.0.0:5678 -m uvicorn main:app --reload --host 0.0.0.0 --port 8000; else uvicorn main:app --host 0.0.0.0 --port 8000; fi"]
