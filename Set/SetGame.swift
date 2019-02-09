//
//  SetGame.swift
//  Set
//
//  Created by Denis on 09.02.2019.
//  Copyright © 2019 Denis Vitrishko. All rights reserved.
//

import Foundation

struct SetGame{

    private(set) var cardsOnTable    = [SetCard]()
    private(set) var cardsSelected   = [SetCard]()
    private(set) var cardsTryMatched = [SetCard]()
    private(set) var cardsRemoved    = [SetCard]()
    
    private var deck = SetCardDeck()
    var cardInDeckCount: Int {return deck.cards.count}
    
    private mutating func takeThreeCardFromDeck() -> [SetCard]?{
        var threeCard = [SetCard]()
        for _ in 0...2{
            if let card = deck.draw(){
                threeCard += [card]
            }else{
                return nil
            }
        }
        return threeCard
    }
    mutating func dealThreeCards(){
        if let dealThreeCards = takeThreeCardFromDeck(){
            cardsOnTable += dealThreeCards
        }
    }
    private mutating func replaceOrRemoveThreeCards(){
        if let take3Cards =  takeThreeCardFromDeck() {
            cardsOnTable.replace(elements: cardsTryMatched, with: take3Cards)
        } else {
            cardsOnTable.remove(elements: cardsTryMatched)
        }
        cardsRemoved += cardsTryMatched
        cardsTryMatched.removeAll()
    }
}

extension Array where Element : Equatable {
    /// переключаем присутствие элемента в массиве:
    /// если нет - включаем, если есть - удаляем
    mutating func inOut(element: Element){
        if let from = self.index(of:element)  {
            self.remove(at: from)
        } else {
            self.append(element)
        }
    }
    
    mutating func remove(elements: [Element]){
        /// Удаляем массив элементов из массива
        self = self.filter { !elements.contains($0) }
    }
    
    mutating func replace(elements: [Element], with new: [Element] ){
        /// Заменяем элементы массива на новые
        guard elements.count == new.count else {return}
        for idx in 0..<new.count {
            if let indexMatched = self.index(of: elements[idx]){
                self [indexMatched ] = new[idx]
            }
        }
    }
    
    func indices(of elements: [Element]) ->[Int]{
        guard self.count >= elements.count, elements.count > 0 else {return []}
        /// Ищем индексы элементов elements у себя - self
        return elements.map{self.index(of: $0)}.compactMap{$0}
    }
}

