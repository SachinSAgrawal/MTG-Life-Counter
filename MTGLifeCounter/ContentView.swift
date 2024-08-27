//
//  ContentView.swift
//  MTGLifeCounter
//
//  Created by Sachin Agrawal on 6/22/24.
//

import SwiftUI

struct ContentView: View {
    // Player life states and game control flags
    @State private var player1Life = 20
    @State private var player2Life = 20
    @State private var player3Life = 20
    @State private var player4Life = 20
    @State private var showAlert = false
    @State private var losingPlayer: String?
    @State private var rotationAngles: [Double] = [0, 0, 0, 0]
    @State private var showPlayer3 = false
    @State private var showPlayer4 = false
    @State private var playersLost = [false, false, false, false]

    var body: some View {
        VStack(spacing: 0) {
            // Top row
            HStack(spacing: 0) {
                // Player 1 (Top-left)
                ZStack {
                    playerColor(playerNumber: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    playerText(playerNumber: 1)
                        .rotationEffect(.degrees(rotationAngles[0]))
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    withAnimation {
                                        rotatePlayer(index: 0)
                                    }
                                }
                        )
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            adjustLife(value: value, playerNumber: 1)
                        }
                        .simultaneously(with: LongPressGesture().onEnded { _ in
                            togglePlayerVisibility(playerNumber: 3)
                        })
                )

                // Player 3 (Top-right)
                if showPlayer3 {
                    ZStack {
                        playerColor(playerNumber: 3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        playerText(playerNumber: 3)
                            .rotationEffect(.degrees(rotationAngles[2]))
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation {
                                            rotatePlayer(index: 2)
                                        }
                                    }
                            )
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                adjustLife(value: value, playerNumber: 3)
                            }
                            .simultaneously(with: LongPressGesture().onEnded { _ in
                                togglePlayerVisibility(playerNumber: 3)
                            })
                    )
                }
            }
            .frame(maxHeight: .infinity)

            // Bottom row
            HStack(spacing: 0) {
                // Player 2 (Bottom-left)
                ZStack {
                    playerColor(playerNumber: 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    playerText(playerNumber: 2)
                        .rotationEffect(.degrees(rotationAngles[1]))
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    withAnimation {
                                        rotatePlayer(index: 1)
                                    }
                                }
                        )
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            adjustLife(value: value, playerNumber: 2)
                        }
                        .simultaneously(with: LongPressGesture().onEnded { _ in
                            togglePlayerVisibility(playerNumber: 4)
                        })
                )

                // Player 4 (Bottom-right)
                ZStack {
                    if showPlayer4 {
                        playerColor(playerNumber: 4)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        playerText(playerNumber: 4)
                            .rotationEffect(.degrees(rotationAngles[3]))
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation {
                                            rotatePlayer(index: 3)
                                        }
                                    }
                            )
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            adjustLife(value: value, playerNumber: 4)
                        }
                        .simultaneously(with: LongPressGesture().onEnded { _ in
                            togglePlayerVisibility(playerNumber: 4)
                        })
                )
            }
            .frame(maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(losingPlayer ?? "Player") Lost"),
                message: Text("Would you like to restart the game?"),
                primaryButton: .default(Text("Restart")) {
                    restartGame()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Returns color based on player number
    private func playerColor(playerNumber: Int) -> some View {
        let color: Color

        switch playerNumber {
        case 1:
            color = .red
        case 2:
            color = .blue
        case 3:
            color = .green
        case 4:
            color = .yellow
        default:
            fatalError("Invalid player number")
        }

        return ZStack {
            color
        }
    }

    // Returns text view displaying player's life total
    private func playerText(playerNumber: Int) -> some View {
        let life: Binding<Int>

        switch playerNumber {
        case 1:
            life = $player1Life
        case 2:
            life = $player2Life
        case 3:
            life = $player3Life
        case 4:
            life = $player4Life
        default:
            fatalError("Invalid player number")
        }

        return ZStack {
            PlayerTextView(life: life)
        }
    }

    // Rotates the specified player's view by 90 degrees
    private func rotatePlayer(index: Int) {
        rotationAngles[index] += 90
    }

    // Toggles visibility of player 3 or 4
    private func togglePlayerVisibility(playerNumber: Int) {
        switch playerNumber {
        case 3:
            showPlayer3.toggle()
            if !showPlayer3 {
                player3Life = 20 // Resets player 3's life when hidden
            }
        case 4:
            showPlayer4.toggle()
            if !showPlayer4 {
                player4Life = 20 // Resets player 4's life when hidden
            }
        default:
            break
        }
    }

    // Adjusts player's life based on drag gesture direction and rotation angle
    private func adjustLife(value: DragGesture.Value, playerNumber: Int) {
        let swipeThreshold: CGFloat = 50

        var life: Binding<Int>
        switch playerNumber {
        case 1:
            life = $player1Life
        case 2:
            life = $player2Life
        case 3:
            life = $player3Life
        case 4:
            life = $player4Life
        default:
            fatalError("Invalid player number")
        }

        // Adjusts life based on swipe direction and rotation angle
        let angle = rotationAngles[playerNumber - 1].truncatingRemainder(dividingBy: 360)
        switch angle {
        case 0:
            if value.translation.height < -swipeThreshold {
                life.wrappedValue += 1 // Swipe up
            } else if value.translation.height > swipeThreshold && life.wrappedValue > 0 {
                life.wrappedValue -= 1 // Swipe down
            }
        case 90:
            if value.translation.width < -swipeThreshold && life.wrappedValue > 0 {
                life.wrappedValue -= 1 // Swipe left
            } else if value.translation.width > swipeThreshold {
                life.wrappedValue += 1 // Swipe right
            }
        case 180:
            if value.translation.height > swipeThreshold {
                life.wrappedValue += 1 // Swipe up
            } else if value.translation.height < -swipeThreshold && life.wrappedValue > 0 {
                life.wrappedValue -= 1 // Swipe down
            }
        case 270:
            if value.translation.width > swipeThreshold && life.wrappedValue > 0 {
                life.wrappedValue -= 1 // Swipe left
            } else if value.translation.width < -swipeThreshold {
                life.wrappedValue += 1 // Swipe right
            }
        default:
            break
        }

        checkForLoser() // Checks if any player has lost
    }

    // Checks if any player's life total has dropped to zero or below
    private func checkForLoser() {
        for i in 0..<playersLost.count {
            if !playersLost[i] { // Checks only players who have not lost
                switch i {
                case 0:
                    if player1Life <= 0 {
                        losingPlayer = "Player 1"
                        showAlert = true // Shows alert when player loses
                        playersLost[i] = true // Marks player as lost
                    }
                case 1:
                    if player2Life <= 0 {
                        losingPlayer = "Player 2"
                        showAlert = true
                        playersLost[i] = true
                    }
                case 2:
                    if player3Life <= 0 && showPlayer3 {
                        losingPlayer = "Player 3"
                        showAlert = true
                        playersLost[i] = true
                    }
                case 3:
                    if player4Life <= 0 && showPlayer4 {
                        losingPlayer = "Player 4"
                        showAlert = true
                        playersLost[i] = true
                    }
                default:
                    break
                }
            }
        }
    }

    // Restarts the game by resetting all player states
    private func restartGame() {
        player1Life = 20
        player2Life = 20
        player3Life = 20
        player4Life = 20
        losingPlayer = nil
        playersLost = [false, false, false, false]
    }
}

// Represents a text view showing a player's life total
struct PlayerTextView: View {
    @Binding var life: Int

    var body: some View {
        Text("\(max(0, life))") // Ensure score doesn't go negative
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

#Preview {
    ContentView()
}
