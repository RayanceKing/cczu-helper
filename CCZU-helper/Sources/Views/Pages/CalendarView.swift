//
//  CalendarView.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI
import CalendarKit

// 自定义 CalendarKit 控制器
class CalendarKitController: DayViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置数据源和委托
        dayView.delegate = self
        dayView.dataSource = self

        
        // 加载数据并聚焦当前时间
        reloadData()
        scrollToCurrentTime()
    }
    
    // 重写 eventsForDate 方法
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // 返回空数组，表示没有事件
        return []
    }
    
    // 滚动到当前时间
    private func scrollToCurrentTime() {
        let now = Date()
        let hour = Float(Calendar.current.component(.hour, from: now)) // 转换为 Float
        dayView.scrollTo(hour24: hour, animated: false) // 修正方法名
    }
}

// 将 CalendarKit 集成到 SwiftUI
struct CalendarKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CalendarKitController {
        let controller = CalendarKitController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CalendarKitController, context: Context) {
        uiViewController.reloadData()
    }
}

// 更新后的 CalendarView
struct CalendarView: View {
    var body: some View {
        CalendarKitView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("课表")
    }
}

// 预览
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(ApplicationConfigs())
            .environmentObject(Logger())
    }
}
