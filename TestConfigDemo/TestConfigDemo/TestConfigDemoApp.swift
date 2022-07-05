//
//  TestConfigDemoApp.swift
//  TestConfigDemo
//
//  Created by 欧冬冬 on 2022/5/23.
//

import SwiftUI

@main

struct TestWidget: Widget {
    let kind: String = "TestWidget"
    var body: some WidgetConfiguration {
     StaticConfiguration(kind: kind,provider: Provider()) { entry in
            TestWidget EntryView(entry: entry)
        }
        .configurationDisplayName("name")
        .description("des")
        .supportedFamilies([.systemMedium])
    }
}

struct TestConfigDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
