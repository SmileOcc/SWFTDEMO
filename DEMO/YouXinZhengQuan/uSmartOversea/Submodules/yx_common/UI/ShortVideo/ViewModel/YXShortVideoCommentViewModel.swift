//
//  YXCommentViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

enum YXShortVideoCommentBusinessType: Int {
    case lesson = 1
    case shortVideo = 3
    case live = 4
}

class YXShortVideoCommentViewModel {
    
    var lessonId: String = ""
    ///  作者id
    var authorId: String?
    
    var pageNum = 1
    
    let pageSize = 20
    
    var businessType: YXShortVideoCommentBusinessType = .lesson
    
    //是否倒序(默认倒叙)
    var orderDesc = true
    
//    var commentList: [YXCommentItem] = []
    
    var refreshCommentList: Driver<YXShortVideoCommentListResModel?>!
    
    var loadMoreCommentList: Driver<[YXShortVideoCommentItem]>!

    var sendButtonEnable: Driver<Bool>!
    
    var publishComment: Driver<YXResponseModel?>!
    
    var deleteComment: Driver<IndexPath?>!
    
    var likeComment: Driver<Bool>!
    
    // 把输入转为输出
    func setInput(input: (viewWillAppear: Observable<[Any]>,
                          textViewInput: Driver<String>,
                          publishComment: Signal<String?>,
                          deleteComment: Driver<(String,IndexPath)>,
                          likeComment: Driver<(String,YXShortVideoLikeAction)>,
                          loadMore: Driver<()>)) {
        
        let lessonId = self.lessonId
        let pageSize = self.pageSize
        let businessCode = self.businessType.rawValue
        let orderDesc = self.orderDesc
        
        sendButtonEnable = input.textViewInput.map({ text in
            return text.count > 0
        })
        
        let commentInput = Driver.combineLatest(input.publishComment.asDriver(onErrorJustReturn: nil),input.textViewInput)
        publishComment = input.publishComment.withLatestFrom(commentInput).flatMapLatest { (parentsId,text) in
                return YXCourseRequestAPI.addcomment(lessonId: lessonId, content: text, commentType: businessCode,parentId: parentsId).request().map { res in
                    return res
                }.asDriver(onErrorJustReturn: nil)
        }

        deleteComment = input.deleteComment.flatMapLatest({ value in
            return YXCourseRequestAPI.deletecomment(commentId: value.0).request().map { res in
                if res?.code == YXResponseStatusCode.success {
                    return value.1
                }
                return nil
            }.asDriver(onErrorJustReturn: nil)
        })
        
        likeComment = input.likeComment.flatMapLatest({ (id, action) in
            return YXCourseRequestAPI.like(business: 3, businessId: id, status: action.rawValue).request().map { res in
                return res?.code == YXResponseStatusCode.success
            }.asDriver(onErrorJustReturn: false)
        })
        
        // merge方法要求Observable的元素类型一致才可以,所以需要把input.viewWillAppear的元素类型改成Bool
        refreshCommentList = Observable.merge(input.viewWillAppear.map({_ in true})).filter({ $0 }).asDriver(onErrorJustReturn: false).flatMapLatest { _ in
            return YXCourseRequestAPI.commentList(lessonId: lessonId, pageNum: 1, pageSize: pageSize, businessCode: businessCode, orderDesc: orderDesc).request().map { res in
                self.pageNum = 2
                let model = YXShortVideoCommentListResModel.yy_model(withJSON: res?.data ?? [:])
                let list = model?.items ?? []
                return model
            }.asDriver(onErrorJustReturn: nil)
        }
        
        loadMoreCommentList = input.loadMore.flatMapLatest({ _ in
            return YXCourseRequestAPI.commentList(lessonId: lessonId, pageNum: self.pageNum, pageSize: pageSize, businessCode: businessCode, orderDesc: orderDesc).request().map({ res in
                if let model = YXShortVideoCommentListResModel.yy_model(withJSON: res?.data ?? [:]) {
                    self.pageNum += 1
                    return model.items
                }
                return []
                
            }).asDriver(onErrorJustReturn: [])
        })
    }
}

