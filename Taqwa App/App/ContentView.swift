import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            LoadingView {
                PrayerTimesView()
            }
        }
    }
}
