//
//  YXUGCFeedAttentionSumItemModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCFeedAttentionSumItemModel: YXModel {
    
    @objc var attentionPostModel:YXUGCFeedAttentionModel?
    @objc var attentionCommentModel:YXUGCAttentionCommentListItemModel?

}

extension YXUGCFeedAttentionSumItemModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    
    }
}
