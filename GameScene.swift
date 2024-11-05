//
//  GameScene.swift
//  ROFL V1.0
//
//  Created by Kameron Robinson on 10/23/24.
//
import CoreMotion
import SpriteKit
import AVFoundation
import AVKit
import ReplayKit
import Foundation

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var selectedLevel: Int?
    
    var player: SKSpriteNode!
    
    var isTeleporting = false
    
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager?
    
    var restartButton: UIButton!
    
    var isGameOver = false
    
    var isGameStarted = false
    
    var scoreLabel: SKLabelNode!
    
    var timer: Timer?
    var timeElapsed: TimeInterval = 0
    var timerLabel: SKLabelNode!
    
    var countdownTimer: Timer?
    var countdownValue: Int = 3
    var countdownLabel: UILabel!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var tempURL: URL?
    
    
    var score =  0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 1120, y: 416)
        background.blendMode = .replace
        //background.scale(to: 0.5)
        background.zPosition = -1
        addChild(background)
        
        setupTimer()
        setupCountdownLabel(view: view)
        startCountdown()
        
        setupHomeButton()
        
        setupRestartButton(view: view)
        
        //setupCamera()
        checkCameraPermission()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 64, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        

        if let level = selectedLevel {
            loadLevel(level)
        }
        //loadLevel(1)
        createPlayer(at: CGPoint(x: 704, y: 608))
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
    }
    
    func loadLevel(_ level: Int) {
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {fatalError("Could not find level1.txt in the app bundle.")}
        guard let levelString = try? String(contentsOf: levelURL) else {fatalError("Could not load level1.txt from the app bundle") }
        let lines = levelString.components(separatedBy: "\n")
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 640, y: (64 * row) + -32)
                
                if letter == "x" {
                    //load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    
                    addChild(node)
                } else if letter == "v" {
                    //load vortex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    //node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1))) //make spin
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "s" {
                    //load star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "f" {
                    //load finish point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "j" {
                    //load star
                    let node = SKSpriteNode(imageNamed: "jump")
                    node.name = "jump1"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "k" {
                    //load star
                    let node = SKSpriteNode(imageNamed: "jump")
                    node.name = "jump2"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == " " {
                    //this is an empty space - do nothing!
                    
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        guard isGameOver == false else { return }
        if isGameStarted {
            #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
            #else
            if let accelerometerData = motionManager?.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
            #endif
        } else {
            player.position = CGPoint(x: 704, y: 608)
        }

    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            player.run(sequence) { [weak self] in
                self?.createPlayer(at: CGPoint(x: 704, y: 608))
                self?.isGameOver = false
            }
        } else if node.name == "jump1" && !isTeleporting {
            isTeleporting = true // Set the teleporting flag
            let sparkle = SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1)
            player.run(sparkle)
            
            // Create a new player at jump2's position
            if let jump2 = self.childNode(withName: "jump2") {
                player.removeFromParent()
                // Create a new player instance
                createPlayer(at: jump2.position) // Pass the new position
                
                // Reset the teleporting flag after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isTeleporting = false
                }
            }
        } else if node.name == "jump2" && !isTeleporting {
            isTeleporting = true // Set the teleporting flag
            
            // Create a new player at jump1's position
            if let jump1 = self.childNode(withName: "jump1") {
                player.removeFromParent()
                // Create a new player instance
                createPlayer(at: jump1.position) // Pass the new position
                
                // Reset the teleporting flag after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isTeleporting = false
                }
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            timer?.invalidate()
            timer = nil
            captureSession.stopRunning()
            stopRecording() {result in print(result)}
//            let menuVC = MenuViewController()
//            menuVC.currentLevel = selectedLevel// Create a new HomeViewController instance
//
//            RPScreenRecorder.shared().stopRecording { (previewViewController, error) in
//                let tempDirectory = FileManager.default.temporaryDirectory
//                let videoURL = tempDirectory.appendingPathComponent("recording.mov")
//                menuVC.videoURL = videoURL
//                self.tempURL = videoURL
//                print(videoURL)
//            }
//            print(menuVC.videoURL)

            



//            stopScreenRecording { [weak self] url in
//                    // Present MenuViewController with video URL
//                    //let menuVC = MenuViewController()
//                    menuVC.videoURL = url // Pass the recorded video URL
//                    DispatchQueue.main.async {
//                        self?.view?.window?.rootViewController?.present(menuVC, animated: true, completion: nil)
//                    }
//                }
////            let menuVC = MenuViewController()
////            menuVC.currentLevel = selectedLevel// Create a new HomeViewController instance
            //view?.window?.rootViewController = menuVC // Set it as the root view controller
            }
        
    }
    

    
    func setupTimer() {
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "Time: 0.00"
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.position = CGPoint(x: 64, y: 64)
        timerLabel.zPosition = 2
        addChild(timerLabel)
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timeElapsed += 0.01
        timerLabel.text = "Time: \(Float(timeElapsed))"
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = CGRect(x: 64, y: 256, width: 100, height: 100) // Adjust position and size
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.zPosition = 2
        videoPreviewLayer.cornerRadius = 10

        
        if let connection = videoPreviewLayer.connection {
            connection.videoOrientation = .landscapeRight
        }

        // Add the preview layer to the scene
        let previewLayerNode = SKNode()
        addChild(previewLayerNode)

        let skView = self.view as! SKView
        skView.layer.addSublayer(videoPreviewLayer)

        // Start the session
        captureSession.startRunning()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCamera()
                }
            }
        case .denied:
            print("Camera access denied")
        case .restricted:
            print("Camera access restricted")
        @unknown default:
            break
        }
    }
    
    func setupHomeButton() {
        let homeButton = UIButton(type: .system)
        homeButton.setTitle("Back to Home", for: .normal)
        homeButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        homeButton.setTitleColor(.black, for: .normal)
        homeButton.layer.cornerRadius = 10
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button to the view
        if let view = self.view {
            view.addSubview(homeButton)
            
            // Set button constraints
            NSLayoutConstraint.activate([
                homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                homeButton.widthAnchor.constraint(equalToConstant: 120),
                homeButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        // Add target action for the button
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
    }
    
    @objc func homeButtonTapped() {
        // Handle back button tap
        if let view = self.view {
            view.subviews.forEach { $0.removeFromSuperview() } // Remove the button
            let homeVC = HomeViewController() // Create a new HomeViewController instance
            view.window?.rootViewController = homeVC // Set it as the root view controller
        }
    }
    func setupCountdownLabel(view: SKView) {
        countdownLabel = UILabel()
        countdownLabel.text = "\(countdownValue)"
        countdownLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        countdownLabel.textColor = .white
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countdownLabel)
        
        // Center the label in the view
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        if countdownValue > 0 {
            countdownValue -= 1
            countdownLabel.text = "\(countdownValue)"
        } else {
            countdownTimer?.invalidate() // Stop the timer
            countdownTimer = nil
            countdownLabel.removeFromSuperview() // Remove the countdown label
            timeElapsed = 0.00
            startGame() // Start the game logic after countdown
        }
    }
    
    func startGame() {
        //timeElapsed = 0
//        if isGameStarted {
//            timerLabel.removeFromParent()
//        }
//        setupTimer()
        isGameStarted = true
        startScreenRecording()
    }
    
    func setupRestartButton(view: SKView) {
        restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart Level", for: .normal)
        restartButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        restartButton.setTitleColor(.black, for: .normal)
        restartButton.layer.cornerRadius = 10
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(restartButton)
        
        // Set button constraints
        NSLayoutConstraint.activate([
            restartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 120),
            restartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add target action for the button
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
    }
    
    @objc func restartButtonTapped() {
        // Logic to restart the level
        loadLevel(selectedLevel ?? 1) // Restart the current level
        player.removeFromParent()
        createPlayer(at: CGPoint(x: 704, y: 608))
//        if isGameStarted {
//            timerLabel.removeFromParent()
//        }
        
        countdownLabel.removeFromSuperview()
        countdownValue = 3
        isGameStarted = false
        setupCountdownLabel(view: self.view!)
        startCountdown()
    }
    
    func startScreenRecording() {
        guard RPScreenRecorder.shared().isAvailable else { return }
        RPScreenRecorder.shared().startRecording { error in
            if let error = error {
                print("Error starting recording: \(error.localizedDescription)")
            } else {
                print("Started recording")
            }
        }
    }
    
    func stopScreenRecording(completion: @escaping (URL?) -> Void) {
        RPScreenRecorder.shared().stopRecording { (previewViewController, error) in
            if let error = error {
                print("Error stopping recording: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Present the preview view controller (optional)
//            if let previewViewController = previewViewController {
//                DispatchQueue.main.async {
//                    // You can also present this VC if needed
////                     self.view?.window?.rootViewController?.present(previewViewController, animated: true, completion: nil)
//                }
//            }


            // Save the video to a URL
            // Note: For this example, we assume the video will be saved in a temporary directory
            let tempDirectory = FileManager.default.temporaryDirectory
            let videoURL = tempDirectory.appendingPathComponent("recording.mov")
            completion(videoURL)
            print("Stopped Recording")
        }
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        // ... stop recording logic
        let menuVC = MenuViewController()
        menuVC.currentLevel = selectedLevel// Create a new HomeViewController instance

        RPScreenRecorder.shared().stopRecording { (previewViewController, error) in
            let tempDirectory = FileManager.default.temporaryDirectory
            let videoURL = tempDirectory.appendingPathComponent("recording.mov")
            menuVC.videoURL = videoURL
            self.tempURL = videoURL
            //print(videoURL)
            completion(videoURL)
            self.view?.window?.rootViewController = menuVC
        }

    }
    
}





