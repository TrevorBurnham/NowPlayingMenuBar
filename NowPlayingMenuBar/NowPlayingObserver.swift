//
//  NowPlayingObserver.swift
//  NowPlayingObserver
//

import Foundation

// JSON-serializable structure for track info.
struct TrackInfo: Codable, Equatable {
  let name: String?
  let artist: String?
  let playing: Bool
}

// Load the MediaRemote framework.
let bundle = CFBundleCreate(
  kCFAllocatorDefault,
  NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

class NowPlayingObserver: NSObject, ObservableObject {
  // Info for the track that's currently playing.
  var currentTrack: TrackInfo?

  override init() {
    super.init()
    self.refreshCurrentTrack()
    self.registerNotificationObservers()
  }

  func registerNotificationObservers() {
    // Get a Swift function for MRMediaRemoteRegisterForNowPlayingNotifications.
    guard
      let registerForNotificationsPointer =
        CFBundleGetFunctionPointerForName(
          bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
    else { return }
    typealias RegisterForNotificationsFunction = @convention(c) (
      DispatchQueue
    ) -> Void
    let registerForNowPlayingNotifications = unsafeBitCast(
      registerForNotificationsPointer,
      to: RegisterForNotificationsFunction.self)

    // Register for "Now Playing" notifications.
    registerForNowPlayingNotifications(DispatchQueue.main)

    DispatchQueue.main.async {
      // Handle NowPlayingApplicationIsPlayingDidChange events.
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.refreshCurrentTrack),
        name: NSNotification.Name(
          "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"), object: nil)

      // Handle NowPlayingInfoDidChange events.
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.refreshCurrentTrack),
        name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"), object: nil)
    }
  }

  @objc func refreshCurrentTrack() {
    // Get a Swift function for MRMediaRemoteGetNowPlayingInfo.
    guard
      let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
        bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
    else { return }
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (
      DispatchQueue, @escaping ([String: Any]) -> Void
    ) -> Void
    let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
      MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

    // Get song info.
    MRMediaRemoteGetNowPlayingInfo(
      DispatchQueue.main, { (information) in
        var name: String?
        var artist: String?
        var playbackRate = 0.0

        if information["kMRMediaRemoteNowPlayingInfoArtist"] != nil {
          if let info = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
            artist = info
          }
          if let info = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
            name = info
          }
          if let info = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
            playbackRate = info
          }
        }

        self.objectWillChange.send()
        self.currentTrack = TrackInfo(name: name, artist: artist, playing: playbackRate != 0.0)
      }
    )
  }
}
