import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager

    
    
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "fork.knife.circle")
                        Text("検索")
                    }
                }
                .tag(1)
                .environmentObject(locationManager)

         

            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "wrench.and.screwdriver")
                        Text("設定")
                    }
                }
                .tag(3)
        }
        .onAppear {
                    // タブバーに背景を付ける
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
        .accentColor(.orange)
        .background(Color(.black).edgesIgnoringSafeArea(.all))


    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
