//
//  NowPlayingMenuBarApp.swift
//  NowPlayingMenuBar
//

import Sparkle
import SwiftUI

@main
struct NowPlayingMenuBarApp: App {
  @ObservedObject var observer = NowPlayingObserver()
  @ObservedObject var launchAtLogin = LaunchAtLogin.observable

  private let sparkleDelegate = SparkleDelegate()
  private let updaterController: SPUStandardUpdaterController

  init() {
    updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: sparkleDelegate,
      userDriverDelegate: sparkleDelegate
    )

    // Check for updates immediately at launch.
    updaterController.updater.checkForUpdateInformation()
  }

  var body: some Scene {
    MenuBarExtra {
      if let update = sparkleDelegate.updateAvailable {
        Button("Update Available: v\(update.displayVersionString)") {
          // Prompt the user to update.
          updaterController.checkForUpdates(nil)
        }
        Divider()
      }

      Toggle(
        "Launch on Login",
        isOn: $launchAtLogin.isEnabled
      )

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
