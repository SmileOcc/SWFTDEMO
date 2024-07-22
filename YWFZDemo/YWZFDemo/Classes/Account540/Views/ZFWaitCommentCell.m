//
//  ZFWaitCommentCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWaitCommentCell.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "BigClickAreaButton.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "GoodsDetailModel.h"
#import "ZFRRPLabel.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"
#import "ExchangeManager.h"

@interface ZFWaitCommentCell ()
@property (nonatomic, strong) UIView        *contentBgView;
@property (nonatomic, strong) UIImageView   *productImageView;
@property (nonatomic, strong) UILabel       *titleLabel;
//@property (nonatomic, strong) UIImageView   *pointImageView;
@property (nonatomic, strong) UILabel       *pointLabel;
//@property (nonatomic, strong) UIImageView   *rewardImageView;
//@property (nonatomic, strong) UILabel       *rewardLabel;
@property (nonatomic, strong) UIButton      *reviewButton;
@end

@implementation ZFWaitCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFC0xF2F2F2();
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setCommentModel:(ZFWaitCommentModel *)commentModel {
    _commentModel = commentModel;
    
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:commentModel.goods_thumb]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    
    self.pointLabel.text = ZFToString(commentModel.point_msg);
    self.titleLabel.text = ZFToString(commentModel.goods_title);
    
    
    if (!commentModel.pointsAttr) {
        
        UIImage *pointsImage = [UIImage imageNamed:@"comment_points"];
        CGFloat height = [@"xxx" sizeWithAttributes:@{NSFontAttributeName: self.pointLabel.font}].height;
        CGFloat pointY = (18 - height) / 2.0 + 1;
        
        NSMutableAttributedString *attstring;
        
        NSString *youhuilv = ZFToString(self.commentModel.coupon_msg.youhuilv);
        NSString *fangshi = ZFToString(self.commentModel.coupon_msg.fangshi);
        NSString *pontsMsg = ZFToString(_commentModel.point_msg);
        NSString *couponMsg = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv fangshi:fangshi];
        
        NSString *contentString;
        if (!ZFIsEmptyString(youhuilv)) {
            contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_UP_XXPoints_XXCoupon", nil),pontsMsg,couponMsg];
            
            attstring = [[NSMutableAttributedString alloc] initWithString:contentString];
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = pointsImage;
            attach.bounds = CGRectMake(0, -pointY, height, height);
            
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attstring insertAttributedString:imageStr atIndex:0];
            
            
            NSRange range = [NSStringUtils rangeSpecailString:attstring.string specialString:@"+"];
            NSInteger rewardIndex = -100;
            if (range.location != NSNotFound) {
                rewardIndex = range.location;
            }
            
            if (rewardIndex >= 0) {
                
                UIImage *rewardImage = [UIImage imageNamed:@"commit_reward"];
                NSTextAttachment *rewardAttach = [[NSTextAttachment alloc] init];
                rewardAttach.image = rewardImage;
                
                rewardAttach.bounds = CGRectMake(0, -pointY, height, height);
                
                NSAttributedString *rewardImageStr = [NSAttributedString attributedStringWithAttachment:rewardAttach];
                [attstring insertAttributedString:rewardImageStr atIndex:rewardIndex+1];
            }
            
        } else {
            contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_UP_XXPoints", nil),pontsMsg];
            
            attstring = [[NSMutableAttributedString alloc] initWithString:contentString];

            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = pointsImage;
            attach.bounds = CGRectMake(0, -pointY, height, height);
            
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attstring insertAttributedString:imageStr atIndex:0];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        if ([SystemConfigUtils isRightToLeftShow]) {
            paragraphStyle.alignment = NSTextAlignmentRight;
        }
        [paragraphStyle setLineSpacing:4];  // 设置行距
        [attstring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attstring.string.length)];

        commentModel.pointsAttr = attstring;
    }
    
    self.pointLabel.attributedText = commentModel.pointsAttr;
    
}

