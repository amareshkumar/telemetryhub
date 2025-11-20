#pragma once

#include <cstdio>
#include <string>
#include <stdexcept>

namespace telemetryhub::device {

class FileHandle
{
public:
    FileHandle() = default;
    FileHandle(const std::string& path, const std::string& mode);
    ~FileHandle();

    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;

    FileHandle(FileHandle&& other) noexcept;
    FileHandle& operator=(FileHandle&& other) noexcept;

    void open(const std::string& path, const std::string& mode);
    void close() noexcept;
    
    std::FILE* get() const noexcept;

    explicit operator bool() const noexcept;

private:
    std::FILE* handle_ = nullptr;
};

} // namespace telemetryhub::device
