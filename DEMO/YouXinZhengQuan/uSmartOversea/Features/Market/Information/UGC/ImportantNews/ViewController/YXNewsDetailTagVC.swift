//
//  YXNewsDetailTagVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit


class YXNewsDetailTagModel: NSObject {
    
    @objc var tagList: [YXListNewsJumpTagModel]?
}

extension YXNewsDetailTagModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}



class YXNewsDetailTagCell: UICollectionViewCell {
    
    let tagView = YXNewsJumpTagView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        contentView.addSubview(tagView)
        tagView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
    }
}


class YXNewsDetailTagVC: ListSectionController {

    private var object: YXNewsDetailTagModel?
    
    override init() {
        super.init()
    }

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        return CGSize(width: width, height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsDetailTagCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.tagView.list = object?.tagList ?? [Any]()
        cell.tagView.tagJumpCallBack = { model in
            if model.jump_type == 1 {
                YXWebViewModel.pushToWebVC(model.jump_addr)
            } else if model.jump_type == 2 {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: model.jump_addr)
            }
        }
        return cell
    }
    

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsDetailTagModel
    }

}
