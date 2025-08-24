#!/bin/bash

# Claude Code Monitoring Setup Script
# This script sets up monitoring for Claude Code using Prometheus, Loki, and Grafana

set -e

echo "🚀 Setting up Claude Code Monitoring Stack..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
echo "📋 Checking dependencies..."

if ! command_exists docker; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command_exists docker-compose; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Dependencies check passed"

# Create directories if they don't exist
echo "📁 Setting up directories..."
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards

# Stop existing services if running
echo "🛑 Stopping existing services..."
docker-compose down --remove-orphans || true

# Start the monitoring stack
echo "🎯 Starting monitoring stack..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check Prometheus
if curl -s -f http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo "✅ Prometheus is healthy"
else
    echo "⚠️  Prometheus may not be ready yet"
fi

# Check Loki
if curl -s -f http://localhost:3100/ready > /dev/null 2>&1; then
    echo "✅ Loki is healthy"
else
    echo "⚠️  Loki may not be ready yet"
fi

# Check Grafana
if curl -s -f http://localhost:3001/api/health > /dev/null 2>&1; then
    echo "✅ Grafana is healthy"
else
    echo "⚠️  Grafana may not be ready yet"
fi

echo ""
echo "🎉 Claude Code Monitoring Stack is ready!"
echo ""
echo "📊 Access Points:"
echo "  • Grafana:    http://localhost:3001 (admin/admin)"
echo "  • Prometheus: http://localhost:9090"
echo "  • Loki:       http://localhost:3100"
echo ""
echo "🔧 Claude Code Configuration:"
echo "  Set these environment variables in your shell:"
echo "  export CLAUDE_CODE_ENABLE_TELEMETRY=1"
echo "  export OTEL_METRICS_EXPORTER=prometheus"
echo ""
echo "💡 Note: This setup focuses on metrics only."
echo "   Logs require additional OTLP collector setup (see README.md)"
echo ""
echo "📈 Next Steps:"
echo "  1. Configure Claude Code with the environment variables above"
echo "  2. Start using Claude Code to generate metrics"
echo "  3. Access Grafana to create dashboards and view metrics"
echo "  4. Check README.md for dashboard suggestions and troubleshooting"
echo ""
echo "🔍 Verify Claude Code metrics:"
echo "  curl http://localhost:9464/metrics"
echo ""