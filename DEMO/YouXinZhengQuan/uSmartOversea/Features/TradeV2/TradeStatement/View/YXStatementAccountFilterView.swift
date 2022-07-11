//
//  YXStatementAccountFilterView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import YYText

class YXStatementAccountFilterView: UIControl {
    
    var selectedBlock:((_ type:TradeStatementAccountType) -> Void)?
    
    private var selectedStatementAccountType: TradeStatementAccountType = .stock

    private var contentViewHeight: CGFloat = 188

    var didHideBlock: ((Bool) -> Void)?

    lazy var cancelButton: QMUIButton = {
        let cancelButton = QMUIButton()
        cancelButton.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelButton.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        cancelButton.backgroundColor = QMUITheme().foregroundColor()
        cancelButton.layer.borderColor = QMUITheme().alertButtonLayerColor().cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 4
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        _ = cancelButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](btn) in
            self?.hidden()
        })

        return cancelButton
    }()

    lazy var confirmButton: QMUIButton = {
        let confirmButton = QMUIButton()
        confirmButton.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = QMUITheme().themeTextColor()
        confirmButton.layer.borderColor = QMUITheme().themeTextColor().cgColor
        confirmButton.layer.borderWidth = 1.0
        confirmButton.layer.cornerRadius = 4
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        return confirmButton
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 15

        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = QMUITheme().foregroundColor()
        view.register(YXOrderMutipleConditionsFilterCell.self,
                      forCellWithReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterCell.self))
        view.register(YXOrderMutipleConditionsFilterHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterHeaderView.self))

        return view
    }()

    var types: [TradeStatementAccountType]!
    init(frame: CGRect, types: [TradeStatementAccountType]) {
        super.init(frame: frame)

        self.types = types
        
        qmui_tapBlock = { [weak self] sender in
            self?.hidden()
        }
        
        confirmButton.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.selectedBlock?(self.selectedStatementAccountType)
        }
        
        self.backgroundColor = QMUITheme().shadeLayerColor()


        let cancelBtnAndConfirmBtnStackView = UIStackView.init(arrangedSubviews: [cancelButton, confirmButton])
        cancelBtnAndConfirmBtnStackView.alignment = .fill
        cancelBtnAndConfirmBtnStackView.axis = .horizontal
        cancelBtnAndConfirmBtnStackView.distribution = .fillEqually
        cancelBtnAndConfirmBtnStackView.spacing = 21

        containerView.addSubview(collectionView)
        containerView.addSubview(cancelBtnAndConfirmBtnStackView)
        addSubview(containerView)

        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
        }

        cancelBtnAndConfirmBtnStackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(48)
            make.top.equalTo(collectionView.snp.bottom).offset(20)
        }

        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-contentViewHeight)
            make.height.equalTo(contentViewHeight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maskPath = UIBezierPath(
            roundedRect: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: contentViewHeight),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }

    func show(accountType: TradeStatementAccountType
    ) {
        selectedStatementAccountType = accountType

        self.isHidden = false
        collectionView.reloadData()

        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
            self.layoutIfNeeded()
        })
    }

    func hidden() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(-self.contentViewHeight)
            }
            self.layoutIfNeeded()
        }) { (finished) in
            self.isHidden = true
            self.didHideBlock?(finished)
        }
    }
}

extension YXStatementAccountFilterView:
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        types.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterCell.self),
            for: indexPath
        ) as! YXOrderMutipleConditionsFilterCell

        let type = types[indexPath.row]
        cell.titleLabel.text = type.text

        cell.isChoosed = selectedStatementAccountType == type

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterHeaderView.self),
                for: indexPath
            ) as! YXOrderMutipleConditionsFilterHeaderView

            header.titleLabel.text = YXLanguageUtility.kLang(key: "accounts")

            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: YYTextCGFloatPixelFloor(collectionView.width - 32) / 3.0, height: 32.0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.size.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = types[indexPath.row]
        
        selectedStatementAccountType = type

        collectionView.reloadData()
    }
}
