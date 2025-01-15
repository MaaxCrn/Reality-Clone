import Flutter
import UIKit
import AVFoundation

public class SwiftMyCustomPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "my_custom_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftMyCustomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getFOV" {
            result(getFov())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func getFocalLength() -> Double {
        let device = AVCaptureDevice.default(for: .video)
        guard let camera = device else { return 0.0 }
        let focalLength = camera.lensPosition
        return focalLength
    }
}
