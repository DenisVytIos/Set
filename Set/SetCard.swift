//
//  SetCard.swift
//  Set
//
//  Created by Denis on 09.02.2019.
//  Copyright © 2019 Denis Vitrishko. All rights reserved.
//

import Foundation

struct SetCard: Equatable, CustomStringConvertible {
    
    static func == (lhs: SetCard, rhs: SetCard) -> Bool{
        return ((lhs.number == rhs.number) &&
                (lhs.shape == rhs.shape) &&
                (lhs.color == rhs.color) &&
                (lhs.fill == rhs.fill)
        )
    }
    
    var description: String{return "\(number)-\(shape)\(color)-\(fill)-"}
    
    let number: Variant
    let shape: Variant
    let color: Variant
    let fill: Variant
    
    enum Variant: Int, CustomStringConvertible{
        
        var description: String{return String(self.rawValue)}
        
        case variant1 = 1
        case variant2
        case variant3
        
        static var all: [Variant] {return [.variant1,.variant2,.variant3]}
        var idx: Int {return (self.rawValue - 1)}
        
    }
    
    static func isSet(cards:[SetCard]) -> Bool{
        guard cards.count == 3 else {return false}
        let sum = [
            cards.reduce(0, {$0 + $1.number.rawValue}),
            cards.reduce(0, {$0 + $1.color.rawValue}),
            cards.reduce(0, {$0 + $1.shape.rawValue}),
            cards.reduce(0, {$0 + $1.fill.rawValue}),
            ]
            return sum.reduce(true, { $0 && ($1 % 3 == 0) })
         }
}
