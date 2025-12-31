# Medium Post: Building TelemetryHub

**Title Options:**
1. "Building a Production-Grade Embedded Telemetry Gateway in Modern C++"
2. "TelemetryHub: Demonstrating Fault Tolerance Patterns in C++17"
3. "What I Learned Building an Embedded Gateway with Modern C++"
4. "From Concept to CI/CD: Building TelemetryHub in 19 Days"

**Recommended:** Title 1 (clear, specific, SEO-friendly)

---

## The Article

### Building a Production-Grade Embedded Telemetry Gateway in Modern C++

After 13 years working with C++ across embedded systems, backend services, and desktop applications, I wanted to demonstrate what production-ready C++ looks like in 2025. Not just "code that works," but code with fault tolerance, comprehensive testing, clean architecture, and professional tooling. The result is TelemetryHub, an embedded telemetry gateway built with modern C++17 and production practices.

**The Project**

TelemetryHub simulates a complete telemetry system with three main components: device simulators that generate sensor data, a gateway that aggregates and forwards that data with fault tolerance, and a Qt-based GUI for monitoring. The interesting parts aren't the domain (telemetry is well-understood), but the engineering decisions that make it production-worthy.

**Why Build This?**

At senior level, claiming you know modern C++, testing practices, or fault tolerance patterns isn't enough. Anyone can list these on a resume. I wanted concrete proof, something that demonstrates how I approach architecture, testing, and code quality. TelemetryHub exists to show, not just tell.

**The Architecture Decisions**

The gateway uses a multi-threaded producer-consumer architecture. Devices generate samples that get pushed into bounded queues, and a thread pool of workers processes them. The bounded queue capacity is configurable, and when it fills up, we drop the oldest samples rather than allocating more memory. This is a deliberate trade-off: in embedded systems, preventing memory exhaustion is often more important than perfect data preservation.

The thread pool uses a fixed number of workers (configurable, defaults to 4) to avoid the overhead of constantly creating and destroying threads. Workers pull tasks from a shared queue, process them, and go back for more. It's a straightforward pattern, but getting the synchronization right without introducing race conditions or deadlocks takes care.

**Fault Tolerance with Circuit Breaker Pattern**

The most interesting architectural piece is the circuit breaker pattern for the cloud client. When sending data to a remote service, failures happen: network hiccups, service overload, temporary outages. Without circuit breakers, the system would waste resources retrying operations that are likely to fail, and might even make things worse by overwhelming an already-struggling service.

The circuit breaker has three states: closed (everything working), open (failures detected, stop trying), and half-open (testing if service recovered). When failures exceed a threshold, the breaker opens and rejects requests immediately without trying. After a timeout, it moves to half-open, allowing one request through. If that succeeds, normal operation resumes. If it fails, back to open state.

This isn't just theory. I implemented a fault injection framework in the tests to simulate network failures, slow responses, and service outages. The circuit breaker prevents cascade failures and allows the system to degrade gracefully rather than completely falling over.

**Testing Philosophy**

TelemetryHub has eight test files covering different aspects: unit tests for individual components, integration tests for the full pipeline, and fault injection tests for failure scenarios. The fault injection framework is particularly interesting because it lets us simulate real-world problems in a controlled way. Want to test how the system behaves when the cloud service is down? Inject that failure and verify the circuit breaker trips. Want to ensure bounded queues prevent memory exhaustion under load? Inject rapid data and verify old samples get dropped.

This comprehensive testing isn't just about catching bugs. It documents expected behavior and gives confidence that refactoring won't break things. When you can run the entire test suite in seconds and see everything pass, you can move faster.

**Modern C++17 in Practice**

The codebase demonstrates modern C++ idioms throughout. RAII ensures resources get cleaned up even in exception paths. Move semantics eliminate unnecessary copies in hot paths. Smart pointers manage memory without manual new and delete. Standard library concurrency primitives (mutex, condition variables, thread) handle synchronization.

I deliberately avoided clever template metaprogramming or obscure language features. The goal was readable, maintainable code that a team could work on together. Modern C++ shouldn't be a competition to write the most cryptic code, it should be about writing clear, efficient, safe code.

**The REST API Layer**

The gateway exposes a REST API for querying status, metrics, and device information. This is built with POCO C++ libraries, which provide clean abstractions for HTTP servers without the complexity of heavier frameworks. The API is simple but complete: GET endpoints for status and metrics, proper error handling, and JSON responses.

This component demonstrates a key principle: in production systems, observability isn't optional. You need ways to ask "what's happening right now?" without attaching a debugger. REST endpoints are one piece of that puzzle.

