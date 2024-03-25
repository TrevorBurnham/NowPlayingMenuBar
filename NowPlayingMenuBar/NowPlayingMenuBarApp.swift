//
//  NowPlayingMenuBarApp.swift
//  NowPlayingMenuBar
//

import SwiftUI

@main
struct NowPlayingMenuBarApp: App {
  @ObservedObject var observer = NowPlayingObserver()
  @ObservedObject var launchAtLogin = LaunchAtLogin.observable

  var body: some Scene {
    MenuBarExtra {
      Toggle(
        "Launch on Login",
        isOn: $launchAtLogin.isEnabled)
      Button("Quit") {
        NSApplication.shared.terminate(self)
      }
    } label: {
      Text(
        observer.currentTrack?.playing == true
          ? """
          \(observer.currentTrack!.artist != nil
            ? observer.currentTrack!.artist!
            : "Unknown artist") - \(observer.currentTrack!.name!)
          """
          : "♫"
      )
    }
  }
}
