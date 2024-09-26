import SwiftUI

struct PlaceDetailsView: View {
    let place: Place
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: place.photo.pc.l)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(10)
                .padding(5)
                Divider()
                
                HStack(spacing: 20) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "phone")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    Button(action: {
                    }) {
                        Image(systemName: "map")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
               
                    Button(action: {
                    
                    }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.top)
                .padding(.bottom)
                
                
                Text(place.name)
                    .font(.title)
                    .padding()
                
                Text(place.address)
                    .font(.subheadline)
                    .padding()
                
                Text(place.catchCopy)
                    .font(.body)
                    .padding()
                
                Link("店舗URL", destination: URL(string: place.urls.pc)!)
                    .padding()
            }
        }
        .navigationBarTitle(place.name, displayMode: .inline)
    }
}
