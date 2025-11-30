#pragma once

// Centralized feature toggles for cpp-httplib to avoid optional deps
// Wrap in guards to prevent redefinition warnings if included elsewhere
// If build system predefines support macros, force-undef them so
// httplib does not enter optional dependency branches.
#ifdef CPPHTTPLIB_ZSTD_SUPPORT
#undef CPPHTTPLIB_ZSTD_SUPPORT
#endif
#ifdef CPPHTTPLIB_BROTLI_SUPPORT
#undef CPPHTTPLIB_BROTLI_SUPPORT
#endif
#ifdef CPPHTTPLIB_ZLIB_SUPPORT
#undef CPPHTTPLIB_ZLIB_SUPPORT
#endif
#ifdef CPPHTTPLIB_OPENSSL_SUPPORT
#undef CPPHTTPLIB_OPENSSL_SUPPORT
#endif

#ifndef CPPHTTPLIB_NO_ZSTD
#define CPPHTTPLIB_NO_ZSTD 1
#endif

#ifndef CPPHTTPLIB_NO_BROTLI
#define CPPHTTPLIB_NO_BROTLI 1
#endif

#ifndef CPPHTTPLIB_NO_ZLIB
#define CPPHTTPLIB_NO_ZLIB 1
#endif

#ifndef CPPHTTPLIB_NO_OPENSSL
#define CPPHTTPLIB_NO_OPENSSL 1
#endif