- (void)reviewButtonAction {
    if (self.touchReviewBlock) {
        self.touchReviewBlock(self.commentModel);
    }
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    [self.contentView addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.productImageView];
    [self.contentBgView addSubview:self.titleLabel];
//    [self.contentBgView addSubview:self.pointImageView];
    [self.contentBgView addSubview:self.pointLabel];
//    [self.contentBgView addSubview:self.rewardImageView];
//    [self.contentBgView addSubview:self.rewardLabel];
    [self.contentBgView addSubview:self.reviewButton];
}

- (void)zfAutoLayoutView {
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(6, 12, 6, 12));
    }];
    
    [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self.contentBgView).mas_offset(16);
        make.size.mas_offset(CGSizeMake(60, 80));
    }];
    
    self.titleLabel.preferredMaxLayoutWidth = KScreenWidth - (12 + 16+ 5) * 2;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productImageView.mas_top);
        make.leading.mas_equalTo(self.productImageView.mas_trailing).mas_offset(5);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).mas_offset(-16);
    }];
    
//    [self.pointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
//        make.leading.mas_equalTo(self.titleLabel.mas_leading);
//        make.size.mas_offset(CGSizeMake(18, 18));
//    }];
    
    [self.pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).mas_offset(-16);
    }];
    
//    [self.rewardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.pointImageView.mas_bottom).offset(3);
//        make.leading.mas_equalTo(self.titleLabel.mas_leading);
//        make.size.mas_offset(CGSizeMake(18, 18));
//    }];
//
//    [self.rewardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.rewardImageView.mas_centerY);
//        make.leading.mas_equalTo(self.rewardImageView.mas_trailing).offset(5);
//        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).mas_offset(-16);
//    }];
    
    [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentBgView.mas_bottom).offset(-10);
        make.height.mas_offset(25);
    }];
}

#pragma mark - Getter

- (UIView *)contentBgView{
    if (!_contentBgView) {
        _contentBgView = [[UIView alloc] init];
        _contentBgView.backgroundColor = ZFCOLOR_WHITE;
        _contentBgView.layer.cornerRadius = 8;
        _contentBgView.layer.masksToBounds = YES;
        _contentBgView.clipsToBounds = YES;
    }
    return _contentBgView;
}

- (UIImageView *)productImageView{
    if (!_productImageView) {
        _productImageView = [[UIImageView alloc] init];
        _productImageView.contentMode = UIViewContentModeScaleAspectFill;
        _productImageView.clipsToBounds = YES;
    }
    return _productImageView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

//- (UIImageView *)pointImageView{
//    if (!_pointImageView) {
//        _pointImageView = [[UIImageView alloc] init];
//        _pointImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _pointImageView.image = [UIImage imageNamed:@"comment_points"];
//    }
//    return _pointImageView;
//}

-(UILabel *)pointLabel {
    if (!_pointLabel) {
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _pointLabel.font = [UIFont boldSystemFontOfSize:12];
        _pointLabel.numberOfLines = 2;
    }
    return _pointLabel;
}

//- (UIImageView *)rewardImageView{
//    if (!_rewardImageView) {
//        _rewardImageView = [[UIImageView alloc] init];
//        _rewardImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _rewardImageView.image = [UIImage imageNamed:@"commit_reward"];
//    }
//    return _rewardImageView;
//}

//-(UILabel *)rewardLabel {
//    if (!_rewardLabel) {
//        _rewardLabel = [[UILabel alloc] init];
//        _rewardLabel.textColor = ZFC0xFE5269();
//        _rewardLabel.font = [UIFont systemFontOfSize:12];
//    }
//    return _rewardLabel;
//}

- (UIButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reviewButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reviewButton setBackgroundColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_reviewButton addTarget:self action:@selector(reviewButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_reviewButton setTitle:ZFLocalizedString(@"Order_Review_Btn", nil) forState:0];
        [_reviewButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _reviewButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        _reviewButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _reviewButton.layer.cornerRadius = 2;
        _reviewButton.layer.masksToBounds = YES;
        _reviewButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1).CGColor;
        _reviewButton.layer.borderWidth = 1;
    }
    return _reviewButton;
}

@end

