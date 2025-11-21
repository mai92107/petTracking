//
//  TrackingManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/20.
//

import ActivityKit

final class TrackingManager {

    static let shared = TrackingManager()

    private init(){}

    var activity: Activity<TrackingAttributes>?

    func start(deviceName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not allowed")
            return
        }

        let attributes = TrackingAttributes(deviceName: deviceName)
        let content = ActivityContent(
            state: TrackingAttributes.ContentState(
                elapsedSeconds: 0,
                isActive: true
            ),
            staleDate: nil
        )
        do {
            let activity = try Activity<TrackingAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            self.activity = activity
            print("🔥 Live Activity Started: \(activity.id)")

        } catch {
            print("❌ Could not start Live Activity: \(error)")
        }
    }

    func update(seconds: Int) {
        guard let activity else { return }

        let content = ActivityContent(
            state: TrackingAttributes.ContentState(
                elapsedSeconds: seconds,
                isActive: true
            ),
            staleDate: nil
        )
        Task {
            await activity.update(content)
        }
    }

    func stop() {
        guard let activity else { return }

        let content = ActivityContent(
            state: TrackingAttributes.ContentState(
                elapsedSeconds: 0,
                isActive: false
            ),
            staleDate: nil
        )

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}
