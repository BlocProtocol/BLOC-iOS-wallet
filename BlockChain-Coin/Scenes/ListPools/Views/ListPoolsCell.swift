//
//  ListPoolsCell.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 30/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import UIKit

class ListPoolsCell: TableViewCell {

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.layoutMargins = UIEdgeInsets(top: 15.0, left: 20.0, bottom: 15.0, right: 10.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        return stackView
    }()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12.5)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 10.0)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.numberOfLines = 0
        return label
    }()
    
    let accessoryImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.roundOff())
        imageView.tintColor = UIColor(hex: 0x00ffff)
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: R.image.separatorDash()!)
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        
        contentView.backgroundColor = .clear
        backgroundColor = contentView.backgroundColor
        
        contentView.addSubview(separatorView)
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        [ textStackView, accessoryImageView ].forEach(stackView.addArrangedSubview)
        
        [ topLabel, bottomLabel ].forEach(textStackView.addArrangedSubview)
        
        accessoryImageView.snp.makeConstraints({
            $0.height.equalTo(39.0)
            $0.width.equalTo(39.0)
        })
        
        separatorView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(15.0)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1.0)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        accessoryImageView.image = selected ? R.image.roundOn() : R.image.roundOff()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        accessoryImageView.image = highlighted ? R.image.roundOn() : R.image.roundOff()
        self.backgroundColor = highlighted ? UIColor(hex: 0x121f46) : .clear
    }
    
    func configure(name: String, subtitle: String) {
        topLabel.text = "• \(name)"
        bottomLabel.text = subtitle
    }

}
