//
//  ContentView.swift
//  Pong Game
//
//  Created by Marek Michalski on 05/08/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State private var ballVelocity = CGPoint(x: 5, y: 5)
    @State private var playerPaddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)
    @State private var computerPaddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 60)
    @State private var playerScore = 0
    @State private var computerScore = 0
    @State private var computerScoreInRound = 0
    @State private var gameOver = false
    @State private var gameStarted = false // New state to track game start
    @State private var gamePaused = false // New state to track game pause
    
    let paddleSize = CGSize(width: 100, height: 20)
    let ballSize: CGFloat = 20
    let winningScore = 21
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all) // Ensure background color covers the entire screen
                
                if gameStarted {
                    if gameOver {
                        VStack {
                            Text(playerScore == winningScore ? "Player Wins!" : "Computer Wins!")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("Computer scored \(computerScoreInRound) points this round.")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                            
                            Button(action: {
                                resetGame()
                            }) {
                                Text("Restart")
                                    .font(.title)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                        }
                    } else {
                        // Ball
                        Ball(position: $ballPosition, size: ballSize)
                        
                        // Player Paddle
                        Paddle(position: CGPoint(x: playerPaddlePosition.x, y: geometry.size.height - geometry.safeAreaInsets.bottom), size: paddleSize)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        playerPaddlePosition.x = value.location.x
                                    }
                            )
                        
                        // Computer Paddle
                        Paddle(position: CGPoint(x: computerPaddlePosition.x, y:
                                                    geometry.safeAreaInsets.top), size: paddleSize)
                        // Display Scores
                        VStack {
                            Text("Computer: \(computerScore)")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .padding(.top, geometry.safeAreaInsets.top) // Respect safe area for top padding
                            Spacer()
                            Text("Player: \(playerScore)")
                                .foregroundColor(.white)
                                .padding(.bottom, 20)
                                .padding(.bottom, geometry.safeAreaInsets.bottom) // Respect safe area for bottom padding
                        }
                        
                        // Pause/Play and Back Buttons
                        VStack {
                            HStack {
                                Button(action: {
                                    resetGame()
                                    gameStarted = false
                                }) {
                                    Text("Back")
                                        .font(.body)
                                        .padding(5)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                }
                                Spacer()
                                Button(action: {
                                    gamePaused.toggle()
                                }) {
                                    Text(gamePaused ? "Play" : "Pause")
                                        .font(.body)
                                        .padding(5)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                }
                            }
//                            .padding()
                            Spacer()
                        }
                    }
                } else {
                    // Welcome screen
                    VStack {
                        Spacer()
                        
                        Text("Welcome to Pong Game!")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.top, geometry.safeAreaInsets.top) // Respect safe area for top padding
                        
                        Spacer()
                        
                        Button(action: {
                            gameStarted = true
                            startGame()
                        }) {
                            Text("Start")
                                .font(.title)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    
    func startGame() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if !gameOver {
                if !gamePaused {
                    updateBallPosition(geometry: UIScreen.main.bounds)
                    updateComputerPaddlePosition()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    func updateBallPosition(geometry: CGRect) {
        ballPosition.x += ballVelocity.x
        ballPosition.y += ballVelocity.y
        
        // Collision with walls
        if ballPosition.x <= ballSize / 2 || ballPosition.x >= geometry.width - ballSize / 2 {
            ballVelocity.x = -ballVelocity.x
        }
        
        // Collision with computer paddle
        let computerPaddleRect = CGRect(
            x: computerPaddlePosition.x - paddleSize.width / 2,
            y: computerPaddlePosition.y - paddleSize.height / 2,
            width: paddleSize.width,
            height: paddleSize.height
        )
        
        // Debug prints for computer paddle collision
        print("Computer Paddle Rect: \(computerPaddleRect)")
        print("Ball Position: \(ballPosition)")
        
        if computerPaddleRect.intersects(CGRect(x: ballPosition.x - ballSize / 2, y: ballPosition.y - ballSize / 2, width: ballSize, height: ballSize)) {
            ballVelocity.y = abs(ballVelocity.y) // Ensure the ball moves downward
            ballPosition.y = computerPaddlePosition.y + paddleSize.height / 2 + ballSize / 2 // Adjust position to avoid multiple collisions
            print("Collision with Computer Paddle")
        }
        
        // Collision with player paddle
        let playerPaddleRect = CGRect(
            x: playerPaddlePosition.x - paddleSize.width / 2,
            y: playerPaddlePosition.y - paddleSize.height / 2,
            width: paddleSize.width,
            height: paddleSize.height
        )
        
        // Debug prints for player paddle collision
        print("Player Paddle Rect: \(playerPaddleRect)")
        print("Ball Position: \(ballPosition)")
        
        if playerPaddleRect.intersects(CGRect(x: ballPosition.x - ballSize / 2, y: ballPosition.y - ballSize / 2, width: ballSize, height: ballSize)) {
            ballVelocity.y = -abs(ballVelocity.y) // Ensure the ball moves upward
            ballPosition.y = playerPaddlePosition.y - paddleSize.height / 2 - ballSize / 2 // Adjust position to avoid multiple collisions
            print("Collision with Player Paddle")
        }
        
        // Check for scoring
        if ballPosition.y <= geometry.minY {
            playerScore += 1
            resetBall(geometry: geometry)
        } else if ballPosition.y >= geometry.maxY {
            computerScore += 1
            computerScoreInRound += 1
            resetBall(geometry: geometry)
        }
        
        // Check for game over
        if playerScore == winningScore || computerScore == winningScore {
            gameOver = true
        }
    }
    
    func updateComputerPaddlePosition() {
        // Simple AI to move the computer paddle with some randomness
        let targetX = ballPosition.x
        let paddleSpeed: CGFloat = 3 // Reduced speed for more challenge
        let randomFactor = CGFloat.random(in: -10...10) // Add randomness to the target position
        
        if computerPaddlePosition.x < targetX + randomFactor {
            computerPaddlePosition.x += paddleSpeed
        } else if computerPaddlePosition.x > targetX + randomFactor {
            computerPaddlePosition.x -= paddleSpeed
        }
    }
    
    func resetBall(geometry: CGRect) {
        ballPosition = CGPoint(x: geometry.width / 2, y: geometry.height / 2)
        
        // Assign a random direction for the ball
        let randomAngle = CGFloat.random(in: 0..<360) * .pi / 180
        let speed: CGFloat = 5
        ballVelocity = CGPoint(x: cos(randomAngle) * speed, y: sin(randomAngle) * speed)
    }
    
    func resetGame() {
        playerScore = 0
        computerScore = 0
        computerScoreInRound = 0
        gameOver = false
        gameStarted = false // Return to welcome screen
        resetBall(geometry: UIScreen.main.bounds)
    }
}

struct Ball: View {
    @Binding var position: CGPoint
    var size: CGFloat
    
    var body: some View {
        Circle()
            .frame(width: size, height: size)
            .position(position)
            .foregroundColor(.white)
    }
}

struct Paddle: View {
    var position: CGPoint
    var size: CGSize
    
    var body: some View {
        Rectangle()
            .frame(width: size.width, height: size.height)
            .position(position)
            .foregroundColor(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