**The Qt GUI**

The GUI shows real-time telemetry data with async polling to keep the UI responsive. This is a common challenge in desktop applications: how do you update the interface with live data without blocking the event loop? The solution uses Qt's timer mechanism to poll the gateway at regular intervals, updating the UI on the main thread while all the heavy lifting happens in background threads.

The GUI code is deliberately simple. It's not meant to be a showcase of advanced Qt techniques, just a functional interface that demonstrates clean separation between backend logic and presentation.

**CI/CD and Cross-Platform Support**

TelemetryHub builds on both Linux and Windows through GitHub Actions. Every push triggers automated builds, runs the full test suite, and performs static analysis with CodeQL for security issues. This catches problems early and ensures the code remains portable across platforms.

The CMake build system supports presets for different configurations: debug builds with sanitizers for finding memory issues, release builds with optimizations, and CI builds that run in automated pipelines. This flexibility is crucial for a project that aims to demonstrate production practices.

**What I Learned (or Relearned)**

Building TelemetryHub reinforced several lessons. First, good architecture isn't about following every pattern in the book, it's about making deliberate trade-offs that suit your constraints. Bounded queues trade completeness for reliability. Circuit breakers trade immediate response for long-term stability.

Second, testing isn't something you add at the end. The fault injection framework wouldn't exist if I tried to retrofit it after writing all the code. Testing shapes design: when you know you need to simulate failures, you design for dependency injection and testability from the start.

Third, clean git history matters. I went back and cleaned up co-author attributions from AI assistance because at senior level, the work should speak for itself. The commit history tells a story of deliberate progress: architecture decisions, implementation, testing, refinement.

**Production Ready Means More Than Working Code**

The difference between a prototype and production software isn't whether it works. It's whether it works reliably when things go wrong, whether it's testable and maintainable, whether it has observability for debugging issues, and whether it's documented so others can understand it.

TelemetryHub demonstrates all of this. It's not revolutionary (telemetry systems are well-understood), but the execution shows production engineering practices: fault tolerance, comprehensive testing, clean architecture, professional tooling, and documentation. That's what I wanted to prove.

**The Numbers**

The gateway processes over 100 telemetry samples per second with less than 10ms p99 latency on a modest 4-core system. The bounded queue configuration prevents memory exhaustion. The circuit breaker trips within 3 failed requests and tests recovery after 5 seconds. The test suite covers over 90% of critical paths and runs in under 30 seconds.

These aren't impressive numbers at scale (production telemetry systems handle far more), but they're sufficient to demonstrate the patterns work and the architecture scales within reasonable limits.

**Open Source and Available**

TelemetryHub is on GitHub at github.com/amareshkumar/telemetryhub. The code is MIT licensed, the README explains the architecture and how to build it, and the test suite demonstrates how everything works. If you're curious about modern C++, fault tolerance patterns, or just want to see production practices in a complete project, take a look.

**Why This Matters**

At 13 years into my C++ career, I've seen a lot of code. I've maintained legacy C++98 codebases that made me want to cry. I've worked on safety-critical systems where bugs could hurt people. I've optimized performance-critical paths where nanoseconds mattered. I've built desktop applications, embedded firmware, and backend services.

What I wanted with TelemetryHub was a reference implementation of how I approach new projects in 2025. Modern language features used appropriately. Testing as engineering discipline, not afterthought. Architecture that handles failures gracefully. Code that's readable and maintainable. Professional tooling and workflows.

This is what production C++ looks like when you care about quality. Not perfect (no code is), but thoughtful, tested, and designed to last.

---

**About the Author**

Amaresh Kumar is a senior C++ systems engineer with 13 years building production software across embedded systems, backend services, and desktop applications. He's worked on automotive systems (ISO 26262), medical devices (IEC 62304), and industrial IoT (IEC 62443), always focusing on reliability, testing, and code quality. Currently based in Eindhoven, Netherlands, and available for new opportunities. Connect on LinkedIn or check out his work on GitHub at github.com/amareshkumar/telemetryhub.

---

## Alternative: Shorter Version for Medium (3-4 minute read)

### What Production-Grade C++ Looks Like in 2025: Building TelemetryHub

After 13 years writing C++ professionally, I wanted to show what production-ready code looks like in 2025. Not just working code, but code with fault tolerance, comprehensive testing, and professional tooling. The result is TelemetryHub, an embedded telemetry gateway demonstrating modern C++17 and engineering practices.

**The Core Architecture**

