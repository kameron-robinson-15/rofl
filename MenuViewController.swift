//
//  MenuViewController.swift
//  ROFL V1.0
//
//  Created by Kameron Robinson on 10/28/24.
//
//
import UIKit
import SpriteKit
import AVKit
import ReplayKit
import Photos





class MenuViewController: UIViewController {
    var currentLevel: Int?
    var videoURL: URL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        let titleLabel = UILabel()
        titleLabel.text = "Level Completed!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Set up buttons
        let restartButton = createButton(title: "Restart Level", action: #selector(restartLevel))
        let homeButton = createButton(title: "Home", action: #selector(goHome))
        let nextLevelButton = createButton(title: "Next Level", action: #selector(nextLevel))

        let stackView = UIStackView(arrangedSubviews: [titleLabel, restartButton, homeButton, nextLevelButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        let placeholderView = UIView(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
        placeholderView.backgroundColor = .black
        view.addSubview(placeholderView)
        
        // Center the stack view in the view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

//        if let videoURL = videoURL {
//            let player = AVPlayer(url: videoURL)
//            let playerController = AVPlayerViewController()
//            playerController.player = player
//            
//            present(playerController, animated: true)
//            {
//                player.play()
//            }
//        }

//        if let videoURL = videoURL {
//                   let player = AVPlayer(url: videoURL)
//                   let playerLayer = AVPlayerLayer(player: player)
//                   playerLayer.frame
//        = CGRect(x: 720, y: 608, width: view.bounds.width, height: view.bounds.height)
//
//                   view.layer.addSublayer(playerLayer)
//                   player.play()
//               }
//        print(videoURL)
        
        if let videoURL = videoURL {
            let player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            
            // Set the playerLayer's frame to fit within placeholderView
            //playerLayer?.frame = placeholderView.bounds
            playerLayer?.frame = CGRect(x: 200, y: 400, width: 100, height: 100)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.zPosition = 999
            playerLayer?.isHidden = false
            view.layer.addSublayer(playerLayer!)

            // Start playing the video
            print("From menuViewController: \(videoURL)")
            player.play()
            
        }
        
        //playerLayer = VideoPlayer(player: AVPlayer(url: videoURL!))



    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func restartLevel(_ sender: UIButton) {
        let gameScene = GameScene(size: CGSize(width: 1792, height: 828)) // Adjust size as needed
        sender.tag = currentLevel ?? 1
        gameScene.selectedLevel = sender.tag // Pass the selected level
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)
        view.addSubview(skView)
        dismiss(animated: true, completion: nil) // Dismiss this view controller
    }

    @objc func goHome() {
        let homeVC = HomeViewController() // Create a new HomeViewController instance
        view.window?.rootViewController = homeVC // Set it as the root view controller
        dismiss(animated: true, completion: nil) // Adjust if needed based on navigation
    }

    @objc func nextLevel(_ sender: UIButton) {
        let gameScene = GameScene(size: CGSize(width: 1792, height: 828)) // Adjust size as needed
        sender.tag = (currentLevel ?? 1) + 1
        gameScene.selectedLevel = sender.tag // Pass the selected level
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)
        view.addSubview(skView)
        dismiss(animated: true, completion: nil) // Dismiss this view controller
    }
    

}




