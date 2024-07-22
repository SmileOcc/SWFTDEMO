//
//  ZFCommunityPostDetailBottomView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 社区帖子详情底部工具栏
 */
@interface ZFCommunityPostDetailBottomView : UIView

@property (nonatomic, strong) UIButton *relationButton;   // 相关商品

@property (nonatomic, copy) void (^likeHandle)(BOOL isSelected);
@property (nonatomic, copy) void (^collectHandle)(BOOL isCollected);
@property (nonatomic, copy) void (^commentHandle)(void);
@property (nonatomic, copy) void (^relatedHandle)(BOOL isSelected);

- (void)setLikeNumber:(NSString *)likeNumber isMyLiked:(BOOL)isMyLiked;
- (void)setCommentNumber:(NSString *)commentNumber;
- (void)setCollectNumber:(NSString *)collectNumber isCollect:(BOOL)isCollect;
- (void)setRelateUnselected;

+ (CGFloat)defaultHeight;


@end
