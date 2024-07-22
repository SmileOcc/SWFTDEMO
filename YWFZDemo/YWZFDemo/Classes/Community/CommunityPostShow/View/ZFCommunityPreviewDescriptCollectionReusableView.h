//
//  ZFCommunityPreviewDescriptCollectionReusableView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFCommunityPreviewDescriptCollectionReusableView : UICollectionReusableView

+ (ZFCommunityPreviewDescriptCollectionReusableView *)descriptWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;


// 设置值，赋值先后顺序赋值
- (void)setContentString:(NSString *)contentString;
- (void)setDeepLinkTitle:(NSString *)deeplinkTitle url:(NSString *)deeplinkUrl;
- (void)setTagArray:(NSArray *)tagArray;
- (void)setReadNumber:(NSString *)readNumber;
- (void)setPublishTime:(NSString *)time;

@end

