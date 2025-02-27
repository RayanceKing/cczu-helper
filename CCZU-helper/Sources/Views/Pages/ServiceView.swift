//
//  ServiceView.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import SwiftUI

// 服务项模型
struct ServiceItem: Identifiable {
    let id = UUID()
    let text: String // 用于选项卡显示
    let service: AnyView?
    let image: String // Resources 中的图片名称
    
    init(text: String, service: AnyView? = nil, image: String) {
        self.text = text
        self.service = service
        self.image = image
    }
}

// 假设的账户数据模型
class MultiAccountData: ObservableObject {
    @Published var currentEduAccount: String? = nil
    @Published var currentSSOAccount: String? = nil
    
    func hasCurrentEduAccount() -> Bool {
        return currentEduAccount != nil
    }
    
    func hasCurrentSSOAccount() -> Bool {
        return currentSSOAccount != nil
    }
}

// 服务视图
struct ServiceView: View {
    @EnvironmentObject var accounts: MultiAccountData
    @State private var selectedTab: Int = 0
    
    // 服务数据
    private let services: [String: [ServiceItem]] = [
        "教务系统": [
            ServiceItem(
                text: "生成课程表(企微)",
                service: AnyView(ICalendarServiceView(api: .wechat)),
                image: "icalendar"
            ),
            ServiceItem(
                text: "查询成绩(企微)",
                service: AnyView(WeChatGradeQueryServiceView()),
                image: "grade"
            ),
            ServiceItem(
                text: "排名绩点(企微)",
                service: AnyView(WeChatRankServiceView()),
                image: "rank"
            )
        ],
        "一网通办": [
            ServiceItem(
                text: "生成课程表",
                service: AnyView(ICalendarServiceView(api: .jwcas)),
                image: "icalendar"
            ),
            ServiceItem(
                text: "查询成绩",
                service: AnyView(GradeQueryServiceView()),
                image: "grade"
            ),
            ServiceItem(
                text: "实验室时长",
                service: AnyView(LabServiceView()),
                image: "lab"
            )
        ],
        "杂项": [
            ServiceItem(
                text: "生成CMCC宽带拨号账户",
                service: AnyView(CMCCAccountServiceView()),
                image: "cmcc_account"
            )
        ]
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // 选项卡切换（左上方）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(services.keys.enumerated()), id: \.offset) { index, key in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(key)
                                .font(.headline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedTab == index ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 服务项网格
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 150), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    if let items = services[Array(services.keys)[selectedTab]] {
                        ForEach(items) { item in
                            ServiceItemView(item: item)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("服务")
    }
    
    // 账户检查逻辑
    static func accountCheckOnTap(predicate: (MultiAccountData) -> Bool, item: ServiceItem, context: Binding<AnyView?>) {
        let accounts = MultiAccountData() // 应从 @EnvironmentObject 获取
        if predicate(accounts) {
            if let service = item.service {
                context.wrappedValue = service
            }
        } else {
            let alert = Alert(
                title: Text("账户未填写!"),
                message: Text("还未填写或选中账户，确认使用此功能？"),
                primaryButton: .default(Text("打开账户设置"), action: {
                    context.wrappedValue = AnyView(AccountManageView())
                }),
                secondaryButton: .default(Text("确认"), action: {
                    if let service = item.service {
                        context.wrappedValue = service
                    }
                })
            )
            NavigationHelper.showAlert(alert)
        }
    }
    
    static func eduCheckOnTap(item: ServiceItem) -> Void {
        accountCheckOnTap(predicate: { $0.hasCurrentEduAccount() }, item: item, context: .constant(nil))
    }
    
    static func ssoCheckOnTap(item: ServiceItem) -> Void {
        accountCheckOnTap(predicate: { $0.hasCurrentSSOAccount() }, item: item, context: .constant(nil))
    }
}

// 服务项视图
struct ServiceItemView: View {
    let item: ServiceItem
    @State private var presentedView: AnyView? = nil
    
    var body: some View {
        let dimension = min(UIScreen.main.bounds.width / 2 - 16, 200)
        Button(action: {
            if item.text.contains("(企微)") {
                ServiceView.eduCheckOnTap(item: item)
            } else if item.text == "生成课程表" || item.text == "查询成绩" || item.text == "实验室时长" {
                ServiceView.ssoCheckOnTap(item: item)
            } else if let service = item.service {
                presentedView = service
            }
        }) {
            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(width: dimension, height: dimension)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
        .frame(width: dimension, height: dimension)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        
    }
}

// 导航辅助类
struct NavigationHelper {
    static func showAlert(_ alert: Alert) {
        // 假设通过全局方法显示 Alert
        print("Showing alert: \(alert)")
    }
}

// 假设的其他视图（占位符）
struct ICalendarServiceView: View {
    enum APIType { case wechat, jwcas }
    let api: APIType
    var body: some View { Text("ICalendar Service") }
}

struct WeChatGradeQueryServiceView: View {
    var body: some View { Text("WeChat Grade Query") }
}

struct WeChatRankServiceView: View {
    var body: some View { Text("WeChat Rank") }
}

struct GradeQueryServiceView: View {
    var body: some View { Text("Grade Query") }
}

struct LabServiceView: View {
    var body: some View { Text("Lab Service") }
}

struct CMCCAccountServiceView: View {
    var body: some View { Text("CMCC Account") }
}

struct AccountManageView: View {
    var body: some View { Text("Account Manage") }
}

// 预览
struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView()
            .environmentObject(MultiAccountData())
    }
}
