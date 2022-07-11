//
//  OSSVDetailReviewCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVReviewsListModel.h"
#import "ZZStarView.h"
#import "YYPhotoBrowseView.h"


@interface OSSVDetailReviewCell : OSSVDetailBaseCell

@property (nonatomic, strong) OSSVReviewsListModel      *model;

@property (nonatomic, strong) UIView                    *bottomLineView;
/**头像*/
@property (nonatomic, strong) YYAnimatedImageView       *iconImg;
/**用户名称*/
@property (nonatomic, strong) UILabel                   *userName;
/**星星*/
@property (nonatomic, strong) ZZStarView         *starRating;
/**评论时间*/
@property (nonatomic, strong) UILabel                   *publishedTime;
/**评论内容*/
@property (nonatomic, strong) UILabel                   *replyLabel;
/** 商品属性*/
//@property (nonatomic, strong) UILabel                   *attributeLabel;
/**上传的图片容器*/
@property (nonatomic, strong) UIView                    *pictureContentView;

@property (nonatomic, strong) NSMutableArray            *picArray;
@property (nonatomic, strong) NSMutableArray            *layoutArray;

+ (CGFloat )heightReplayContent:(NSString *)content;
+ (CGFloat )fetchReviewCellHeight:(OSSVReviewsListModel *)model;
@end



@interface STLGoodsDetailReviewMoreCell : OSSVDetailBaseCell

@property (nonatomic, strong) UILabel                 *titleLab;
@property (nonatomic, strong) UIImageView             *arrImgView;

@end
