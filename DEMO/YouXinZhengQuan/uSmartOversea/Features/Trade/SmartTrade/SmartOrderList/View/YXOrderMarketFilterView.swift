//
//  YXOrderMarketFilterView.swift
//  uSmartOversea
//
//  Created by Evan on 2021/12/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXOrderMarketFilterView: UIControl {

    var selectMarketBlock: ((YXMarketFilterType) -> Void)?

    var didHideBlock: ((Bool) -> Void)?

    private let dataSource: [YXMarketFilterType] = YXMarketFilterType.allCases

    private let bag = DisposeBag()

    private var contentViewHeight: CGFloat = 208

    private var selectedMarketType: YXMarketFilterType = .all

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.register(YXOrderMarketFilterCell.self, forCellReuseIdentifier: NSStringFromClass(YXOrderMarketFilterCell.self))
        view.rowHeight = 50
        view.separatorStyle = .none
        return view
    }()

    @objc init(frame: CGRect, marketType: YXMarketFilterType) {
        super.init(frame: frame)

        self.selectedMarketType = marketType

        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.hidden()
        }).disposed(by: bag)

        self.backgroundColor = QMUITheme().shadeLayerColor()

        containerView.addSubview(tableView)
        addSubview(containerView)

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(200)
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
            cornerRadii: CGSize(width: 20, height: 20))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }

    func show(selectedMarketType: YXMarketFilterType) {
        self.selectedMarketType = selectedMarketType
        self.tableView.reloadData()
        self.isHidden = false
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

extension YXOrderMarketFilterView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXOrderMarketFilterCell.self), for: indexPath) as! YXOrderMarketFilterCell
        let marketType = dataSource[indexPath.row]
        cell.iconImageView.image = UIImage(named: marketType.iconName)
        cell.titleLabel.text = marketType.title
        cell.isSelected = marketType == selectedMarketType
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let marketType = dataSource[indexPath.row]
        selectedMarketType = marketType
        selectMarketBlock?(selectedMarketType)
    }
}
