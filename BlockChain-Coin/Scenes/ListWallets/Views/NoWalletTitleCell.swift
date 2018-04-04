//
//  NoWalletTitleCell.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 15/03/2018.
//  Copyright © 2018 BlockChain-Coin.net. All rights reserved.
//

import UIKit

class NoWalletTitleCell: TableViewCell {
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 0.0, right: 20.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.preservesSuperviewLayoutMargins = true
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 15.5)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    let titleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x000b35)
        view.layer.cornerRadius = 4.0
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleBackgroundView)
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        titleBackgroundView.snp.makeConstraints({
            $0.leading.equalTo(stackView).inset(stackView.layoutMargins.left)
            $0.trailing.equalTo(stackView).inset(stackView.layoutMargins.right)
            $0.top.equalTo(stackView).inset(stackView.layoutMargins.top)
            $0.bottom.equalTo(stackView).inset(stackView.layoutMargins.bottom)
        })
        
        titleLabel.snp.makeConstraints({
            $0.height.equalTo(25.0)
        })
        
        [ SpacerView(height: 15.0), titleLabel, SpacerView(height: 15.0) ].forEach(stackView.addArrangedSubview)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleBackgroundView.layer.rasterizationScale = UIScreen.main.scale
        titleBackgroundView.layer.shouldRasterize = true
    }
    
}
