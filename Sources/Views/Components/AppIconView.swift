import SwiftUI

struct AppIconView: View {
    var body: some View {
        if let icon = ResourceLoader.loadAppIcon() {
            Image(nsImage: icon)
                .resizable()
                .frame(width: UIConstants.appIconSize, height: UIConstants.appIconSize)
        } else {
            Image(systemName: "moon.circle.fill")
                .resizable()
                .frame(width: UIConstants.appIconSize, height: UIConstants.appIconSize)
                .foregroundStyle(.blue)
        }
    }
}
