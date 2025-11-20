#pragma once

#include <cstdio>
#include <string>
#include <stdexcept>

namespace telemetryhub::device {

class FileHandle
{
public:
    FileHandle() = default;

    FileHandle(const std::string& path, const std::string& mode)
    {
        open(path, mode);
    }

    ~FileHandle()
    {
        close();
    }

    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;

    FileHandle(FileHandle&& other) noexcept
        : handle_(other.handle_)
    {
        other.handle_ = nullptr;
    }

    FileHandle& operator=(FileHandle&& other) noexcept
    {
        if (this != &other)
        {
            close();
            handle_ = other.handle_;
            other.handle_ = nullptr;
        }
        return *this;
    }

    void open(const std::string& path, const std::string& mode)
    {
        close();
        handle_ = std::fopen(path.c_str(), mode.c_str());
        if (!handle_)
        {
            throw std::runtime_error("Failed to open file: " + path);
        }
    }

    void close() noexcept
    {
        if (handle_)
        {
            std::fclose(handle_);
            handle_ = nullptr;
        }
    }

    std::FILE* get() const noexcept { return handle_; }

    explicit operator bool() const noexcept { return handle_ != nullptr; }

private:
    std::FILE* handle_ = nullptr;
};

} // namespace telemetryhub::device
