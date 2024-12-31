//
//  TreeViews.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//
//
//import SwiftUI
//
//struct PineTreeGroup: View {
//    var body: some View {
//        HStack(spacing: 32) {
//            ForEach(0..<5) { i in
//                PineTreeView(scale: i.isMultiple(of: 2) ? 1.0 : 0.8)
//            }
//        }
//    }
//}
//
//struct PineTreeView: View {
//    let scale: CGFloat
//    @State private var sway: Bool = false
//
//    var body: some View {
//        ZStack {
//            // Trunk
//            Rectangle()
//                .fill(Color.brown)
//                .frame(width: 4, height: 24)
//                .offset(y: 12)
//
//            // Pine shape: stacked triangles
//            VStack(spacing: -6) {
//                Triangle()
//                    .fill(Color.green.opacity(0.85))
//                    .frame(width: 28, height: 20)
//                Triangle()
//                    .fill(Color.green.opacity(0.85))
//                    .frame(width: 22, height: 16)
//                Triangle()
//                    .fill(Color.green.opacity(0.85))
//                    .frame(width: 16, height: 12)
//            }
//            .offset(y: -6)
//        }
//        .rotationEffect(.degrees(sway ? 0.5 : -0.5), anchor: .bottom)
//        .scaleEffect(sway ? scale * 1.01 : scale * 0.99, anchor: .bottom)
//        .onAppear {
//            sway = true
//        }
//    }
//}
//
//struct Triangle: Shape {
//    func path(in rect: CGRect) -> Path {
//        Path { path in
//            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//            path.closeSubpath()
//        }
//    }
//}
