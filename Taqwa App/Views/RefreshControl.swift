//
//  RefreshControl.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct RefreshControl: View {
    let coordinateSpace: CoordinateSpace
    let onRefresh: () -> Void

    @State private var isRefreshing: Bool = false

    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        if !isRefreshing {
                            isRefreshing = true
                            onRefresh()
                        }
                    }
            } else if geo.frame(in: coordinateSpace).midY < 1 {
                Spacer()
                    .onAppear {
                        isRefreshing = false
                    }
            }
            ZStack(alignment: .center) {
                if isRefreshing {
                    ProgressView()
                }
            }
            .frame(width: geo.size.width)
        }
        .padding(.top, -50)
    }
}
