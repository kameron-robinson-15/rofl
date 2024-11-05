//
//  HomeViewController.swift
//  ROFL V1.0
//
//  Created by Kameron Robinson on 10/25/24.
//
import UIKit
import SpriteKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Marble Maze"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        // Center title label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        // Create level buttons
        for i in 1...3 { // Example for 3 levels
            let button = UIButton(type: .system)
            button.setTitle("Level \(i)", for: .normal)
            button.tag = i // Set tag for identifying the level
            button.addTarget(self, action: #selector(levelButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(button)
            
            // Set button constraints
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CGFloat(40 + (i - 1) * 50))
            ])
        }
    }
    
    @objc func levelButtonTapped(_ sender: UIButton) {
        let gameScene = GameScene(size: CGSize(width: 1792, height: 828)) // Adjust size as needed
        gameScene.selectedLevel = sender.tag // Pass the selected level
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)
        view.addSubview(skView)
        dismiss(animated: true, completion: nil) // Dismiss this view controller
    }
}

