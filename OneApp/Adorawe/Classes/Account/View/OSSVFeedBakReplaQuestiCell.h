//
//  OSSVFeedBakReplaQuestiCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVFeedbacksReplaysModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFeedBakReplaQuestiCell : UITableViewCell

@property (nonatomic, strong) OSSVFeedbacksReplaysModel *model;

@property (nonatomic, strong) UIView                    *bgColorView;
@property (nonatomic, strong) UIView                    *bgView;
@property (nonatomic, strong) YYAnimatedImageView       *iconImg;
@property (nonatomic, strong) UILabel                   *questionTypeDesc;
/**评论内容*/
@property (nonatomic, strong) UILabel                   *replyLabel;
/**上传的图片容器*/
@property (nonatomic, strong) UIView                    *pictureContentView;

@property (nonatomic, strong) NSMutableArray            *picArray;
@property (nonatomic, strong) NSMutableArray            *layoutArray;


@end

NS_ASSUME_NONNULL_END
