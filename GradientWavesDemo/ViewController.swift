//
//  ViewController.swift
//  GradientWavesDemo
//
//  Created by Олег Адамов on 04.12.2017.
//  Copyright © 2017 Oleg Adamov. All rights reserved.
//

import UIKit


extension UIColor {
    
    class func fromRGB(r: Int, g: Int, b: Int, a: CGFloat? = nil) -> UIColor {
        let alpha = a ?? 1
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    var singleWaves = [GradientWave]()
    var doubleWaves = [GradientWavesView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x1 = 100
        let x2 = UIScreen.main.bounds.width - 100
        
        createOneWaveHeart(CGPoint(x: x1, y: 180))
        createOneWaveHeartWithStroke(CGPoint(x: x2, y: 180))
    }

    
    @IBAction func touchUpInside(_ sender: UISlider) {
        let value = Int(sender.value)
        singleWaves.forEach { $0.percents = value }
    }
    
    
    func createOneWaveHeart(_ center: CGPoint) {
        let view = GradientWave(center: center, direction: .left, maskImagename: "heart_mask",
                                startColor: .fromRGB(r: 255, g: 51, b: 186, a: 0.8), endColor: .fromRGB(r: 255, g: 237, b: 249, a: 0.6))
        view.percents = Int(slider.value)
        self.view.addSubview(view)
        view.start()
        
        singleWaves.append(view)
    }
    
    
    func createOneWaveHeartWithStroke(_ center: CGPoint) {}
}