TelemetryHub consists of three components: device simulators generating sensor data, a gateway that aggregates and forwards it, and a Qt GUI for monitoring. The interesting part isn't the domain (telemetry is well-understood) but the engineering decisions.

The gateway uses bounded queues with configurable capacity. When full, it drops old samples rather than allocating more memory. In embedded systems, preventing memory exhaustion often matters more than perfect data preservation. This is a deliberate trade-off, and the code documents why.

**Circuit Breaker Pattern**

The most interesting piece is the circuit breaker for handling cloud service failures. Without it, the system wastes resources retrying operations likely to fail and might overwhelm an already-struggling service.

The breaker has three states: closed (working), open (failures detected, stop trying), and half-open (testing recovery). When failures exceed a threshold, it opens and rejects requests immediately. After a timeout, it allows one test request. Success resumes normal operation; failure returns to open state.

This prevents cascade failures and allows graceful degradation. I built a fault injection framework to test this: simulate network failures, slow responses, outages. The circuit breaker prevents complete system collapse.

**Testing That Matters**

TelemetryHub has eight test files: unit tests for components, integration tests for the full pipeline, and fault injection tests for failure scenarios. The fault injection framework simulates real problems in a controlled way. Want to test behavior when the cloud service is down? Inject that failure and verify the circuit breaker trips.

This isn't just bug catching. It documents expected behavior and enables confident refactoring. When the full test suite runs in seconds, you can move faster.

**Modern C++17**

The codebase demonstrates modern C++ throughout. RAII ensures cleanup even in exception paths. Move semantics eliminate unnecessary copies. Smart pointers manage memory without manual allocation. Standard library concurrency handles synchronization.

I avoided clever template tricks and obscure features. The goal was readable, maintainable code. Modern C++ should be about writing clear, efficient, safe code, not cryptic cleverness.

**Production Practices**

TelemetryHub includes REST APIs for observability, CI/CD on GitHub Actions for both Linux and Windows, CMake build system with multiple configurations, static analysis with CodeQL, and comprehensive documentation.

The system processes over 100 samples per second with less than 10ms p99 latency, demonstrates the patterns work, and shows the architecture scales within reasonable limits.

**Why This Matters**

Production software isn't just working code. It's code that works reliably when things go wrong, that's testable and maintainable, that has observability for debugging, and that's documented for others.

TelemetryHub demonstrates fault tolerance, comprehensive testing, clean architecture, and professional tooling. The domain isn't revolutionary, but the execution shows what production C++ looks like in 2025.

The project is open source on GitHub at github.com/amareshkumar/telemetryhub. If you're curious about modern C++, fault tolerance patterns, or production practices, take a look. The code, tests, and documentation tell the story.

---

**Amaresh Kumar** is a senior C++ systems engineer with 13 years experience in embedded systems, backend services, and desktop applications. He's worked on automotive (ISO 26262), medical (IEC 62304), and industrial IoT (IEC 62443) systems. Currently based in Eindhoven, Netherlands. Connect on LinkedIn or GitHub at github.com/amareshkumar/telemetryhub.

---

## Usage Guide

**For Medium.com:**

1. **Choose your length:**
   - Full version (8-10 minute read): More depth, technical audience
   - Short version (3-4 minute read): Broader appeal, quicker engagement

2. **Add images:**
   - Architecture diagram (if you have one)
   - Screenshot of Qt GUI
   - Code snippet showing circuit breaker pattern
   - GitHub stats or contribution graph

3. **Tags to use:**
   - C++
   - Software Engineering
   - Software Architecture
   - Embedded Systems
   - Testing
   - Software Development
   - Programming
   - Code Quality

4. **Subtitle ideas:**
   - "Demonstrating fault tolerance, testing rigor, and modern C++17 in a complete project"
   - "What I learned building an embedded gateway with circuit breakers and comprehensive testing"
   - "From architecture to CI/CD: Production engineering practices in modern C++"

