import SwiftUI
import SafariServices

struct ContentView: View {
    @State private var scannedCode: String? = nil
    @State private var showBrowser: Bool = false
    @State private var browserURL: URL? = nil

    var body: some View {
        ZStack {
            ScannerView(onCodeScanned: { code in
                guard scannedCode == nil else { return }
                scannedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
                if let encoded = scannedCode?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "https://tirparts.com.ua/ua?q=" + encoded) {
                    browserURL = url
                    showBrowser = true
                }
            })
            .ignoresSafeArea()

            VStack {
                Spacer()
                if let code = scannedCode {
                    Text("Считано: \(code)")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.bottom, 24)
                } else {
                    Text("Наведите камеру на штрихкод (Code 128)")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showBrowser, onDismiss: {
            scannedCode = nil
        }) {
            if let url = browserURL {
                SafariView(url: url)
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        return SFSafariViewController(url: url, configuration: config)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
