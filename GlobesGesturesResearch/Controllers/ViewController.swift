//
//  ViewController.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 17/3/2025.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = SoundManager.shared 
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("playCorrectSound"), object: nil)
    }
}
