//
//  BottomNavigationBarView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct BottomNavigationBarView: View {
    var body: some View {
        HStack {
            Spacer()
            navItem(icon: "sun.max", label: "Prayer", isSelected: true)
            Spacer()
            navItem(icon: "location.north.line", label: "Qibla")
            Spacer()
            navItem(icon: "chart.bar", label: "Tracker")
            Spacer()
            navItem(icon: "gear", label: "Settings")
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: -2)
        )
    }

    private func navItem(icon: String, label: String, isSelected: Bool = false) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .blue : .gray)
            Text(label)
                .font(.footnote)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}
