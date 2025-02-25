<div align=center>
  <img width=200 src="assets\cczu_helper_icon.png"  alt="图标"/>
  <h1 align="center">吊大助手</h1>
</div>

<div align=center>

一款改善你在CCZU的生活体验的应用😋

<img src="https://img.shields.io/badge/flutter-3+-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/Rust-2021-brown" alt="Rust">
  <img src="https://img.shields.io/github/languages/code-size/CCZU-OSSA/cczu-helper?color=green" alt="size">
  <img src="https://img.shields.io/github/license/CCZU-OSSA/cczu-helper" alt="license">
</div>

## 为什么有这个

起源于吊大的打卡查询的应用，起初是自用的应用，后来觉得不如做好点发出来大家一起用，技术本身就是用来改善生活的，希望这个应用能让你在吊大更加便利~

[![图片](doc/screenshot.png)](https://github.com/CCZU-OSSA/cczu-helper/releases/latest)

## 平台支持

| Windows | Android | Linux | MacOS | IOS |
| ------- | ------- | ----- | ----- | --- |
| ✅       | ✅       | ✅     | ✅     | ❌   |


## 参与本项目

### 反馈意见

如果不知道如何在Github提issue，可以搜一下`如何提issue`

https://github.com/CCZU-OSSA/cczu-helper/issues

### 项目结构
''' 
├── CCZUHelper                         # 项目根目录，重命名为更符合 Swift 惯例
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset       # 强调色配置
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset         # 应用图标集
│   │   │   ├── Contents.json
│   │   │   ├── Icon-App-1024x1024@1x.png  # 添加完整图标集（从之前的 Flutter 项目迁移）
│   │   │   ├── Icon-App-20x20@1x.png
│   │   │   ├── Icon-App-20x20@2x.png
│   │   │   ├── Icon-App-20x20@3x.png
│   │   │   ├── Icon-App-29x29@1x.png
│   │   │   ├── Icon-App-29x29@2x.png
│   │   │   ├── Icon-App-29x29@3x.png
│   │   │   ├── Icon-App-40x40@1x.png
│   │   │   ├── Icon-App-40x40@2x.png
│   │   │   ├── Icon-App-40x40@3x.png
│   │   │   ├── Icon-App-60x60@2x.png
│   │   │   ├── Icon-App-60x60@3x.png
│   │   │   ├── Icon-App-76x76@1x.png
│   │   │   ├── Icon-App-76x76@2x.png
│   │   │   ├── Icon-App-83.5x83.5@2x.png
│   │   │   ├── app_icon_16.png       # macOS 图标
│   │   │   ├── app_icon_32.png
│   │   │   ├── app_icon_64.png
│   │   │   ├── app_icon_128.png
│   │   │   ├── app_icon_256.png
│   │   │   ├── app_icon_512.png
│   │   └── Contents.json
│   ├── Resources                      # 新增：存放图片等静态资源
│   │   ├── cczu_helper_icon.png       # 从原 assets 迁移
│   │   ├── cmcc_account.png
│   │   ├── grade.png
│   │   ├── icalendar.png
│   │   ├── lab.png
│   │   ├── rank.png
│   │   └── background.png            # 启动背景图
│   ├── Sources                        # 新增：组织源代码
│   │   ├── Controllers
│   │   │   ├── Accounts.swift        # 账户管理
│   │   │   ├── Calendar.swift        # 日历逻辑
│   │   │   ├── Config.swift          # 配置管理
│   │   │   ├── Platform.swift        # 平台特定功能
│   │   │   └── Scheduler.swift       # 通知调度
│   │   ├── Models
│   │   │   ├── Fields.swift          # 数据字段
│   │   │   ├── NavStyle.swift        # 导航样式
│   │   │   └── Version.swift         # 版本信息
│   │   ├── Views
│   │   │   ├── Pages
│   │   │   │   ├── AccountView.swift      # 账户页面
│   │   │   │   ├── CalendarView.swift     # 日历页面
│   │   │   │   ├── CalendarSettingsView.swift # 日历设置
│   │   │   │   ├── LogView.swift          # 日志页面
│   │   │   │   ├── ServicesView.swift     # 服务页面
│   │   │   │   ├── SettingsView.swift     # 设置页面
│   │   │   │   ├── TutorialView.swift     # 教程页面
│   │   │   │   └── UpdateView.swift       # 更新页面
│   │   │   ├── Services
│   │   │   │   ├── Common
│   │   │   │   │   └── ICalendar.swift    # iCalendar 解析
│   │   │   │   ├── Edu
│   │   │   │   │   └── Wechat
│   │   │   │   │       ├── Grades.swift   # 微信成绩
│   │   │   │   │       └── Ranks.swift    # 微信排名
│   │   │   │   ├── Misc
│   │   │   │   │   └── CMCCAccount.swift  # 移动账户
│   │   │   │   └── SSO
│   │   │   │       ├── Grades.swift       # 单点登录成绩
│   │   │   │       └── Lab.swift          # 单点登录实验室
│   │   │   └── Widgets
│   │   │       ├── Adaptive.swift         # 自适应组件
│   │   │       ├── Markdown.swift         # Markdown 渲染
│   │   │       ├── Progressive.swift      # 渐进加载
│   │   │       ├── Scrollable.swift       # 可滚动组件
│   │   │       └── Selector.swift         # 选择器
│   │   ├── CCZUHelperApp.swift            # 重命名自 CCZU_helperApp.swift
│   │   └── MainView.swift                 # 重命名自 ContentView.swift
│   ├── CCZUHelper.entitlements            # 重命名自 CCZU_helper.entitlements
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   │       └── Contents.json
│   ├── Info.plist                         # 新增：应用信息配置文件
│   ├── LaunchScreen.storyboard            # 新增：iOS 启动屏幕（可选）
│   └── MainMenu.xib                       # 新增：macOS 主菜单（可选）
├── CCZUHelper.xcodeproj                   # 重命名自 CCZU-helper.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   └── swiftpm
│   │   │       └── configuration
│   │   └── xcuserdata
│   │       └── rayanceking.xcuserdatad
│   │           └── UserInterfaceState.xcuserstate
│   └── xcuserdata
│       └── rayanceking.xcuserdatad
│           └── xcschemes
│               └── xcschememanagement.plist
├── CCZUHelperTests                        # 重命名自 CCZU-helperTests
│   └── CCZUHelperTests.swift              # 重命名自 CCZU_helperTests.swift
├── CCZUHelperUITests                      # 重命名自 CCZU-helperUITests
│   ├── CCZUHelperUITests.swift            # 重命名自 CCZU_helperUITests.swift
│   └── CCZUHelperUITestsLaunchTests.swift # 重命名自 CCZU_helperUITestsLaunchTests.swift
├── Protos                                 # 新增：协议文件（可选）
│   ├── Account.proto
│   ├── CMCC.proto
│   ├── Grades.proto
│   ├── ICalendar.proto
│   ├── Lab.proto
│   └── Update.proto
├── LICENSE
├── README.md
└── TODO.md'''

### 如何编译

编译之前先确保你的设备上拥有 Rust 与 Flutter 环境，需要`clone`此项目你还需要一个`git`

然后运行以下代码

`<target-platform>`取决于你的目标平台

可以使用`flutter help build`命令查看

```sh
git clone https://github.com/CCZU-OSSA/cczu-helper.git
cd cczu-helper
cargo install rinf
rinf message
flutter build <target-platform> --release
```
