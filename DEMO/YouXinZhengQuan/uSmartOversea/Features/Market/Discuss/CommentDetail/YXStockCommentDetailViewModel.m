//
//  YXStockCommentDetailViewModel.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockCommentDetailViewModel.h"
#import "uSmartOversea-Swift.h"

@implementation YXStockCommentDetailViewModel

-(void)initialize {
    if (self.params[@"cid"]) {
        self.cid = self.params[@"cid"];
    }
}

-(YXCommentSectionTitleModel *)commentTitleModel {
    if (!_commentTitleModel) {
        _commentTitleModel = [[YXCommentSectionTitleModel alloc] init];
    }
    return _commentTitleModel;
}

-(NSMutableArray *)commentLists {
    if (!_commentLists) {
        _commentLists = [NSMutableArray array];
    }
    return _commentLists;
}

-(YXCommentSectionFooterTitleModel *)footerTitleModel {
    if (!_footerTitleModel) {
        _footerTitleModel = [[YXCommentSectionFooterTitleModel alloc] init];
        _footerTitleModel.title = [YXLanguageUtility kLangWithKey:@"more_comment_open"];
    }
    return _footerTitleModel;
}

-(YXCommentDetailNoDataModel *)noDataModel {
    if (!_noDataModel) {
        _noDataModel = [[YXCommentDetailNoDataModel alloc] init];
        _noDataModel.image = @"empty_noData";
        _noDataModel.title = [YXLanguageUtility kLangWithKey:@"no_comment_hk"];
        _noDataModel.subTitle = [YXLanguageUtility kLangWithKey:@"comment_now_hk"];
        _noDataModel.post_type = @"5";
    }
    return _noDataModel;
}

@end
