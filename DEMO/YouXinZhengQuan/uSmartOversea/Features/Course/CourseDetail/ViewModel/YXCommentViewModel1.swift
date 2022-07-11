//
//  YXCommentViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa

class YXCommentViewModel1 {
    
    var lessonId: String = ""
    
    var pageNum = 1
    
    let pageSize = 20
    
    var commentList: [YXCourseCommentItem] = []
    
    var refreshCommentList: Driver<YXCommentListResModel?>!
    
    var loadMoreCommentList: Driver<[YXCourseCommentItem]>!

    var sendButtonEnable: Driver<Bool>!
    
    var publishComment: Driver<Bool>!
    
    var deleteComment: Driver<Bool>!
    
    var reloadComment: Driver<(Bool)>!
    
    // 把输入转为输出
    func setInput(input: (viewWillAppear: Observable<[Any]>,
                          textViewInput: Driver<String>,
                          publishComment: Signal<()>,
                          deleteComment: Driver<String>,
                          loadMore: Driver<()>,
                          reloadComment:Driver<()>)) {
        
        let lessonId = self.lessonId
        let pageSize = self.pageSize
        
        sendButtonEnable = input.textViewInput.map({ text in
            return text.count > 0
        })
        
        publishComment = input.publishComment.withLatestFrom(input.textViewInput).flatMapLatest({ text in
            return YXCourseRequestAPI.addcomment(lessonId: lessonId, content: text, commentType: 1).request().map { res in
                return res?.code == YXResponseStatusCode.success
            }.asDriver(onErrorJustReturn: false)
        })
        
        deleteComment = input.deleteComment.flatMapLatest({ id in
            return YXCourseRequestAPI.deletecomment(commentId: id).request().map { res in
                return res?.code == YXResponseStatusCode.success
            }.asDriver(onErrorJustReturn: false)
        })
        
        reloadComment = input.reloadComment.map{true}
        // merge方法要求Observable的元素类型一致才可以,所以需要把input.viewWillAppear的元素类型改成Bool
        refreshCommentList = Observable.merge(input.viewWillAppear.map({_ in true}), publishComment.asObservable(), deleteComment.asObservable(),reloadComment.asObservable()).filter({ $0 }).asDriver(onErrorJustReturn: false).flatMapLatest { _ in
            
            return YXCourseRequestAPI.commentList(lessonId: self.lessonId, pageNum: 1, pageSize: pageSize, businessCode: 1, orderDesc: true).request().map { res in
                self.pageNum = 2
                let model = YXCommentListResModel.yy_model(withJSON: res?.data ?? [:])
                let list = model?.items ?? []
                model?.code = res?.code ?? .newsNoUser
                self.commentList = list
                return model
            }.asDriver(onErrorJustReturn: nil)
        }
        
        loadMoreCommentList = input.loadMore.flatMapLatest({ _ in
            return YXCourseRequestAPI.commentList(lessonId: lessonId, pageNum: self.pageNum, pageSize: pageSize, businessCode: 1, orderDesc: true).request().map({ res in
                if let model = YXCommentListResModel.yy_model(withJSON: res?.data ?? [:]) {
                    self.commentList = self.commentList + model.items
                    self.pageNum += 1
                }
                return self.commentList
                
            }).asDriver(onErrorJustReturn: self.commentList)
        })
    }
}

