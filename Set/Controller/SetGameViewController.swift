//
//  ViewController.swift
//  Set
//
//  Created by Denis on 09.02.2019.
//  Copyright © 2019 Denis Vitrishko. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    @IBOutlet weak var boardView: BoardView!{
        didSet{
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(deal3))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
  
    private var game = SetGame()

    var colors                 = [#colorLiteral(red: 1, green: 0.4163245823, blue: 0, alpha: 1), #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
    var strokeWidths:[CGFloat] = [ -10, 10, -10]
    var alphas:[CGFloat]       = [1.0, 0.60, 0.15]
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var iPhoneLabel: UILabel!
    
    @IBOutlet var cardButtons: [SetCardButton]! {
        didSet {
            for button in cardButtons{
                button.strokeWidths = strokeWidths
                button.colors       = colors
                button.alphas       = alphas
            }
        }
    }
    
    @IBOutlet weak var dealButton: BorderButton!
    @IBOutlet weak var newButton: BorderButton!
    @IBOutlet weak var hintButton: BorderButton!
    
    @IBAction func touchCard(_ sender: SetCardButton) {
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("choosen card was not in cardButtons")
        }
    }
    
    private func updateViewFromModel() {
        updateCardViewsFromModel()
    
        // update Buttons and Labels
        updateHintButton()
        deckCountLabel.text = "Deck: \(game.deckCount )"
        scoreLabel.text = "Score: \(game.score) / \(game.numberSets)"
        if let itIsSet = game.isSet {
            messageLabel.text = itIsSet ? "СОВПАДЕНИЕ" :"НЕСОВПАДЕНИЕ"
        } else {
            messageLabel.text = ""
        }
        dealButton.isHidden =  game.deckCount == 0
        hintButton.disable = game.hints.count == 0
    }
    
    private func updateHintButton() {
        hintButton.setTitle("\(game.hints.count ) sets", for: .normal)
        _lastHint = 0
    }
    private func updateCardViewsFromModel(){
        // удаляем лишние карты из boardView
        if boardView.cardViews.count - game.cardsOnTable.count > 0{
            let cardViews = boardView.cardViews [..<game.cardsOnTable.count]//удаляем лишние cardViews
            boardView.cardViews = Array(cardViews)
        }
        let numberCardViews = boardView.cardViews.count
        
        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if index > (numberCardViews - 1){ // new card
                let cardView = SetCardView()// created new cardViews
                updateCardView(cardView,for: card)
                addTapGestureRecognizer(for: cardView) //added at new card gesture tap
                boardView.cardViews.append(cardView)
                
            } else {                                // old cards
                let cardView = boardView.cardViews [index]
                updateCardView(cardView,for: card)
            }
        }
    }
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        //created tap gesture
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: )))
        
        tap.numberOfTapsRequired    = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            //обработчик жеста tap определяет грвфическую карту cardView, на которую игрок тапнул, и сообщает об етом модели визывая ее метод
            if  let cardView = recognizer.view! as? SetCardView {
                game.chooseCard(at: boardView.cardViews.index(of: cardView)!)
            }
        default:
            break
        }
        updateViewFromModel()
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard){
        
//        Метод выполняет работу контроллера по синхронизации Model and View

        cardView.symbolInt  = card.shape.rawValue
        cardView.fillInt    = card.fill.rawValue
        cardView.colorInt   = card.color.rawValue
        cardView.count      = card.number.rawValue
        cardView.isSelected = game.cardsSelected.contains(card)
        
        if let itIsSet = game.isSet {
            if game.cardsTryMatched.contains(card) {
                cardView.isMatched = itIsSet
            }
        } else {
            cardView.isMatched = nil
        }
    }
    
    private func updateButtonsFromModel() {
        messageLabel.text = ""
        
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if index < game.cardsOnTable.count {
                //--------------------------------
                let card = game.cardsOnTable[index]
                button.setCard = card
                //-----------Selected----------------------
                button.setBorderColor(color:
                    game.cardsSelected.contains(card) ? Colors.selected : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
                //-----------TryMatched----------------------
                if let itIsSet = game.isSet {
                    if game.cardsTryMatched.contains(card) {
                        button.setBorderColor(color:
                            itIsSet ? Colors.matched: Colors.misMatched)
                    }
                    messageLabel.text = itIsSet ? "matched" : "mis matched"
                }
                //--------------------------------
            } else {
                button.setCard = nil
            }
        }
    }
    
    @IBAction func deal3() {
            game.deal3()
            updateViewFromModel()
    }
    
    private weak var timer: Timer?
    private var _lastHint = 0
    private let flashTime = 1.5
    
    @IBAction func hint() {
        timer?.invalidate()
        if  game.hints.count > 0 {
            game.hints[_lastHint].forEach { (idx) in
                boardView.cardViews[idx].hint()
            }
            messageLabel.text = "Set \(_lastHint + 1) Wait..."
            timer = Timer.scheduledTimer(withTimeInterval: flashTime,
                                         repeats: false) { [weak self] time in
                                            self?._lastHint =
                                                (self?._lastHint)!.incrementCicle(in:(self?.game.hints.count)!)
                                            self?.messageLabel.text = ""
                                            self?.updateCardViewsFromModel()
            }
        }
    }
    
    @IBAction func new() {
        game = SetGame()
        cardButtons.forEach { $0.setCard = nil }
        updateViewFromModel()
    }
    @objc
    func reshuffle(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default:
            break
        }
    }
    //     MARK:    ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        updateViewFromModel()
    }
}

extension SetGameViewController {
    //------------------ Constants -------------
    private struct Colors {
        static let hint       = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)
        static let selected   = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        static let matched    = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        static var misMatched = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    private struct Constants {
        static let flashTime = 1.5
    }
}

extension Int {
    func incrementCicle (in number: Int)-> Int {
        return (number - 1) > self ? self + 1: 0
    }
}
