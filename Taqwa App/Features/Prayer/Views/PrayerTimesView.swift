//
//  PrayerTimesView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI
struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @State private var selectedTab: Tab = .prayer
    
    
    var body: some View {
            NavigationStack {
                ZStack {
                    // Background gradient at root level
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.10, blue: 0.30),
                            Color(red: 0.50, green: 0.25, blue: 0.60)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        switch selectedTab {
                        case .prayer:
                            VStack(spacing: 0) {
                                TopSectionView(
                                    currentPrayer: viewModel.currentPrayer,
                                    timeRemaining: viewModel.timeRemaining
                                )
                                .padding(.top, 1)
                                
                                GridLayoutView(selectedTab: $selectedTab)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                    .padding(.bottom, 30)
                                    
                                Spacer()
                            }
                            
                        case .qibla:
                            QiblaView()
                            
                        case .tracker:
                            TrackerView()
                            
                        case .settings:
                            SettingsView()
                        }
                        
                        BottomNavigationBarView(selectedTab: $selectedTab)
                            .padding(.bottom, 8)
                    }
                }
            }
            .onAppear {
                viewModel.fetchPrayerTimes(for: Date())
            }
        }
    }
