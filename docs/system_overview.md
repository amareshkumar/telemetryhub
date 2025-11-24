What is TelemetryHub (your version)?

“It’s a small demo system with a fake measuring device, a gateway service, and (later) a GUI monitor…”

Which components exist?

device – fake embedded sensor producing samples + states

gateway – service/daemon reading those samples, buffering them, talking to “cloud” (REST client)

gui – Qt app to show state & samples (even if minimal)

What problem does this architecture illustrate?

Safe handling of a streaming device

Producer–consumer with a queue

Clean separation of concerns

## What this project is

## Main building blocks

- device/…
- gateway/…
- gui/…

## What it demonstrates for interviews
