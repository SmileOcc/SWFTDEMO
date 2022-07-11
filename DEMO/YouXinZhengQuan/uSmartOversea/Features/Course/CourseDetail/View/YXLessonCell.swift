//
//  YXLessonCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import QMUIKit
import RxSwift
import RxCocoa
import UIKit

class YXLessonCell : UITableViewCell {
    
    /// 标题
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        return label;
    }()
    
    
    /// 观看数
    lazy var count: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.setImage(UIImage(named: "play_count_icon"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return btn
    }()

    /// 播放时长
    lazy var duration: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.setImage(UIImage(named: "duration_icon"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return btn
    }()
    
    
    /// 播放按钮状态
    lazy var playBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "player_play_icon_sm"), for: .normal)
        btn.setImage(UIImage(named: "playing_icon"), for: .selected)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //是否播放当前课时状态
    var isPlaying: Bool = false
{
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                titleLabel.textColor = QMUITheme().mainThemeColor()
                titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
                self.backgroundColor = QMUITheme().blockColor().withAlphaComponent(0.85)
            } else {
                titleLabel.textColor = QMUITheme().textColorLevel1()
                titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
                self.backgroundColor = QMUITheme().foregroundColor()
            }
        }
    }
    
    var isLocked: Bool = false {
        didSet {
            if isLocked {
                playBtn.setImage(UIImage(named: "course_locked_icon"), for: .normal)
            } else {
                playBtn.setImage(UIImage(named: "player_play_icon_sm"), for: .normal)
            }
        }
    }
    
    func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(count)
        contentView.addSubview(playBtn)
        contentView.addSubview(duration)
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.right.equalTo(playBtn.snp.left).offset(-16)
        }
        
        count.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        duration.snp.makeConstraints { make in
            make.left.equalTo(count.snp.right).offset(24)
            make.centerY.equalTo(count.snp.centerY)
        }
        
        playBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.size.equalTo(18)
        }
    }
}
