//
//  ZFCommentPostDetailMoreCommentView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommentPostDetailMoreCommentView : UICollectionReusableView


@property (nonatomic, copy) void (^tapMoreBlock)(void);

@property (nonatomic, strong) UIView         *mainView;

@property (nonatomic, strong) UIButton       *moreButton;
@property (nonatomic, strong) UILabel        *infoLabel;
@property (nonatomic, strong) UIImageView    *arrowImageView;


- (void)configurateNums:(NSInteger)counts;

+ (ZFCommentPostDetailMoreCommentView *)commentPostDetailMoreCommentViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
