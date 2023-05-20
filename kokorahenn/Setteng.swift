import SwiftUI

struct SettingsView: View {
    // 検索範囲関連の変数は削除

    let appVersion = "1.0.0"
    let twitterURL = "https://twitter.com/gadgelogger"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("製作者")) {
                    Link("Twitter: @gadgelogger", destination: URL(string: twitterURL)!)
                }

                Section(header: Text("アプリ情報")) {
                    Text("バージョン: \(appVersion)")
                }
            }
            .navigationBarTitle("設定")
        }
    }
}
