import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    var content: Content
    var onRefresh: () -> Void
    
    init(onRefresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var refreshableScrollView: RefreshableScrollView
        
        init(_ refreshableScrollView: RefreshableScrollView) {
            self.refreshableScrollView = refreshableScrollView
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            refreshableScrollView.onRefresh()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sender.endRefreshing()
            }
        }
    }
}