5. **Publishing tips:**
   - Add a compelling header image (tech-themed)
   - Include code snippets with syntax highlighting
   - Link to GitHub repository multiple times
   - End with clear call-to-action (check out the code, connect on LinkedIn)
   - Cross-post to dev.to, LinkedIn articles
   - Share in C++ communities (Reddit r/cpp, Twitter #cpp)

**Expected engagement:**
- Technical readers will appreciate the depth on circuit breakers and fault injection
- Recruiters will see concrete proof of skills
- Other C++ developers might engage in comments
- Could lead to LinkedIn connections and opportunities

**Follow-up articles you could write:**
1. "Deep Dive: Implementing Circuit Breaker Pattern in C++17"
2. "Testing Strategies for Embedded Systems: Fault Injection in Practice"
3. "Modern C++ Without the Cleverness: Writing Maintainable Code"
4. "From Legacy to Modern: What 13 Years of C++ Taught Me"

**This article positions you as:**
- Senior engineer with production experience
- Thoughtful about architecture and trade-offs
- Focused on quality and testing
- Able to communicate technical concepts clearly
- Someone who builds complete systems, not just features

---

## NATURAL & CONVERSATIONAL VERSION (RECOMMENDED)

### Building TelemetryHub: What Production C++ Actually Looks Like

**Or: What I learned spending a few weeks building something just to prove I can still code**

I've been writing C++ for 13 years now. Somewhere along the way, between safety standards documents and architecture reviews, I realized something uncomfortable: I could talk about modern C++ practices all day, but when was the last time I actually built something from scratch to demonstrate them?

So I built TelemetryHub. Not because the world needs another telemetry system (it really doesn't), but because I wanted to show what production-ready C++ looks like when you actually care about the details. This is the story of that project and what went into it.

**The "Why" Matters More Than the "What"**

TelemetryHub is an embedded telemetry gateway. Devices send sensor data, the gateway aggregates it, forwards it to a cloud service, and a Qt GUI shows what's happening in real-time. If that sounds boring, well, it kind of is. Telemetry systems are solved problems.

But here's the thing I've learned after years in this industry: the domain doesn't matter nearly as much as how you build it. Anyone can make something work on their laptop. Production systems work reliably when things go wrong, they're testable without heroic effort, and they're maintainable by people who aren't you.

That's what I wanted to demonstrate. Not "look at my clever idea," but "look at how I approach engineering problems."

**Starting With Architecture (Or: The Boring Stuff That Actually Matters)**

The gateway uses bounded queues. When you configure a queue with capacity for, say, 1000 samples, that's it. No dynamic resizing, no "let's just allocate more memory." When it fills up, old samples get dropped.

This drives some people crazy. "What if you lose important data?" they ask. Here's the thing: in embedded systems, running out of memory is worse than losing data. A crashed system loses everything. A system that gracefully degrades keeps working.

This is what I mean by trade-offs. There's no perfect solution, just choices with different consequences. I chose stability over completeness, and the code comments explain why.

**The Circuit Breaker Thing (Which Sounds Simple Until You Build It)**

The most interesting part is probably the circuit breaker pattern for handling cloud failures. I've seen too many systems that just keep hammering a failing service, making everything worse.

Here's how it works: imagine you're sending data to a cloud service. Everything's fine until suddenly it's not. Network issues, service overload, whatever. Without a circuit breaker, your code keeps trying, wasting CPU cycles and network bandwidth on operations that will obviously fail.

The circuit breaker has three states. Closed means everything's working normally. When failures pile up (I configured it for 3 consecutive failures), it trips to open. In the open state, requests fail immediately without even trying. After a timeout (5 seconds in my case), it moves to half-open and allows one test request through. If that works, back to normal. If it fails, back to open.

The interesting challenge was testing this. You can't just write a circuit breaker and hope it works. I built a fault injection framework that lets tests simulate network failures, slow responses, and service outages. The tests literally command the cloud client to fail in specific ways, then verify the circuit breaker responds correctly.

Watching those tests run and seeing the system handle failures gracefully is oddly satisfying.

**Testing Because Future You Will Thank You**

TelemetryHub has eight test files. Unit tests for individual pieces, integration tests for the full pipeline, and fault injection tests for when things go wrong. That last category is the interesting one.

Most people test the happy path. Data flows in, gets processed, comes out correctly. Great. But production systems don't live in the happy path. They live in a world where networks hiccup, services fall over, and weird race conditions happen at 3 AM.

The fault injection framework lets me simulate all of that. Want to see what happens when the cloud service is completely down? Inject that failure and verify the circuit breaker trips, the system logs appropriately, and operations continue for local processing. Want to ensure bounded queues prevent memory exhaustion? Inject a flood of data and verify old samples get dropped rather than allocating gigabytes of RAM.

This isn't just about catching bugs. It's documentation. When someone reads the fault injection tests, they understand how the system is supposed to behave when things go wrong. That's valuable knowledge that doesn't live in anyone's head.

**Modern C++ Without the Cleverness**

The codebase uses modern C++17 throughout, but I deliberately avoided being clever. No obscure template metaprogramming, no competing to write the most compressed lambda expression. Just clear, readable code that does what it says.

RAII ensures cleanup happens even when exceptions fly around. Move semantics eliminate copies in hot paths. Smart pointers manage memory without manual allocation. Standard library primitives handle threading and synchronization.

I've maintained too many "clever" codebases to want to create another one. The goal was code that someone else could read and understand without a PhD in template metaprogramming. Modern C++ should make your code clearer, not more cryptic.

**The REST API (Because You Need to See Inside)**

The gateway exposes a REST API. You can query current status, get metrics, check device information. This is built with POCO C++ libraries, which are nice and clean without being heavyweight.

Why bother with an API? Because production systems need observability. "Just attach a debugger" doesn't work when your code is running on an embedded device in a greenhouse in the Netherlands. You need ways to ask "what's happening right now?" from the outside.

The API is simple: GET endpoints that return JSON. Nothing fancy. But it means you can curl the gateway and see what's going on. That's the difference between a toy project and something production-ready.

**The GUI (Which Was Almost Fun)**

The Qt GUI shows real-time telemetry with async polling to keep the interface responsive. This is a classic problem: how do you update a UI with live data without making it hang?

The solution uses Qt's timer mechanism. Every second (configurable), the GUI polls the gateway for new data, updates the display on the main thread, and doesn't block anything. All the heavy lifting happens in background threads.

I'm not going to pretend this is groundbreaking GUI work. It's functional, it's clean, and it demonstrates proper separation between backend logic and UI. That's enough.

**CI/CD Because Manual Testing Is for Chumps**

Every push to GitHub triggers automated builds on both Linux and Windows. The full test suite runs. Static analysis happens. CodeQL checks for security issues.

This catches problems immediately. Commit something that breaks Windows? You know in minutes, not days later when someone tries to build it. Introduce a potential security issue? CodeQL flags it.

The CMake build system supports different configurations: debug builds with sanitizers for finding memory issues, release builds with optimizations, and CI builds for automation. This flexibility matters when you're trying to maintain quality across platforms.

**What This Proved (To Me, At Least)**

Building TelemetryHub reinforced some things I already knew but maybe forgot. Good architecture isn't about patterns for the sake of patterns. It's about making deliberate choices that fit your constraints. Bounded queues work for my use case. Circuit breakers prevent cascade failures.

Testing shapes design. The fault injection framework wouldn't exist if I bolted testing onto finished code. When you know you need to simulate failures, you design for testability from the start.

Clean git history matters more than I thought. I went back and removed AI co-author attributions because at this point in my career, the work should speak for itself. The commit history tells a story: architecture decisions, implementation, testing, refinement.

**The Numbers (Because People Always Ask)**

The gateway handles over 100 samples per second with less than 10ms latency at the 99th percentile. On a basic 4-core system. The bounded queues prevent memory exhaustion. The circuit breaker trips within 3 failures and tests recovery after 5 seconds. The test suite covers over 90% of critical paths and runs in under 30 seconds.

Are these impressive numbers? Not really. Production telemetry systems handle way more. But they're sufficient to show the patterns work and the architecture makes sense.

**It's on GitHub**

The whole thing is on GitHub at github.com/amareshkumar/telemetryhub. MIT licensed, documented, tested. If you're curious about modern C++ or just want to see how someone with 13 years of experience approaches a project, take a look.

**Why I Actually Built This**

Here's the truth: I built TelemetryHub because "I know modern C++" sounds great in interviews but doesn't mean much. At senior level, you need to show, not tell. This project is my show.

It's not perfect. Nothing ever is. But it's thoughtful, it's tested, and it demonstrates how I approach engineering. When someone asks "how do you handle failures?" I can point to the circuit breaker. When they ask about testing, there's a fault injection framework. When they ask about modern C++, the code is right there.

That's worth a few weeks of work. Maybe it helps someone else learning these patterns. Maybe it lands me an interesting conversation with a company building something cool. Maybe it just sits there on GitHub and that's fine too.

What matters is I can point to it and say: this is how I build software. Judge for yourself.

---

**About Me**

I'm Amaresh, a senior C++ systems engineer based in Eindhoven, Netherlands. I've spent 13 years building production software across embedded systems (automotive, medical, industrial), backend services, and desktop applications. When I'm not wrestling with C++, I'm probably thinking about how to make systems more reliable or complaining about code quality. You can find me on LinkedIn or check out my work on GitHub at github.com/amareshkumar/telemetryhub.

If you're building something interesting where reliability matters and you think we'd work well together, reach out. I'm always interested in good engineering conversations.
