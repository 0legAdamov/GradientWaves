//
//  GradientWave.swift
//  GradientWaves
//
//  Created by Oleg Adamov on 05.12.2017
//  Copyright © 2017 AdamovOleg. All rights reserved.
//

import UIKit


enum GradientWaveDirection {
    case left
    case right
}


private enum GradientWaveAnimation {
    case increase
    case decrease
    case none
}


class GradientWave: UIView {
    
    // constants
    var animationDuration: Double = 4.0
    var phaseShift: CGFloat = -0.02
    var primaryLineWidth: CGFloat = 3.0
    var frequency: CGFloat = 1.2
    var amplitude: CGFloat = 0.95
    var density: CGFloat = 5.0
    
    var percents: Int {
        get { return Int(round(self.percentsValue)) }
        set { animatePercentes(to: newValue) }
    }
    
    
    init(center: CGPoint, direction: GradientWaveDirection, maskImagename: String, startColor: UIColor, endColor: UIColor) {
        self.waveDirection = direction
        self.startColor = startColor
        self.endColor = endColor
        
        let maskImage = UIImage(named: maskImagename)!
        super.init(frame: CGRect(origin: .zero, size: maskImage.size))
        self.center = center
        
        self.layer.mask = UIImageView(image: maskImage).layer
        self.backgroundColor = .clear
    }
    
    
    func start() {
        self.displayLink.add(to: .main, forMode: .commonModes)
    }
    
    
    //MARK: Private
    
    private let displayLink = CADisplayLink(target: self, selector: #selector(update))
    private let waveDirection: GradientWaveDirection
    
    private var endAnimationTime:   CFTimeInterval = 0
    private var startAnimationTime: CFTimeInterval = 0
    private var animationType: GradientWaveAnimation = .none
    
    private var percentsValue:    CGFloat = 0
    private var newPercentsValue: CGFloat = 0
    
    private var currentPhase: CGFloat = 0
    
    private let startColor: UIColor
    private let endColor:   UIColor
    
    private lazy var gradient: CGGradient = {
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [startColor, endColor] as CFArray, locations: [0.0, 0.85])!
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func animatePercentes(to newValue: Int) {
        var value = CGFloat(newValue)
        if value > 100 { value = 100 } else if value < 0 { value = 0 }
        self.newPercentsValue = value
        
        self.startAnimationTime = self.displayLink.timestamp
        self.endAnimationTime = self.startAnimationTime + self.animationDuration
        
        if value > self.percentsValue {
            self.animationType = .increase
        }
        else if value < self.percentsValue {
            self.animationType = .decrease
        }
    }
    
    
    @objc private func update() {
        defer {
            setNeedsDisplay()
        }
        let shift = self.animationType == .none ? self.phaseShift : (self.phaseShift * 2.4)
        self.currentPhase += self.waveDirection == .left ? shift : (-shift)
        
        guard self.animationType != .none else { return }
        
        let time = self.displayLink.timestamp
        let delta = (time - self.startAnimationTime) / (self.endAnimationTime - self.startAnimationTime)
        guard delta > 0 else {
            self.percentsValue = self.newPercentsValue
            self.animationType = .none
            return
        }
        
        let step = CGFloat(Double(self.newPercentsValue - self.percentsValue) * delta)
        self.percentsValue += step
        
        if self.animationType == .increase && self.percentsValue >= self.newPercentsValue {
            self.percentsValue = self.newPercentsValue
            self.animationType = .none
        }
        else if self.animationType == .decrease && self.percentsValue <= self.newPercentsValue {
            self.percentsValue = self.newPercentsValue
            self.animationType = .none
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(self.bounds)
        
        UIColor.clear.set()
        
        let wave = createWavePath()
        wave.addClip()
        
        let midX = self.bounds.midX
        context?.drawLinearGradient(self.gradient, start: CGPoint(x: midX, y: 0), end: CGPoint(x: midX, y: 0), options: CGGradientDrawingOptions())
    }
    
    
    private func createWavePath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = self.primaryLineWidth
        
        let midY = self.bounds.midY
        let width = self.bounds.width
        let midX = self.bounds.midX
        let maxAmplitude = max(midY / 10 - 4, 2 * self.primaryLineWidth)
        
        var x: CGFloat = 0
        while x < (width + self.density) {
            let scaling = -pow(1 / midX * (x - midX), 2) + 1
            let fx = CGFloat(2.0 * Double.pi) * (x / width) * self.frequency + self.currentPhase
            let f = self.waveDirection == .left ? sin(fx) : cos(fx)
            let y = scaling * maxAmplitude * self.amplitude * f + self.bounds.height * CGFloat(100 - self.percentsValue) / CGFloat(100)
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            x += self.density
        }
        
        path.addLine(to: CGPoint(x: width, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.height))
        path.close()
        path.fill()
        
        return path
    }
}
