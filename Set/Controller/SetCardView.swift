//
//  SetCardView.swift
//  Set
//
//  Created by Denis on 03.03.2019.
//  Copyright © 2019 Denis Vitrishko. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    @IBInspectable
    var faceBackgroundColor: UIColor = UIColor.white { didSet { setNeedsDisplay()} }
    
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var isSelected:Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isMatched: Bool? { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var symbolInt: Int = 1 { didSet {
        switch symbolInt {
        case 1: symbol = .squiggle
        case 2: symbol = .oval
        case 3: symbol = .diamond
        default: break
        }
        }}
    @IBInspectable
    var fillInt: Int = 1 { didSet {
        switch fillInt {
        case 1: fill = .empty
        case 2: fill = .stripes
        case 3: fill = .solid
        default: break
        }
        }}
    @IBInspectable
    var colorInt: Int = 1 { didSet {
        switch colorInt {
        case 1: color = Colors.green
        case 2: color = Colors.red
        case 3: color = Colors.purple
        default: break
        }
        }}
    
    @IBInspectable
    var count: Int = 1 {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    private var color = Colors.red {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }
    private var fill = Fill.stripes {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }
    private var symbol = Symbol.squiggle {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }
    
    private enum Symbol: Int {
        case diamond
        case squiggle
        case oval
    }
    
    private enum Fill: Int {
        case empty
        case stripes
        case solid
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds,
                                       cornerRadius: cornerRadius)
        faceBackgroundColor.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            drawPips()
        } else {
            //         drawBack()
            
            if let cardBackImage = UIImage(named: "card-back",
                                           in: Bundle(for: self.classForCoder),
                                           compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
            
        }
    }
    
    private func drawBack() {
        UIColor.green.setFill()
        let font = UIFont(name: "Party LET", size: backFontsize)!
        let attr: [NSAttributedStringKey : Any] = [
            .font : font,
            ]
        let text = NSAttributedString(string: "K", attributes: attr)
        text.draw(at: CGPoint.zero)
    }
    
    private func drawPips(){
        color.setFill()
        color.setStroke()
        
        switch count {
        case 1:
            let origin = CGPoint(x: faceFrame.minX, y: faceFrame.midY - pipHeight/2)
            let size = CGSize(width: faceFrame.width, height: pipHeight)
            let firstRect = CGRect(origin: origin, size: size)
            drawShape(in: firstRect)
            
        case 2:
            let origin = CGPoint(x: faceFrame.minX, y: faceFrame.midY - interPipHeight/2 - pipHeight)
            let size = CGSize(width: faceFrame.width, height: pipHeight)
            let firstRect = CGRect(origin: origin, size: size)
            drawShape(in: firstRect)
            let secondRect = firstRect.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: secondRect)
            
        case 3:
            let origin = CGPoint (x: faceFrame.minX, y: faceFrame.minY)
            let size = CGSize(width: faceFrame.width, height: pipHeight)
            let firstRect = CGRect(origin: origin, size: size)
            drawShape(in: firstRect)
            let secondRect = firstRect.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: secondRect)
            let thirdRect = secondRect.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: thirdRect)
        default: break
        }
    }
    
    private func drawShape(in rect: CGRect) {
        let path: UIBezierPath
        switch symbol {
        case .diamond:
            path = pathForDiamond(in: rect)
        case .oval:
            path = pathForOval(in: rect)
        case .squiggle:
            path = pathForSquiggle(in: rect)
        }
        
        path.lineWidth = 3.0
        path.stroke()
        switch fill {
        case .solid:
            path.fill()
        case .stripes:
            stripeShape(path: path, in: rect)
        default:
            break
        }
    }
    
    private func stripeShape(path: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        stripeRect(rect)
        context?.restoreGState()
    }
    
    private func pathForSquiggle(in rect: CGRect) -> UIBezierPath {
        let upperSquiggle = UIBezierPath()
        let sqdx = rect.width * 0.1
        let sqdy = rect.height * 0.2
        upperSquiggle.move(to: CGPoint(x: rect.minX,
                                       y: rect.midY))
        upperSquiggle.addCurve(to:
            CGPoint(x: rect.minX + rect.width * 1/2,
                    y: rect.minY + rect.height / 8),
                               controlPoint1: CGPoint(x: rect.minX,
                                                      y: rect.minY),
                               controlPoint2: CGPoint(x: rect.minX + rect.width * 1/2 - sqdx,
                                                      y: rect.minY + rect.height / 8 - sqdy))
        upperSquiggle.addCurve(to:
            CGPoint(x: rect.minX + rect.width * 4/5,
                    y: rect.minY + rect.height / 8),
                               controlPoint1: CGPoint(x: rect.minX + rect.width * 1/2 + sqdx,
                                                      y: rect.minY + rect.height / 8 + sqdy),
                               controlPoint2: CGPoint(x: rect.minX + rect.width * 4/5 - sqdx,
                                                      y: rect.minY + rect.height / 8 + sqdy))
        
        upperSquiggle.addCurve(to:
            CGPoint(x: rect.minX + rect.width,
                    y: rect.minY + rect.height / 2),
                               controlPoint1: CGPoint(x: rect.minX + rect.width * 4/5 + sqdx,
                                                      y: rect.minY + rect.height / 8 - sqdy ),
                               controlPoint2: CGPoint(x: rect.minX + rect.width,
                                                      y: rect.minY))
        
        let lowerSquiggle = UIBezierPath(cgPath: upperSquiggle.cgPath)
        lowerSquiggle.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        lowerSquiggle.apply(CGAffineTransform.identity
            .translatedBy(x: bounds.width, y: bounds.height))
        upperSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        upperSquiggle.append(lowerSquiggle)
        return upperSquiggle
    }
    
    private func pathForOval(in rect: CGRect) -> UIBezierPath {
        let oval = UIBezierPath()
        let radius = rect.height / 2
        oval.addArc(withCenter: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                    radius: radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2, clockwise: true)
        oval.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        oval.addArc(withCenter: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius, startAngle: CGFloat.pi*3/2, endAngle: CGFloat.pi/2, clockwise: true)
        oval.close()
        return oval
    }
    
    private func pathForDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: rect.minX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.close()
        return diamond
    }
    
    private func stripeRect(_ rect: CGRect) {
        //------- classic method
        let stripe = UIBezierPath()
        stripe.lineWidth = 1.0
        stripe.move(to: CGPoint(x: rect.minX, y: bounds.minY ))
        stripe.addLine(to: CGPoint(x: rect.minX, y: bounds.maxY))
        let stripeCount = Int(faceFrame.width / interStripeSpace)
        for _ in 1...stripeCount {
            let translation = CGAffineTransform(translationX: interStripeSpace, y: 0)
            stripe.apply(translation)
            stripe.stroke()
        }
        /*
         //---- dash line
         let stripe = UIBezierPath()
         let  dashes: [ CGFloat ] = [ 1,4 ]
         stripe.setLineDash(dashes, count: dashes.count, phase: 0.0)
         
         stripe.lineWidth = bounds.size.height
         stripe.lineCapStyle = .butt
         stripe.move(to: CGPoint(x: bounds.minX, y: bounds.midY ))
         stripe.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
         stripe.stroke()
         */
    }
    
    private func configureState() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        isOpaque = false
        contentMode = .redraw
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        if isSelected {          // highlight selected card view
            pinLabel.isHidden = false
            layer.borderColor = Colors.selected
        }  else {
            pinLabel.isHidden = true
        }
        if let matched = isMatched { // highlight matched 3 cards
            pinLabel.isHidden = false
            if matched {
                layer.borderColor = Colors.matched
            } else {
                layer.borderColor = Colors.misMatched
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configurePinLabel(pinLabel)
        let pinOffSet = SizeRatio.pinOffset
        pinLabel.frame.origin = bounds.origin.offsetBy(dx: bounds.size.width * pinOffSet,
                                                       dy: bounds.size.height * pinOffSet)
        configureState()
    }
    
    func hint() {
        layer.borderWidth = borderWidth
        layer.borderColor = Colors.hint
    }
    
    // MARK: - Pin
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    private var pinString: NSAttributedString {
        return centeredAttributedString("📌", fontSize: pinFontSize)
    }
    
    private lazy var pinLabel = createPinLabel()
    
    private func createPinLabel() -> UILabel {
        let label = UILabel()
        addSubview(label)
        return label
    }
    
    private func configurePinLabel(_ label: UILabel) {
        label.attributedText = pinString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = true
    }
    
    func copyCard() -> SetCardView {
        let copy = SetCardView()
        copy.symbolInt =  symbolInt
        copy.fillInt = fillInt
        copy.colorInt = colorInt
        copy.count =  count
        copy.isSelected =  false
        
        copy.isFaceUp = true
        copy.bounds = bounds
        copy.frame = frame
        copy.alpha = 1
        return copy
    }
    
    // MARK: Deal a card animation
    
    func animateDeal(from deckCenter: CGPoint, delay: TimeInterval) {
        let currentCenter = center
        let currentBounds = bounds
        
        center =  deckCenter
        alpha = 1
        bounds = CGRect(x: 0.0, y: 0.0, width: 0.6 * bounds.width,
                        height: 0.6 * bounds.height)
        isFaceUp = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: delay,
            options: [],
            animations:
            {
                self.center = currentCenter
                self.bounds = currentBounds
        },
            completion:
            { position in
                UIView.transition(
                    with: self,
                    duration: 0.3,
                    options: [.transitionFlipFromLeft],
                    animations:
                    {
                        self.isFaceUp = true
                }
                )
        }
        )
    }
    
    // MARK: Fly a card animation
    
    var addDiscardPile : (() -> Void)?
    
    func animateFly(to discardPileCenter: CGPoint, delay: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: delay,
            options: [],
            animations:
            {
                self.center = discardPileCenter
        },
            completion:
            { position in
                UIView.transition(
                    with: self,
                    duration: 0.75,
                    options: [.transitionFlipFromLeft],
                    animations:
                    {
                        self.isFaceUp = false
                        self.transform = CGAffineTransform.identity
                            .rotated(by: CGFloat.pi / 2.0)
                        self.bounds = CGRect(x: 0.0, y: 0.0,
                                             width: 0.7*self.bounds.width,
                                             height: 0.7*self.bounds.height)
                },
                    completion:
                    { finished in
                        self.addDiscardPile?()
                }
                )
        }
        )
    }
    
    private struct Colors {
        static let green = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        static let red = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let purple = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
        
        static let selected = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).cgColor
        static let matched = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1).cgColor
        static var misMatched = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        static let hint = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1).cgColor
    }
    
    private struct SizeRatio {
        static let pinFontSizeToBoundsHeight: CGFloat = 0.09
        static let maxFaceSizeToBoundsSize: CGFloat = 0.75
        static let pipHeightToFaceHeight: CGFloat = 0.25
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let pinOffset: CGFloat = 0.03
        static let backTextFontsizeToBoundsWidth: CGFloat = 1.4
    }
    
    private struct AspectRatio {
        static let faceFrame: CGFloat = 0.60
    }
    
    private var maxFaceFrame: CGRect {
        return bounds.zoomed(by: SizeRatio.maxFaceSizeToBoundsSize)
    }
    
    private var faceFrame: CGRect {
        let faceWidth = maxFaceFrame.height * AspectRatio.faceFrame
        return maxFaceFrame.insetBy(dx: (maxFaceFrame.width - faceWidth)/2, dy: 0)
    }
    
    private var pipHeight: CGFloat {
        return faceFrame.height * SizeRatio.pipHeightToFaceHeight
    }
    
    private var pinFontSize: CGFloat {
        return bounds.size.height * SizeRatio.pinFontSizeToBoundsHeight
    }
    
    private var interPipHeight: CGFloat {
        return (faceFrame.height - (3 * pipHeight)) / 2
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var backFontsize: CGFloat {
        return bounds.width * SizeRatio.backTextFontsizeToBoundsWidth
    }
    
    private let interStripeSpace: CGFloat = 5.0
    private let borderWidth: CGFloat = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        isOpaque = false
        alpha = 0
    }
}

extension CGRect {
    func zoomed(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
