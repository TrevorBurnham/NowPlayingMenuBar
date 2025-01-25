//
//  SparkleDelegate.swift
//  NowPlayingMenuBar
//

import Foundation
import Sparkle

class SparkleDelegate: NSObject, SPUStandardUserDriverDelegate, SPUUpdaterDelegate {
  @Published var updateAvailable: SUAppcastItem?

  var supportsGentleScheduledUpdateReminders: Bool {
    return true
  }

  func standardUserDriverShouldHandleShowingScheduledUpdate(
    _ update: SUAppcastItem,
    andInImmediateFocus immediateFocus: Bool
  ) -> Bool {
    // We'll handle showing the update ourselves
    return false
  }

  func standardUserDriverWillHandleShowingUpdate(
    _ handleShowingUpdate: Bool,
    forUpdate update: SUAppcastItem,
    state: SPUUserUpdateState
  ) {
    // Store the update information
    updateAvailable = update
  }

  func standardUserDriverWillFinishUpdateSession() {
    // Clear the update information when the session is done
    updateAvailable = nil
  }
}
