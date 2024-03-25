//
//  LaunchAtLogin.swift
//  NowPlayingMenuBar
//

import ServiceManagement
import SwiftUI
import os.log

public enum LaunchAtLogin {
  static let observable = Observable()

  public static var isEnabled: Bool {
    get { SMAppService.mainApp.status == .enabled }
    set {
      observable.objectWillChange.send()

      do {
        if newValue {
          if SMAppService.mainApp.status == .enabled {
            try? SMAppService.mainApp.unregister()
          }
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        os_log(
          "Failed to \(newValue ? "enable" : "disable", privacy: .public) launch at login: \(error.localizedDescription, privacy: .public)"
        )
      }
    }
  }
}

extension LaunchAtLogin {
  final class Observable: ObservableObject {
    var isEnabled: Bool {
      get { LaunchAtLogin.isEnabled }
      set {
        LaunchAtLogin.isEnabled = newValue
      }
    }
  }
}
