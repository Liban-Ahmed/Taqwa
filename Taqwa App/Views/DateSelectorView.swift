//
//  DateSelectorView.swift.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import SwiftUI

struct DateSelectorView: View {
    let selectedDate: Date
    let hijriDate: String
    let onPreviousDate: () -> Void
    let onNextDate: () -> Void

    var body: some View {
        HStack {
            Button(action: onPreviousDate) {
                Image(systemName: "chevron.left")
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            Spacer()
            VStack(spacing: 4) {
                Text(selectedDate, formatter: Self.dateFormatter)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(hijriDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onNextDate) {
                Image(systemName: "chevron.right")
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

