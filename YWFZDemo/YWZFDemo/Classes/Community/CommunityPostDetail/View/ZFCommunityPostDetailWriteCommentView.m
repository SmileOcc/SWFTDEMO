//
//  ZFCommunityPostDetailWriteCommentView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailWriteCommentView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "SystemConfigUtils.h"

@interface ZFCommunityPostDetailWriteCommentView ()<ZFInitViewProtocol,UITextFieldDelegate>

@end

@implementation ZFCommunityPostDetailWriteCommentView

+ (ZFCommunityPostDetailWriteCommentView *)writeCommentHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifer];
    ZFCommunityPostDetailWriteCommentView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifer forIndexPath:indexPath];
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)configWithImageUrl:(NSString *)imageString text:(NSString *)text {
    
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:imageString]
    placeholder:[UIImage imageNamed:@"public_user"]
        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
       progress:nil
      transform:^UIImage *(UIImage *image, NSURL *url) {
          if ([image isKindOfClass:[YYImage class]]) {
              YYImage *showImage = (YYImage *)image;
              if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                  return image;
              }
          }
          return [image zf_imageByResizeToSize:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFill];
      }
     completion:nil];
    
    self.textField.text = ZFToString(text);
}


- (void)zfInitView {
    [self addSubview:self.userImageView];
    [self addSubview:self.textField];
    [self addSubview:self.textButton];
}

- (void)zfAutoLayoutView {
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(6);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.height.mas_equalTo(32);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.textButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(6);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.height.mas_equalTo(32);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.textBlock) {
        self.textBlock(textField.text);
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.textBlock) {
        self.textBlock(@"");
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (self.confirmBlock) {
        self.confirmBlock();
    }
    return YES;
}

- (void)actionText:(UIButton *)sender {
    if (self.textTapBlock) {
        self.textTapBlock();
    }
}

#pragma mark - Property Method

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 16;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.delegate = self;
        _textField.placeholder = [NSString stringWithFormat:@"  %@",ZFLocalizedString(@"Community_Post_Detail_CommentQuestion", nil)];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.layer.cornerRadius = 3;
        _textField.layer.masksToBounds = YES;
        _textField.backgroundColor = ZFC0xF2F2F2();
        _textField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;

    }
    return _textField;
}

- (UIButton *)textButton {
    if (!_textButton) {
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textButton;
}
@end
