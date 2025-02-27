//
//  CCZU_helperApp.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI
import UserNotifications

// 静态变量存储上下文
private struct ErrorHandlerContext {
    static var logger: Logger?
    static var configs: ApplicationConfigs?
}

private func handleUncaughtException(_ exception: NSException) {
    if let logger = ErrorHandlerContext.logger {
        logger.error("未捕获异常: \(exception.description)")
        logger.error("堆栈: \(exception.callStackSymbols.joined(separator: "\n"))")
    }
    if let configs = ErrorHandlerContext.configs, configs.autoSaveLog {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFile = documentsDir.appendingPathComponent("error.log")
            try? ErrorHandlerContext.logger?.getLogs().joined(separator: "\n").write(to: logFile, atomically: true, encoding: .utf8)
        }
    }
}

@main
struct CCZUHelperApp: App {
    @StateObject private var configs = ApplicationConfigs()
    @StateObject private var logger = Logger()

    init() {
        setupErrorHandling()
        TimeZone.initializeTimeZones()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(configs)
                .environmentObject(logger)
                .preferredColorScheme(configs.themeMode == .system ? nil : (configs.themeMode == .dark ? .dark : .light))
                .onAppear {
                    // 在视图加载后设置静态变量
                    ErrorHandlerContext.logger = logger
                    ErrorHandlerContext.configs = configs
                    loadInitialData()
                }
        }
    }

    private func setupErrorHandling() {
        NSSetUncaughtExceptionHandler(handleUncaughtException)
    }

    private func saveErrorLog() {
        if configs.autoSaveLog {
            if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let logFile = documentsDir.appendingPathComponent("error.log")
                do {
                    try logger.getLogs().joined(separator: "\n").write(to: logFile, atomically: true, encoding: .utf8)
                } catch {
                    logger.error("保存日志失败: \(error)")
                }
            }
        }
    }

    private func loadInitialData() {
        logger.info("应用程序启动...")

        if let userDataDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let configPath = userDataDir.appendingPathComponent("app.config.json")
            logger.info("配置文件路径: \(configPath.path)")
            configs.load(from: configPath)

            let accountsFile = userDataDir.appendingPathComponent("accounts.json")
            if FileManager.default.fileExists(atPath: accountsFile.path) {
                logger.info("加载账户数据...")
            } else {
                logger.warn("未找到 accounts.json，使用默认模板")
            }
        }

        if let userDataDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let customFontFile = userDataDir.appendingPathComponent("customfont")
            if FileManager.default.fileExists(atPath: customFontFile.path) {
                logger.info("加载自定义字体...")
                configs.sysFont = "Custom Font"
            }
        }

        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Scheduler.initScheduler()
            }
        }
        #endif
    }
}

extension TimeZone {
    static func initializeTimeZones() {
        // 占位
    }
}
