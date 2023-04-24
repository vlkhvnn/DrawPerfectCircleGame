//
//  StandardDev.swift
//  Incubator
//
//  Created by Alikhan Tangirbergen on 21.04.2023.
//

import Foundation
import SwiftUI
enum GraphQuadrants {
    case one
    case two
    case three
    case four
}

func FindStandardDeviation(line : Line, radius : CGFloat, center : CGPoint) -> CGFloat {
    var sum : CGFloat = 0
    for point in line.points {
        let distance = DistanceBetweenTwoPoints(from: point, to: center)
        let deviation = distance - radius
        sum += deviation*deviation
    }
    return sqrt(sum/CGFloat(line.points.count))
}

func CheckInTheSameQuadrant(point : CGPoint, FirstPoint : CGPoint, center : CGPoint) -> Bool {
    let initialQuadrant = DetermineQuadrant(point: FirstPoint, center: center)
    let currQuadrant = DetermineQuadrant(point: point, center: center)
    if initialQuadrant == currQuadrant {
        return true
    }
    return false
}

func MovedToNextQuadrant(point : CGPoint, FirstPoint : CGPoint, center : CGPoint) -> Bool {
    let initialQuadrant = DetermineQuadrant(point: FirstPoint, center: center)
    let currQuadrant = DetermineQuadrant(point: point, center: center)
    if initialQuadrant == currQuadrant {
        return false
    }
    return true
}

func CheckForMinDistance(point : CGPoint, center : CGPoint) -> Bool {
    if DistanceBetweenTwoPoints(from: point, to: center) < 50 {
        return true
    }
    return false
}

func DetermineQuadrant(point : CGPoint, center : CGPoint) -> GraphQuadrants {
    if(point.x - center.x) > 0 {
        if (point.y - center.y) > 0 {
            return .one
        }
        return .four
    }
    if(point.y - center.y) > 0 {
        return .two
    }
    return .three
}

func CheckForWrongWay(line : Line, radius : CGFloat, center : CGPoint) -> Bool {
    for point in line.points {
        let distance = DistanceBetweenTwoPoints(from: point, to: center)
        if abs(distance - radius) > 35 {
            return true
        }
    }
    return false
}

func DistanceBetweenTwoPoints(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
}

func getColor(percentage: CGFloat) -> Color {
    switch percentage {
    case 98...100: return .green
    case 97...98: return .init(uiColor: .init(red: 169/255, green: 255/255, blue: 24/255, alpha: 1))
    case 96...97: return .init(uiColor: .init(red: 234/255, green: 255/255, blue: 16/255, alpha: 1))
    case 95...96: return .yellow
    case 94...95: return .orange
    default: return .red
    }
}
