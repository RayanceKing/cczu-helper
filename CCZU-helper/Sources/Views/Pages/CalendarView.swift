//
//  CalendarView.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI
import KVKCalendar

// 课程数据模型
struct CalendarData: Identifiable {
    let id = UUID()
    let source: CalendarSource
    let location: String?
    let summary: String
    let description: String?
    let week: String?
    let start: Date
    let end: Date
    let isAllDay: Bool
    
    init(location: String?, summary: String, start: Date, end: Date, description: String? = nil, week: String? = nil, isAllDay: Bool = false, source: CalendarSource = .other) {
        self.location = location
        self.summary = summary
        self.start = start
        self.end = end
        self.description = description
        self.week = week
        self.isAllDay = isAllDay
        self.source = source
    }
}

enum CalendarSource {
    case curriculum
    case other
}

// ICS 文件解析器
struct ICalendarParser {
    let calendar: [String: Any]
    let source: CalendarSource
    
    init(raw: String, source: CalendarSource) {
        self.calendar = ICalendarParser.parse(raw)
        self.source = source
    }
    
    static func parse(_ source: String) -> [String: Any] {
        let lines = source.split(separator: "\n")
        var events: [[String: Any]] = []
        var currentEvent: [String: Any] = [:]
        
        for line in lines {
            if line.starts(with: "BEGIN:VEVENT") {
                currentEvent = ["type": "VEVENT"]
            } else if line.starts(with: "END:VEVENT") {
                events.append(currentEvent)
            } else if let (key, value) = parseLine(String(line)) {
                currentEvent[key] = value
            }
        }
        return ["data": events]
    }
    
    static func parseLine(_ line: String) -> (String, String)? {
        let components = line.split(separator: ":", maxSplits: 1)
        guard components.count == 2 else { return nil }
        return (String(components[0]), String(components[1]))
    }
    
    var data: [CalendarData] {
        guard let events = calendar["data"] as? [[String: Any]] else { return [] }
        let filter: ([String: Any]) -> Bool = { $0["type"] as? String == "VEVENT" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        
        return events.filter(filter).map { event in
            let startStr = event["DTSTART"] as? String ?? ""
            let endStr = event["DTEND"] as? String ?? ""
            let startDate = dateFormatter.date(from: startStr) ?? Date()
            let endDate = dateFormatter.date(from: endStr) ?? Date()
            
            return CalendarData(
                location: event["LOCATION"] as? String,
                summary: event["SUMMARY"] as? String ?? "",
                start: startDate,
                end: endDate,
                description: event["DESCRIPTION"] as? String,
                week: event["WEEK"] as? String,
                isAllDay: event["LOCATION"] == nil,
                source: self.source
            )
        }
    }
}

// KVKCalendar 控制器
class KVKCalendarController: UIViewController {
    private var calendarView: KVKCalendarView!
    private var events: [CalendarData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var style = Style()
        style.timeline.heightTime = 30 // 调整时间线高度
        style.startWeekDay = .monday // 从星期一开始
        
        calendarView = KVKCalendarView(frame: view.bounds, style: style)
        
        view.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        calendarView.set(type: .week, date: Date())
        loadEvents()
        scrollToCurrentTime()
    }
    
    private func scrollToCurrentTime() {
        let now = Date()
        calendarView.scrollTo(now, animated: false)
    }
    
    private func loadEvents() {
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDir, includingPropertiesForKeys: nil)
            let icsFiles = files.filter { $0.pathExtension == "ics" }
            
            var parsedEvents: [CalendarData] = []
            for file in icsFiles {
                let source: CalendarSource = file.lastPathComponent == "calendar_curriculum.ics" ? .curriculum : .other
                let rawData = try String(contentsOf: file, encoding: .utf8)
                let parser = ICalendarParser(raw: rawData, source: source)
                parsedEvents.append(contentsOf: parser.data)
            }
            events = parsedEvents
            calendarView.reloadData()
        } catch {
            print("加载 ICS 文件失败: \(error)")
        }
    }
    
    func reloadData() {
        calendarView.reloadData()
    }
}



// 将 KVKCalendar 集成到 SwiftUI
struct CalendarViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> KVKCalendarController {
        let controller = KVKCalendarController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KVKCalendarController, context: Context) {
        uiViewController.reloadData()
    }
}

// 更新后的 CalendarView
struct CalendarView: View {
    var body: some View {
        CalendarViewWrapper()
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


enum NavStyle {
    case top, both, nav
}

enum ThemeMode {
    case system, light, dark
}
