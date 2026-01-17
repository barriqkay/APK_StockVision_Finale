FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set Python environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files (excluding large files that might be mounted)
COPY *.py .
COPY *.md .

# Create predictions directory
RUN mkdir -p /app/predictions

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import requests; r=requests.get('http://localhost:8000/status'); exit(0 if r.status_code==200 else 1)"

# Run API
CMD ["uvicorn", "backend_api:app", "--host", "0.0.0.0", "--port", "8000"]
