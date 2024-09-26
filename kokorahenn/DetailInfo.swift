import SwiftUI

struct DetailInfo: View {
    let icon: String
    let info: String
    let text: String

    var body: some View {
        VStack {
            HStack {
                Label(info, systemImage: icon)
                Spacer()
                Text(text)
                    .multilineTextAlignment(.trailing)
            }
            Divider()
        }
        .padding(.vertical, 8)
    }
}