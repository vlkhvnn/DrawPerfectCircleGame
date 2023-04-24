//
//  ContentView.swift
//  Incubator
//
//  Created by Alikhan Tangirbergen on 21.04.2023.
//

import SwiftUI
import CoreGraphics
import Combine

struct Line {
    var points : [CGPoint]
    var colors : [Color]
    var lineWidth : CGFloat
    let id = UUID()
}

struct ContentView: View {
    @State private var line: Line?
    @State private var selectedLineWidth: CGFloat = 1
    @State private var selectedColor: Color = .green
    @State private var center = CGPoint(x: 0, y: 0)
    @State private var percentage : CGFloat = 0
    @State private var radius : CGFloat = 100
    @State private var maxResult : CGFloat = 0.0
    @State private var stoppedDrawing : Bool = false
    @State private var showWrongWayAlert : Bool = false
    @State private var showMinDistanceAlert : Bool = false
    @State private var FirstPoint = CGPoint(x: 0, y: 0)
    @State private var CurrentPoint = CGPoint(x: 0, y: 0)
    @State private var CompletedCircle = false
    @State private var MovedToNextQuad = false
    @State private var IncompleteCircle = false
    @State private var isShowingTooSlowAlert = false
    @State var timer = Timer.publish(every: 100, on: .main, in: .common).autoconnect()
    
    let engine = DrawingEngine()
    var body: some View {
        ZStack {
            VStack {
                topview
                Spacer()
                GeometryReader { geometry in
                    ZStack {
                        circleAtCenter
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .onAppear {
                                center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            }
                        Canvas { context, size in
                            if let line = line {
                                var path = engine.createPath(for: line.points)
                                path.addLines(line.points)
                                context.stroke(
                                    path,
                                    with: .linearGradient(
                                        .init(colors: line.colors),
                                        startPoint: line.points.first ?? .zero,
                                        endPoint: line.points.last ?? .zero
                                    ),
                                    lineWidth: line.lineWidth
                                )
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged({ value in
                                    showMinDistanceAlert = false
                                    stoppedDrawing = false
                                    CurrentPoint = value.location
                                    if value.translation.width + value.translation.height == 0 {
                                        timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
                                        MovedToNextQuad = false
                                        FirstPoint = CurrentPoint
                                        percentage = 0
                                        line = Line(points: [CurrentPoint], colors: [selectedColor], lineWidth: selectedLineWidth)
                                        radius = DistanceBetweenTwoPoints(from: center, to: CurrentPoint)
                                        showWrongWayAlert = false
                                        if(CheckForMinDistance(point: CurrentPoint, center: center)) {
                                            showMinDistanceAlert = true
                                        }
                                    }
                                    else {
                                        line?.points.append(CurrentPoint)
                                        percentage = 100 - FindStandardDeviation(line: line!, radius: radius, center: center)
                                        line?.colors.append(getColor(percentage: percentage))
                                        if MovedToNextQuadrant(point: CurrentPoint, FirstPoint: FirstPoint, center: center) {
                                            MovedToNextQuad = true
                                        }
                                        if (abs(CurrentPoint.y - FirstPoint.y) < 10) && MovedToNextQuad && CheckInTheSameQuadrant(point: CurrentPoint, FirstPoint: FirstPoint, center: center ){
                                            CompletedCircle = true
                                        }
                                        if CheckForWrongWay(line: line!, radius: radius, center: center) {
                                            showWrongWayAlert = true
                                        }
                                        if(CheckForMinDistance(point: CurrentPoint, center: center)) {
                                            showMinDistanceAlert = true
                                        }
                                    }
                                })
                                .onEnded({ value in
                                    stoppedDrawing = true
                                    IncompleteCircle = true
                                }))
                    }
                    .disabled(CompletedCircle)
                    .alert("Too close to the center!", isPresented: $showMinDistanceAlert) {
                        Button("Okay", role: .cancel) {
                            IncompleteCircle = false
                        }
                    }
                    .alert("Wrong Way!", isPresented: $showWrongWayAlert) {
                        Button("Okay", role: .cancel) {
                            IncompleteCircle = false
                        }
                    }
                }
                
            }
            .opacity(CompletedCircle || IncompleteCircle ? 0 : 1)
            if CompletedCircle {
                Button {
                    CompletedCircle = false
                    stoppedDrawing = true
                    if maxResult < percentage {
                        maxResult = percentage
                    }
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .opacity(0)
                }
                Text("Great, you did a circle. Now tap one time to see it!")
            }
            if IncompleteCircle {
                Button {
                    IncompleteCircle = false
                    stoppedDrawing = true
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .opacity(0)
                }
                Text("Incomplete Circle!")
            }
        }
        .onAppear {
            if let savedMaxResult = UserDefaults.standard.value(forKey: "MaxResult") as? CGFloat {
                maxResult = savedMaxResult
            }
        }
        .onDisappear {
            UserDefaults.standard.set(maxResult, forKey: "MaxResult")
        }
        .onReceive(timer) { _ in
            if !CompletedCircle && !IncompleteCircle && !showWrongWayAlert && !showMinDistanceAlert {
                isShowingTooSlowAlert = true
            }
        }
        .alert("Too slow!", isPresented: $isShowingTooSlowAlert) {
            Button("Okay", role: .cancel) {
                IncompleteCircle = false
                isShowingTooSlowAlert = false
            }
        }
    }
    var topview : some View {
        HStack {
            Text("Linewidth")
            Slider(value: $selectedLineWidth, in: 1...20) {
            }.frame(maxWidth: 300)
            Text(String(format: "%.0f", selectedLineWidth))
        }.padding(.horizontal)
    }
    
    var circleAtCenter : some View {
        VStack {
            Text(String(format: "%.2f", percentage) + "%")
            Circle()
                .foregroundColor(.black)
                .frame(width: 10)
            if stoppedDrawing {
                Text("Best is: \(maxResult)")
                    .font(.system(size: 12))
            } else {
                Text("Draw a full circle")
                    .font(.system(size: 12))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
