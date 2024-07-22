//
//  ZFCommunityHomeTopicCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityBaseCCell.h"

@interface ZFCommunityHomeTopicCell : ZFCommunityBaseCCell

@property (nonatomic, strong) UIView                       *topicContentView;
@property (nonatomic, strong) UIImageView                  *topicPicImageView;
@property (nonatomic, strong) UIView                       *topicMaskView;
@property (nonatomic, strong) UILabel                      *topicContentLab;
@property (nonatomic, strong) UILabel                      *topicNumLab;
@property (nonatomic, strong) UILabel                      *topicViewsLab;
/** 置顶图标,根据is_top == 1 显示*/
@property (nonatomic, strong) UIButton                     *topicTopButton;

+ (NSString *)queryReuseIdentifier;
@end

