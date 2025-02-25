//
//  Config.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import Foundation

class ApplicationConfigs: ObservableObject {
    @Published var themeMode: ThemeMode = .system
    @Published var navStyle: NavigationStyle = .both
    @Published var firstUse: Bool = true
    @Published var autoSaveLog: Bool = false
    @Published var sysFont: String? = nil
    @Published var notificationsEnable: Bool = false
    @Published var notificationsDay: Bool = true
    @Published var skipServiceExitConfirm: Bool = false
    @Published var weakAnimation: Bool = true

    enum ThemeMode {
        case light, dark, system
    }

    func load(from url: URL) {
        // 模拟从 JSON 文件加载配置
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                // 这里需要定义具体配置的 JSON 结构
            } catch {
                print("加载配置失败: \(error)")
            }
        }
    }
}
