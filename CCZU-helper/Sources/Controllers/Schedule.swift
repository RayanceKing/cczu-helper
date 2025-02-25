//
//  Schedule.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import UserNotifications

class Scheduler {
    static func initScheduler() {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        // 实现通知初始化逻辑
        #endif
    }

    static func reScheduleAll() {
        #if os(iOS)
        // 重新调度所有通知
        #endif
    }
}
