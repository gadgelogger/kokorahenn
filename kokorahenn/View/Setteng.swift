import SwiftUI

struct SettingsView: View {
    // 検索範囲関連の変数は削除
    @AppStorage("isDarkMode") private var isDarkMode = false

    let appVersion = "1.1"
    let twitterURL = "https://twitter.com/gadgelogger"
    let terms = "https://gadgelogger.com/kokorahenn/"
    let review = "https://apps.apple.com/jp/app/%E3%81%93%E3%81%93%E3%82%89%E3%81%B8%E3%82%93/id6448917866?action=write-review"
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("設定")) {
                                 Toggle(isOn: $isDarkMode, label: {
                                     HStack {
                                                                Image(systemName: "moon.circle") // ここでアイコンを設定
                                                                Text("テーマ切り替え")
                                                            }                                 })
                                 .onChange(of: isDarkMode) { value in
                                     // ユーザーがダークモードを切り替えた場合の処理を記述します。
                                     // ここではシステムの外観を切り替えます。
                                     UIApplication.shared.windows.first?.overrideUserInterfaceStyle = value ? .dark : .light
                                 }
                             }
                Section(header:Text("その他")) {
                    
                    
                
                    
                    Button(action: {
                        shareApp(shareText: "シェアあざっす！", shareImage: Image("icon"), shareLink: "https://apps.apple.com/jp/app/%E3%81%93%E3%81%93%E3%82%89%E3%81%B8%E3%82%93/id6448917866")
                    }) {
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("シェアする")
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // ボタンのスタイルをプレーンに設定
                    
                    HStack{
                        Image(systemName: "pencil.circle")
                        Link("このアプリを評価する", destination: URL(string: review)!)

                    }
                    HStack{
                        Image(systemName: "hand.raised.circle")
                        Link("プライバシーポリシー", destination: URL(string: terms)!)

                    }
                    HStack{
                        Image(systemName: "info.circle")
                        Link("お問い合わせはこちら（Twitter）", destination: URL(string: twitterURL)!)

                    }
                    HStack{
                        Image(systemName: "terminal")
                        Text("バージョン: \(appVersion)")

                    }

                }

             
            }
            .navigationBarTitle("設定")
        }.navigationViewStyle(.stack)
    }
}

struct Previews_Setteng_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
//シェア
func shareApp(shareText: String, shareImage: Image, shareLink: String) {
    let items = [shareText, shareImage, URL(string: shareLink)!] as [Any]
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let rootVC = windowScene?.windows.first?.rootViewController
    rootVC?.present(activityVC, animated: true,completion: {})
}
