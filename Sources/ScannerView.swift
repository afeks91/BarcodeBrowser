import Foundation
import AVFoundation
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        var onCodeScanned: ((String) -> Void)?

        private let session = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black

            guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput(device: videoDevice) else { return }

            if session.canAddInput(input) { session.addInput(input) }

            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.code128]
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.layer.bounds
            view.layer.addSublayer(preview)
            self.previewLayer = preview

            let guide = UIView()
            guide.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
            guide.layer.borderWidth = 2
            guide.layer.cornerRadius = 8
            guide.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(guide)

            NSLayoutConstraint.activate([
                guide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                guide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                guide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                guide.heightAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.35)
            ])

            session.startRunning()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.layer.bounds
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .code128,
                  let value = object.stringValue else { return }

            if session.isRunning { session.stopRunning() }
            onCodeScanned?(value)
        }
    }
}
