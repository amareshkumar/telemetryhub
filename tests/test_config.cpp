#include "telemetryhub/gateway/Config.h"
#include <gtest/gtest.h>
#include <fstream>
#include <filesystem>

using namespace telemetryhub::gateway;

class ConfigTest : public ::testing::Test {
protected:
    void SetUp() override {
        test_dir_ = std::filesystem::temp_directory_path() / "telemetryhub_test";
        std::filesystem::create_directories(test_dir_);
    }

    void TearDown() override {
        std::filesystem::remove_all(test_dir_);
    }

    std::string write_config(const std::string& content) {
        auto path = test_dir_ / "test_config.ini";
        std::ofstream f(path);
        f << content;
        f.close();
        return path.string();
    }

    std::filesystem::path test_dir_;
};

TEST_F(ConfigTest, LoadValidConfig) {
    auto path = write_config(R"(
sampling_interval_ms = 250
queue_size = 512
log_level = debug
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 250);
    EXPECT_EQ(cfg.queue_size, 512u);
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Debug);
}

TEST_F(ConfigTest, LoadConfigWithComments) {
    auto path = write_config(R"(
# This is a comment
sampling_interval_ms = 100  # inline comment
; semicolon comment
queue_size = 256
log_level = info  ; another inline
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 100);
    EXPECT_EQ(cfg.queue_size, 256u);
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Info);
}

TEST_F(ConfigTest, LoadConfigWithWhitespace) {
    auto path = write_config(R"(
  sampling_interval_ms  =  150  
queue_size=1024
  log_level = warn  
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 150);
    EXPECT_EQ(cfg.queue_size, 1024u);
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Warn);
}

TEST_F(ConfigTest, LoadConfigPartial) {
    auto path = write_config(R"(
sampling_interval_ms = 75
)");

    AppConfig cfg;
    cfg.queue_size = 999; // pre-set value
    cfg.log_level = ::telemetryhub::LogLevel::Error;
    
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 75);
    EXPECT_EQ(cfg.queue_size, 999u); // unchanged
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Error); // unchanged
}

TEST_F(ConfigTest, LoadConfigCaseInsensitiveKeys) {
    auto path = write_config(R"(
SAMPLING_INTERVAL_MS = 50
Queue_Size = 128
LOG_LEVEL = error
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 50);
    EXPECT_EQ(cfg.queue_size, 128u);
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Error);
}

TEST_F(ConfigTest, LoadConfigLogLevelVariants) {
    auto path = write_config(R"(
log_level = warning
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Warn);
}

TEST_F(ConfigTest, LoadConfigNonExistentFile) {
    AppConfig cfg;
    EXPECT_FALSE(load_config("/nonexistent/path/config.ini", cfg));
}

TEST_F(ConfigTest, LoadConfigEmptyFile) {
    auto path = write_config("");

    AppConfig cfg;
    cfg.sampling_interval = std::chrono::milliseconds(999);
    cfg.queue_size = 888;
    
    ASSERT_TRUE(load_config(path, cfg));
    // Values should remain at defaults since nothing was parsed
    EXPECT_EQ(cfg.sampling_interval.count(), 999);
    EXPECT_EQ(cfg.queue_size, 888u);
}

TEST_F(ConfigTest, LoadConfigIgnoresInvalidLines) {
    auto path = write_config(R"(
sampling_interval_ms = 200
invalid line without equals
queue_size = 64
random=garbage=with=multiple=equals
log_level = trace
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 200);
    EXPECT_EQ(cfg.queue_size, 64u);
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Trace);
}

TEST_F(ConfigTest, LoadConfigUnknownKeysIgnored) {
    auto path = write_config(R"(
sampling_interval_ms = 300
unknown_key = 42
queue_size = 1000
another_unknown = value
)");

    AppConfig cfg;
    ASSERT_TRUE(load_config(path, cfg));
    EXPECT_EQ(cfg.sampling_interval.count(), 300);
    EXPECT_EQ(cfg.queue_size, 1000u);
}

TEST_F(ConfigTest, DefaultValues) {
    AppConfig cfg;
    EXPECT_EQ(cfg.sampling_interval.count(), 100); // default
    EXPECT_EQ(cfg.queue_size, 0u); // unbounded
    EXPECT_EQ(cfg.log_level, ::telemetryhub::LogLevel::Info);
}
