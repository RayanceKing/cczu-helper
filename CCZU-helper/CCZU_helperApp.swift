//
//  CCZU_helperApp.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI
import Foundation

// MARK: - 应用配置模型
class ApplicationConfigs: ObservableObject {
    @Published var themeMode: ThemeMode = .system // 主题模式
    @Published var navStyle: NavigationStyle = .both // 导航样式
    @Published var firstUse: Bool = true // 是否首次使用
    @Published var sysFont: String? = nil // 系统字体
    
    enum ThemeMode {
        case light, dark, system // 浅色、深色、系统默认
    }
    
    enum NavigationStyle {
        case top, nav, both // 顶部导航、底部导航、两者兼有
    }
}

// MARK: - 导航项模型
struct NavigationItem {
    let icon: String // SF Symbol 图标名称
    let label: String // 标签
    let view: AnyView // 对应的视图
    
    init(icon: String, label: String, view: some View) {
        self.icon = icon
        self.label = label
        self.view = AnyView(view)
    }
}

// MARK: - 主应用入口
@main
struct CCZUHelperApp: App {
    @StateObject private var configs = ApplicationConfigs() // 配置对象
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(configs) // 将配置注入视图层级
                .preferredColorScheme(themeMode(configs.themeMode)) // 设置主题
        }
    }
    
    // 根据配置返回主题模式
    private func themeMode(_ mode: ApplicationConfigs.ThemeMode) -> ColorScheme? {
        switch mode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - 主视图
struct MainView: View {
    @EnvironmentObject private var configs: ApplicationConfigs // 获取配置
    @State private var currentIndex: Int = 0 // 当前选中的页面索引
    
    // 导航项列表
    private let viewItems = [
        NavigationItem(icon: "calendar", label: "课表", view: CurriculumView()),
        NavigationItem(icon: "graduationcap", label: "服务", view: ServiceView()),
        NavigationItem(icon: "gear", label: "设置", view: SettingsView())
    ]
    
    var body: some View {
        if configs.firstUse {
            TutorialView() // 首次使用显示教程页面
        } else {
            mainContent // 主内容
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        let navStyle = configs.navStyle
        
        #if os(iOS)
        // iOS：使用底部标签导航
        if navStyle == .nav || navStyle == .both {
            TabView(selection: $currentIndex) {
                ForEach(viewItems.indices, id: \.self) { index in
                    viewItems[index].view
                        .tabItem {
                            Label(viewItems[index].label, systemImage: viewItems[index].icon)
                        }
                        .tag(index)
                }
            }
            .navigationBarHidden(navStyle == .nav) // 如果只有底部导航，隐藏顶部栏
            .navigationTitle(navStyle == .top || navStyle == .both ? viewItems[currentIndex].label : "")
        } else {
            // 仅顶部导航
            NavigationStack {
                viewItems[currentIndex].view
                    .navigationTitle(viewItems[currentIndex].label)
            }
        }
        #elseif os(macOS)
        // macOS：使用侧边栏导航
        NavigationSplitView {
            List(viewItems.indices, selection: $currentIndex) { index in
                NavigationLink(value: index) {
                    Label(viewItems[index].label, systemImage: viewItems[index].icon)
                }
            }
            .navigationTitle("常大助手")
        } detail: {
            viewItems[currentIndex].view
        }
        #endif
    }
}

// MARK: - 占位视图
struct CurriculumView: View {
    var body: some View {
        Text("课表页面")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ServiceView: View {
    var body: some View {
        Text("服务页面")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("设置页面")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TutorialView: View {
    @EnvironmentObject private var configs: ApplicationConfigs
    
    var body: some View {
        VStack {
            Text("欢迎使用常大助手！")
            Button("开始") {
                configs.firstUse = false // 点击后标记为非首次使用
            }
        }
    }
}

// MARK: - 预览
#Preview {
    MainView()
        .environmentObject(ApplicationConfigs())
}
