//
//  CardFactory.swift
//  petTracking
//
//  Created by shue on 2025/12/10.
//

import UIKit

struct CardItem {
    let icon: String
    let title: String
    let navigateTo: UIViewController?
}

struct CardFactory {

    static func makeCards(
        items: [CardItem],
        container: UIView,
        colorHexes: [String],
        target: Any?,
        action: Selector
    ) -> [BTButton] {
        var buttons: [BTButton] = []

        for (index, item) in items.enumerated() {
            let card = BTButton()
            let color = UIColor(hexString: colorHexes[index % colorHexes.count])
            card.configure(icon: item.icon, title: item.title, color: color)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.tag = index
            card.addTarget(target, action: action, for: .touchUpInside)
            container.addSubview(card)
            buttons.append(card)
        }

        return buttons
    }

    static func layoutCards(
        _ cards: [BTButton],
        in container: UIView,
        sidePadding: CGFloat = 25,
        spacing: CGFloat = 20,
        cardHeight: CGFloat = 130
    ) {
        guard !cards.isEmpty else { return }
        let screenWidth = container.frame.width
        let cardWidth = (screenWidth - sidePadding * 2 - spacing) / 2

        for (index, card) in cards.enumerated() {
            let isLeft = index % 2 == 0
            let row = index / 2

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: cardWidth),
                card.heightAnchor.constraint(equalToConstant: cardHeight),
                card.topAnchor.constraint(equalTo: row == 0 ? container.topAnchor : cards[index - 2].bottomAnchor, constant: row == 0 ? 0 : spacing)
            ])

            if isLeft {
                card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: sidePadding).isActive = true
            } else {
                card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -sidePadding).isActive = true
                card.leadingAnchor.constraint(equalTo: cards[index - 1].trailingAnchor, constant: spacing).isActive = true
            }
        }

        if let lastCard = cards.last {
            lastCard.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        }
    }
}
