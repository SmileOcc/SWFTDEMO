//
//  ZFCommunityPostDetailWriteCommentView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ZFCommunityPostDetailWriteCommentView : UICollectionReusableView

@property (nonatomic, copy) void (^textBlock)(NSString *text);
@property (nonatomic, copy) void (^confirmBlock)(void);
@property (nonatomic, copy) void (^textTapBlock)(void);



@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton    *textButton;


- (void)configWithImageUrl:(NSString *)imageString text:(NSString *)text;

+ (ZFCommunityPostDetailWriteCommentView *)writeCommentHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

