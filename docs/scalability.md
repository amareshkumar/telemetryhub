## Current Design (v1.0)
- Single device, single queue
- Max throughput: ~9M ops/sec
- Suitable for: 1-10 devices

## Future Scaling Options
1. **Multi-Gateway** (v2.0)
   - One GatewayCore per device
   - Aggregator service combines streams
   - Trade-off: More memory, independent failures

2. **Sharded Queue** (v3.0)
   - Hash device ID to queue
   - Lock-free queues per shard
   - Trade-off: Complexity, reordering

3. **Event-Driven** (v4.0)
   - io_uring or DPDK for device I/O
   - Zero-copy buffers
   - Trade-off: Platform-specific, harder to debug