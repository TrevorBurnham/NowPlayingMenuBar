//
//  NowPlayingMenuBarApp.swift
//  NowPlayingMenuBar
//

import SwiftUI
import Sparkle

@main
struct NowPlayingMenuBarApp: App {
  @ObservedObject var observer = NowPlayingObserver()
  @ObservedObject var launchAtLogin = LaunchAtLogin.observable
    
  private let updaterController: SPUStandardUpdaterController
    
  init() {
    updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
  }

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
