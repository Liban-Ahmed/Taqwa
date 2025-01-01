//
//  HomeView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .prayer

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .prayer:
                PrayerTimesView() // the existing view for prayer times
            case .qibla:
                QiblaView() // the new Qibla direction view
            case .tracker:
                Text("Tracker View (Placeholder)")
            case .settings:
                Text("Settings View (Placeholder)")
            }

            BottomNavigationBarView(selectedTab: $selectedTab)
        }
    }
}
