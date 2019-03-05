//
//  BoardView.swift
//  Set
//
//  Created by Denis on 03.03.2019.
//  Copyright © 2019 Denis Vitrishko. All rights reserved.
//

import UIKit

class BoardView: UIView {

    var cardViews = [SetCardView](){
        willSet { removeSubview() }
        didSet { addSubviews(); setNeedsLayout()}
    }
    private func removeSubview() {
        for card in cardViews {
            card.removeFromSuperview()
        }
    }
    private func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        var grid = Grid(
            layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio),
            frame: bounds)
        grid.cellCount = cardViews.count
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if cardViews.count > (row * grid.dimensions.columnCount + column) {
                    
                    cardViews[row * grid.dimensions.columnCount + column].frame = grid[row,column]!.insetBy(
                        dx: Constant.spacingDx, dy: Constant.spacingDy)
                }
            }
        }
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let spacingDx: CGFloat  = 3.0
        static let spacingDy: CGFloat  = 3.0
    }
}
