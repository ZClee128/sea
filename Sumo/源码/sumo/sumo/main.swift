import UIKit

// True UIKit entry point — AppDelegate is the real host.
// This lets us fully control audio session lifecycle in AppDelegate.
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
