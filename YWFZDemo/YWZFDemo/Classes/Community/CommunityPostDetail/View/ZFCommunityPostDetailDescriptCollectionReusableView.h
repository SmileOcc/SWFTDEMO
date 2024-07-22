//
//  ZFCommunityPostDetailDescriptCollectionReusableView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityPostDetailDescriptCollectionReusableView : UICollectionReusableView

@property (nonatomic, copy) void (^tagActionHandle)(NSString *tagString);
@property (nonatomic, copy) void (^deeplinkHandle)(NSString *deeplinkUrl);

+ (ZFCommunityPostDetailDescriptCollectionReusableView *)descriptWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// 设置值，赋值先后顺序赋值
- (void)setContentString:(NSString *)contentString;
- (void)setDeepLinkTitle:(NSString *)deeplinkTitle url:(NSString *)deeplinkUrl;
- (void)setTagArray:(NSArray *)tagArray;
- (void)setReadNumber:(NSString *)readNumber;
- (void)setPublishTime:(NSString *)time;

@end
