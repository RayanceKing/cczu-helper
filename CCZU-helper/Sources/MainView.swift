import SwiftUI

struct MainView: View {
    @EnvironmentObject private var configs: ApplicationConfigs
    @EnvironmentObject private var logger: Logger
    @State private var currentIndex: Int = 0

    private let viewItems = [
        NavigationItem(icon: "calendar", label: "课表", view: CalendarView()),
        NavigationItem(icon: "graduationcap", label: "服务", view: ServiceView()),
        NavigationItem(icon: "gear", label: "设置", view: SettingsView())
    ]

    var body: some View {
        if configs.firstUse {
            TutorialView()
        } else {
            mainContent
                .onAppear {
                    if configs.notificationsEnable && configs.notificationsDay {
                        logger.info("尝试重新调度所有通知")
                        Scheduler.reScheduleAll()
                    }
                    checkErrorLog()
                }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        let navStyle = configs.navStyle
        let isDark = configs.themeMode == .system ? colorScheme == .dark : configs.themeMode == .dark
        let showTop = navStyle == .top || navStyle == .both

        #if os(iOS)
        TabView(selection: $currentIndex) {
            ForEach(viewItems.indices, id: \.self) { index in
                viewItems[index].view
                    .tabItem {
                        Label(viewItems[index].label, systemImage: viewItems[index].icon)
                    }
                    .tag(index)
            }
        }
        .navigationTitle(showTop ? viewItems[currentIndex].label : "")
        .navigationBarHidden(navStyle == .nav)
        .toolbar {
            if showTop {
                ToolbarItem(placement: .navigationBarTrailing) {
                    themeToggleButton(isDark: isDark)
                }
            }
        }
        #elseif os(macOS)
        NavigationSplitView {
            List(viewItems.indices, selection: $currentIndex) { index in
                NavigationLink(value: index) {
                    Label(viewItems[index].label, systemImage: viewItems[index].icon)
                }
            }
            .navigationTitle("常大助手")
            .toolbar {
                ToolbarItem {
                    themeToggleButton(isDark: isDark)
                }
            }
        } detail: {
            viewItems[currentIndex].view
        }
        #endif
    }

    @Environment(\.colorScheme) var colorScheme

    private func themeToggleButton(isDark: Bool) -> some View {
        Button(action: {
            configs.themeMode = isDark ? .light : .dark
        }) {
            Image(systemName: isDark ? "sun.max" : "moon")
        }
        .contextMenu {
            Button("系统默认") {
                configs.themeMode = .system
            }
        }
    }

    private func checkErrorLog() {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFile = documentsDir.appendingPathComponent("error.log")
            if FileManager.default.fileExists(atPath: logFile.path) {
                do {
                    let data = try String(contentsOf: logFile)
                    try FileManager.default.removeItem(at: logFile)
                    logger.info("检测到错误日志，已删除: \(data)")
                } catch {
                    logger.error("处理错误日志失败: \(error)")
                }
            }
        }
    }
}
