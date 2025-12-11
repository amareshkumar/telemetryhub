# TelemetryHub Examples

This directory contains example code showing how to integrate with TelemetryHub.

## Files

- `basic_usage.cpp` - Simple C++ client connecting to gateway
- `rest_client_example.py` - Python REST API client
- `custom_config.ini` - Example configuration file

## Running Examples

### Python REST Client
```bash
# Start gateway first
../build/gateway/gateway_app

# Run Python client
python rest_client_example.py