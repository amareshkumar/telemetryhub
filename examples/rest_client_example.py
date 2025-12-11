#!/usr/bin/env python3
"""TelemetryHub REST API Client Example

Demonstrates how to interact with the TelemetryHub gateway's REST API.
Requires: requests library (pip install requests)

Usage:
    python rest_client_example.py

Make sure the gateway is running first:
    ../build/gateway/gateway_app --config ../docs/config.example.ini
"""

import requests
import time
import json
import sys

BASE_URL = "http://localhost:8080"

def get_status():
    """Get current gateway status and latest sample."""
    response = requests.get(f"{BASE_URL}/status")
    response.raise_for_status()
    return response.json()

def start_measurement():
    """Start telemetry measurement."""
    response = requests.post(f"{BASE_URL}/start")
    response.raise_for_status()
    return response.json()

def stop_measurement():
    """Stop telemetry measurement."""
    response = requests.post(f"{BASE_URL}/stop")
    response.raise_for_status()
    return response.json()

def print_sample(sample):
    """Pretty print a telemetry sample."""
    if sample:
        print(f"  Sample #{sample['sequence_id']:<6} "
              f"Value: {sample['value']:>8.3f} {sample['unit']:<12} "
              f"Time: {sample.get('timestamp', 'N/A')}")
    else:
        print("  (no sample available)")

def main():
    print("="*70)
    print("TelemetryHub REST API Client Example")
    print("="*70)
    
    try:
        # Get initial status
        print("\n[1] Getting initial status...")
        status = get_status()
        print(f"    Device state: {status['state']}")
        print_sample(status.get('sample'))
        
        # Start measurement
        print("\n[2] Starting measurement...")
        result = start_measurement()
        print(f"    Command result: {result.get('status', 'started')}")
        time.sleep(0.5)  # Give device time to transition
        
        # Verify state changed
        status = get_status()
        print(f"    New state: {status['state']}")
        
        # Poll for samples
        print("\n[3] Polling for 10 samples (press Ctrl+C to stop)...")
        for i in range(10):
            status = get_status()
            print_sample(status.get('sample'))
            time.sleep(0.5)
        
        # Stop measurement
        print("\n[4] Stopping measurement...")
        result = stop_measurement()
        print(f"    Command result: {result.get('status', 'stopped')}")
        time.sleep(0.2)
        
        # Final status
        status = get_status()
        print(f"    Final state: {status['state']}")
        print_sample(status.get('sample'))
        
        print("\n" + "="*70)
        print("✓ Example completed successfully!")
        print("="*70)
        
    except requests.exceptions.ConnectionError:
        print("\n" + "="*70)
        print("ERROR: Cannot connect to gateway at", BASE_URL)
        print("\nMake sure the gateway is running:")
        print("  Linux:   ./build/gateway/gateway_app")
        print("  Windows: .\\build_vs_ci\\gateway\\Release\\gateway_app.exe")
        print("="*70)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nInterrupted by user. Stopping measurement...")
        try:
            stop_measurement()
        except:
            pass
        sys.exit(0)
    except Exception as e:
        print(f"\nERROR: {type(e).__name__}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
