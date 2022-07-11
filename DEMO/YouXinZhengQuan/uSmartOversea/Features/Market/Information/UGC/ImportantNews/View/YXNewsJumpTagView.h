//
//  YXNewsJumpTagView.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2021/1/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXListNewsJumpTagModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXNewsJumpTagView : UIView

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, copy) void (^tagJumpCallBack)(YXListNewsJumpTagModel *tagModel);

@end

NS_ASSUME_NONNULL_END
