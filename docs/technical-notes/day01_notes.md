What is RAII?

“RAII = Resource Acquisition Is Initialization. I tie resource lifetime to object lifetime so resources are acquired in the constructor and released in the destructor, even on exceptions.”

Where have I used RAII?

“In TelemetryHub (FileHandle), and in past roles at Bosch/McAfee/Priva for file handles, sockets, mutexes, etc.”

Why move-only for FileHandle?

“The file handle is a unique resource; copying would cause double-close. Move semantics allow safe transfer of ownership.”