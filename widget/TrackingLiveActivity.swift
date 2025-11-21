//
//  TrackingLiveActivity.swift
//  widget
//
//  Created by Rafael Mai on 2025/11/20.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var isActive: Bool
    }

    var deviceName: String
}

struct TrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackingAttributes.self) { context in
            // 🔴 Lock Screen / Banner UI
            let second = context.state.elapsedSeconds % 60
            let minute = (context.state.elapsedSeconds / 60) % 60
            let hour = context.state.elapsedSeconds / 3600
            
            HStack {
                Circle()
                    .fill(.red)
                    .frame(width: 20, height: 20)

                Text("追蹤中 \(hour)h \(minute)m \(second)s")
                    .font(.headline)
            }
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded

                let second = context.state.elapsedSeconds % 60
                let minute = (context.state.elapsedSeconds / 60) % 60
                let hour = context.state.elapsedSeconds / 3600
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("BunBun Tracking Designed By Rafa")
                        .font(.footnote)
                }
                DynamicIslandExpandedRegion(.leading) {
                    VStack{
                        Spacer()
                        Circle()
                            .fill(.red)
                            .frame(width: 30, height: 30)
                            .padding(.leading, 15)       // 距離左邊 15
                            .padding(.top, 15)
                        Spacer()
                    }

                }
                DynamicIslandExpandedRegion(.center) {
                    Text("追蹤中：\(hour)時 \(minute)分 \(second) 秒")
                        .font(.title3)
                        .padding(.top, 7)
                }
                
            } compactLeading: {
                // 🔴 小圖示（左）
                Circle()
                    .fill(.pink)
                    .frame(width: 15, height: 15)
                    .padding(.leading, 5)

            } compactTrailing: {
                // 秒數（右）
                Text("\(context.state.elapsedSeconds)")
                    .font(.caption2).padding(.leading, 5)
            } minimal: {
                // Minimal Style
                Circle()
                    .fill(.blue)
                    .frame(width: 15, height: 15)
                    .padding(.leading, 5)

            }
        }
    }
}
