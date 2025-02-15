import SwiftUI

struct ShopPageTwo: View {
    @Binding var playerBalance: Int

    @AppStorage("ownedCards") private var ownedCards: String = "firstCardClose"
    @AppStorage("selectedCard") private var selectedCard: String = "firstCardClose"
    @AppStorage("currentSelectedCloseCard") private var currentSelectedCloseCard: String = "cardclose1"

    @State private var alertMessage: String?
    @State private var showAlert: Bool = false

    private let cardOptions: [CardOption] = [
        CardOption(id: "firstCard", buyImage: "firstCardBuy", selectImage: "firstCardSelect", closeImage: "cardclose1", selectedImage: "firstCardSelected"),
        CardOption(id: "greenCard", buyImage: "greenCardBuy", selectImage: "greenCardSelect", closeImage: "greenCardClose", selectedImage: "greenCardSelected"),
        CardOption(id: "blueCard", buyImage: "blueCardBuy", selectImage: "blueCardSelect", closeImage: "blueCardClose", selectedImage: "blueCardSelected")
    ]

    private let cardPrice: Int = 10

    var body: some View {
        HStack(spacing: 20) {
            ForEach(cardOptions) { card in
                Button(action: {
                    handleCardAction(for: card)
                }) {
                    Image(currentImage(for: card))
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    private func currentImage(for card: CardOption) -> String {
        if card.selectedImage == selectedCard {
            return card.selectedImage
        } else if ownedCards.contains(card.closeImage) {
            return card.selectImage
        } else {
            return card.buyImage
        }
    }

    private func handleCardAction(for card: CardOption) {
        if ownedCards.contains(card.closeImage) {
            selectedCard = card.selectedImage
            saveCurrentSelectedCloseCard(card.closeImage)
            alertMessage = "Card selected successfully!"
        } else if playerBalance >= cardPrice {
            playerBalance -= cardPrice
            ownedCards += "," + card.closeImage
            selectedCard = card.selectedImage
            saveCurrentSelectedCloseCard(card.closeImage)
            alertMessage = "Card purchased successfully!"
        } else {
            alertMessage = "Not enough coins to buy this card!"
        }
        showAlert = true
    }

    private func saveCurrentSelectedCloseCard(_ closeCard: String) {
        currentSelectedCloseCard = closeCard
    }
}

struct ShopView: View {
    @AppStorage("coinscore") private var playerBalance: Int = 10

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                    VStack {
                        HStack {
                            Image("back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .onTapGesture {
                                    ApplyGuard.shared.currentScreen = .MENU
                                }
                            Spacer()
                            BalanceTemplate()
                        }
                        Spacer()
                        ShopPageTwo(playerBalance: $playerBalance)
                        Spacer()
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        RotateDeviceScreen()
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image("backgroundShop")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
}

struct CardOption: Identifiable {
    let id: String
    let buyImage: String
    let selectImage: String
    let closeImage: String
    let selectedImage: String
}

#Preview {
    ShopView()
}
