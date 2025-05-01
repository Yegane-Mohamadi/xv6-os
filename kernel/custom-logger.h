// kernel/custom_logger.h

#ifndef CUSTOM_LOGGER_H
#define CUSTOM_LOGGER_H

// تعریف enum برای سطح لاگ
enum log_level {
    INFO = 0,
    WARN = 1,
    ERROR = 2
};

// تابع اصلی لاگر
void log_message(int level, const char *message);

#endif
