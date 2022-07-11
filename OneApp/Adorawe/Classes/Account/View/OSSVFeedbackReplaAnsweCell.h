//
//  OSSVFeedbackReplaAnsweCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVFeedbacksReplaysModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFeedbackReplaAnsweCell : UITableViewCell

@property (nonatomic, strong) STLFeedbackReplayMessageModel *model;

@property (nonatomic, strong) UIView                    *bgColorView;
@property (nonatomic, strong) UIView                    *bgView;
@property (nonatomic, strong) YYAnimatedImageView       *iconImg;
/**评论内容*/
@property (nonatomic, strong) UILabel                   *replyLabel;

@property (nonatomic, assign) BOOL                      isFirst;
@property (nonatomic, assign) BOOL                      isLast;

- (void)updateModel:(STLFeedbackReplayMessageModel *)model first:(BOOL)isFirst last:(BOOL)last;

@end

NS_ASSUME_NONNULL_END
