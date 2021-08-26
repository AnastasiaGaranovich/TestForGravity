//
//  ViewController.swift
//  TestForGravity
//
//  Created by Анастасия Гаранович on 26.08.2021.
//

import UIKit

class MainViewController: UIViewController {
    private let gameDuration: TimeInterval = 7.0
    private var touchingCount = 0
    private var timer: Timer!
    private var startTime: Date = Date()
    
    private let tutorialKey = "SHOW_TUTOTIAL_KEY"
    
    private var showTutorial: Bool {
        get {
            if UserDefaults.standard.object(forKey: tutorialKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: tutorialKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tutorialKey)
        }
    }
    
    private var timerColor: UIColor {
        if timeLeft > 2 {
            return UIColor.green
        }
        return UIColor.red
    }
    
    private var timeLeft: TimeInterval {
        return gameDuration + startTime.timeIntervalSince(Date())
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var touchingCountLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var aimButton: UIButton!
    
    @IBAction func aimButtonPressed(_ sender: UIButton) {
        touchingCount += 1
        touchingCountLabel.text = "\(touchingCount) times"
        if touchingCount == 10 {
            stopTimer()
            gameFinished(win: true)
            return
        }
        moveAim()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        startButton.isHidden = true
        gameIsShown()
        touchingCountLabel.text = "\(touchingCount) times"
        moveAim(animated: false)
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(onTimerTick),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if showTutorial {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            present(viewController, animated: true, completion: nil)
            showTutorial = false
        }
        navigationController?.navigationBar.isHidden = true
        gameIsHidden()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        resetGame()
    }
}

extension MainViewController {
    
    private func resetGame() {
        gameIsHidden()
        touchingCount = 0
        startButton.isHidden = false
    }
    
    private func gameIsHidden() {
        timerLabel.isHidden = true
        touchingCountLabel.isHidden = true
        aimButton.isHidden = true
    }
    
    private func gameIsShown() {
        timerLabel.isHidden = false
        touchingCountLabel.isHidden = false
        aimButton.isHidden = false
    }
    
    private func moveAim(animated: Bool = true) {
        
        let maxX = view.frame.size.width - aimButton.frame.size.width
        // prevent aim from hiding labels
        let minY = touchingCountLabel.frame.origin.y + touchingCountLabel.frame.size.height + 20
        let maxY = view.frame.size.height - aimButton.frame.size.height
        
        let x = CGFloat.random(in: 0...maxX)
        let y = CGFloat.random(in: minY...maxY)
        
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.aimButton.frame.origin = CGPoint(x: x, y: y)
            }
        }
        else {
            self.aimButton.frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    @objc func onTimerTick() {
        timerLabel.textColor = timerColor
        if timeLeft < 0 {
            stopTimer()
            gameFinished(win: false)
            timerLabel.text = "0.0 seconds"
            return
        }
        timerLabel.text = String(format: "%.1f", timeLeft) + " seconds"
    }
    
    private func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
    private func gameFinished(win: Bool) {
        Network.getGameStatusUrls { error, data in
            if let error = error {
                print(error) //Alert
                return
            }
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            if win {
                viewController.url = data?.winner
            }
            else {
                viewController.url = data?.loser
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
