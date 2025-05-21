import SwiftUI

struct contentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ScannerView()
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
        }
    }
}
