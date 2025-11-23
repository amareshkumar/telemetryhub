#include "telemetryhub/device/FileHandle.h"

namespace telemetryhub::device {

void FileHandle::open(const std::string &path, const std::string &mode)
{
    close();
    handle_ = std::fopen(path.c_str(), mode.c_str());
    if (!handle_)
    {
        throw std::runtime_error("Failed to open file: " + path);
    }
}

void FileHandle::close() noexcept
{
    if (handle_)
    {
        std::fclose(handle_);
        handle_ = nullptr;
    }
}

std::FILE *FileHandle::get() const noexcept
{
    return handle_;
}

FileHandle::operator bool() const noexcept
{
    return handle_ != nullptr;
}

FileHandle::FileHandle(const std::string& path, const std::string& mode)
{
    open(path, mode);
}

FileHandle::~FileHandle()
{
    close();
}

FileHandle::FileHandle(FileHandle &&other) noexcept : handle_(other.handle_)
{
    other.handle_ = nullptr;
}

FileHandle& FileHandle::operator=(FileHandle &&other) noexcept
{
    if (this != &other)
    {
        close();
        handle_ = other.handle_;
        other.handle_ = nullptr;
    }
    return *this;
}

} // namespace telemetryhub::device