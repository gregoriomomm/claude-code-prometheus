# Claude Code Monitoring with Prometheus and Grafana

This setup provides comprehensive monitoring for Claude Code usage without requiring an OpenTelemetry Collector in the middle. Claude Code directly exports metrics to Prometheus and events/logs to Loki, which are then visualized in Grafana.

## Architecture

```
Claude Code → Prometheus (metrics) + Loki (events/logs)
                            ↓
            Grafana (visualization & analysis)
```

## Components

- **Prometheus**: Metrics collection and storage
- **Loki**: Log aggregation and storage  
- **Grafana**: Visualization dashboards

## Claude Code Configuration

### Environment Variables

Set these environment variables to enable Claude Code telemetry:

**For Metrics Only:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=prometheus
```

**For Metrics + Logs (Requires Additional Setup):**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=prometheus
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

**Important Note on Logs**: 
- Claude Code exports logs via OTLP (port 4318)
- Loki listens on port 3100 but doesn't natively accept OTLP
- To get logs into Loki, you need an OpenTelemetry Collector as a bridge
- The current setup focuses on **metrics only** for simplicity
- Logs can be added later by including an OTLP collector service

### Default Configuration

Claude Code exports metrics using the following configuration:

- **Port**: 9464 (OpenTelemetry Prometheus exporter default)
- **Endpoint**: /metrics  
- **Protocol**: HTTP

## Prometheus Configuration

The Prometheus scrape configuration is optimized for Claude Code:

```yaml
scrape_configs:
  - job_name: 'claude-code'
    static_configs:
      - targets: ['host.docker.internal:9464']
    metrics_path: /metrics
    scrape_interval: 5s
```

## Metrics Collected

Claude Code exports the following standard metrics:

### Core Metrics
- **Session count**: Number of active Claude Code sessions
- **Lines of code modified**: Total lines changed/added
- **Pull requests created**: Number of PRs generated
- **Commits created**: Number of commits made
- **API request costs**: Token usage and associated costs
- **Active development time**: Time spent in active development

### Performance Metrics
- **Tool usage statistics**: Usage patterns for different tools
- **Response times**: API call latencies
- **Error rates**: Failed requests and operations
- **Token consumption**: Detailed token usage breakdown

## Quick Start

### 1. Start the monitoring stack

```bash
cd claude-code-prometheus
docker-compose up -d
```

### 2. Configure Claude Code

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=prometheus
```

### 3. Access services

- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

### 4. Verify metrics collection

Check that Claude Code metrics are being scraped:
```bash
curl http://localhost:9090/api/v1/targets
```

## Configuration Files

### Docker Compose (`docker-compose.yml`)
- Orchestrates Prometheus, Loki, and Grafana services
- Configures networking and persistent volumes
- Sets up service dependencies

### Prometheus Config (`prometheus.yml`) 
- Defines Claude Code as a scrape target
- Configures scrape intervals and timeouts
- Sets up service discovery

### Loki Config (`loki-config.yml`)
- Configures log ingestion and storage
- Sets retention policies
- Defines query limits

### Grafana Datasources (`grafana/provisioning/datasources/prometheus.yml`)
- Pre-configures Prometheus and Loki as data sources
- Sets connection parameters
- Configures query defaults

## Dashboard Development

### Suggested Dashboard Sections

1. **Overview**
   - Total sessions
   - Lines of code modified
   - Active development time
   - Cost summary

2. **Usage Analysis**  
   - Tool usage patterns
   - Session duration trends
   - Peak usage times
   - User activity patterns

3. **Performance Monitoring**
   - API response times
   - Error rates
   - Token consumption rates
   - Service health status

4. **Cost Management**
   - Token usage by session
   - Cost per feature/tool
   - Budget tracking
   - Usage efficiency metrics

5. **Event Logs** (via Loki)
   - Session start/stop events
   - Error logs
   - Tool execution logs
   - System events

## Security Considerations

- **No sensitive data**: Claude Code redacts user prompt content by default
- **Configurable privacy**: Telemetry is opt-in and configurable
- **Local deployment**: All monitoring data stays within your infrastructure
- **Access control**: Grafana admin credentials should be changed from defaults

## Troubleshooting

### Common Issues

1. **No metrics appearing**
   - Verify Claude Code environment variables are set
   - Check Claude Code is running and accessible on port 9464
   - Confirm Prometheus can reach host.docker.internal:9464

2. **Grafana can't connect to data sources**
   - Ensure all services are in the same Docker network
   - Check container names match datasource URLs
   - Verify services are fully started

3. **Loki not receiving logs**
   - Claude Code may need additional OTEL configuration for log export
   - Check Loki configuration and ensure it's accepting connections
   - Verify log format compatibility

### Validation Commands

```bash
# Check service health
docker-compose ps

# Check Claude Code metrics endpoint
curl http://localhost:9464/metrics

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Loki health
curl http://localhost:3100/ready
```

## Advanced Configuration

### Custom Metrics Collection

To extend metrics collection, you can:

1. Add additional Prometheus scrape targets
2. Configure custom recording rules
3. Set up alerting rules for threshold monitoring
4. Implement custom exporters for additional data sources

### Scaling Considerations

For high-volume usage:

1. Configure Prometheus retention and storage
2. Set up Loki sharding and retention policies  
3. Use external storage for persistent data
4. Implement monitoring for the monitoring stack itself

## References

- [Claude Code Monitoring Documentation](https://docs.anthropic.com/en/docs/claude-code/monitoring-usage)
- [Prometheus Configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [Grafana Loki Documentation](https://grafana.com/docs/loki/)
- [OpenTelemetry Prometheus Exporter](https://opentelemetry.io/docs/specs/otel/metrics/sdk_exporters/prometheus/)