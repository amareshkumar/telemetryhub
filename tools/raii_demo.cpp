#include "C:\code\telemetryhub\device\include\telemetryhub\device\FileHandle.h"
#include <iostream>
#include <string>

using telemetryhub::device::FileHandle;

int main()
{
    try
    {
        std::cout << "RAII demo starting...\n";

        FileHandle f{"telemetry_demo.log", "w"};
        if (!f)
        {
            std::cerr << "Failed to open file.\n";
            return 1;
        }

        const char* msg = "TelemetryHub RAII demo: this file is managed by FileHandle.\n";
        std::fwrite(msg, 1, std::strlen(msg), f.get());

        std::cout << "Wrote to telemetry_demo.log successfully.\n";

        // Move test: show that move semantics keep things safe
        FileHandle f2 = std::move(f);
        if (!f && f2)
        {
            std::cout << "Move semantics worked: original is empty, new one owns the handle.\n";
        }

        // On exit, f2's destructor will close the file.
    }
    catch (const std::exception& ex)
    {
        std::cerr << "Exception: " << ex.what() << "\n";
        return 1;
    }

    return 0;
}
