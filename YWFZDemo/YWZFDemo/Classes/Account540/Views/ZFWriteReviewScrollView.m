//
//  ZFWriteReviewScrollView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWriteReviewScrollView.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "BigClickAreaButton.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "StarRatingControl.h"
#import "ZFRRPLabel.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFButton.h"
#import "Constants.h"
#import "ZFReviewPhotoView.h"
#import "ZFReviewPropertyView.h"
#import "ZFReviewsMarkView.h"
#import "NSString+Extended.h"
#import "ZFWaitCommentModel.h"
#import "NSStringUtils.h"
#import "UIImage+ZFExtended.h"

@interface ZFWriteReviewScrollView ()<UITextViewDelegate, StarRatingDelegate>
@property (nonatomic, strong) UIView                                *goodsInfoBgView;
@property (nonatomic, strong) UIImageView                           *goodsImageView;
@property (nonatomic, strong) UILabel                               *goodsTitleLabel;
@property (nonatomic, strong) UILabel                               *goodsSizeLabel;
@property (nonatomic, strong) UIButton                              *writeReviewBtn;
@property (nonatomic, strong) UILabel                               *overallFitLabel;
@property (nonatomic, strong) UIButton                              *trueSizeButton;
@property (nonatomic, strong) UIButton                              *smallButton;
@property (nonatomic, strong) UIButton                              *largeButton;
@property (nonatomic, strong) UIButton                              *tempChooseButton;
@property (nonatomic, strong) UILabel                               *ratingLabel;
@property (nonatomic, strong) StarRatingControl                     *starView;
@property (nonatomic, strong) UILabel                               *contentLabel;
@property (nonatomic, strong) UILabel                               *inputPlacehoderLabel;
@property (nonatomic, strong) UITextView                            *inputTextView;
@property (nonatomic, strong) ZFReviewsMarkView                     *markContentView;
@property (nonatomic, strong) UIView                                *emptyLineView1;
@property (nonatomic, strong) UILabel                               *myShowTipLabel;
@property (nonatomic, strong) ZFReviewPhotoView                     *photoContentView;
@property (nonatomic, strong) UIButton                              *uploadZmeButton;
@property (nonatomic, strong) UIView                                *emptyLineView2;
@property (nonatomic, strong) ZFButton                              *showInfoButton;
@property (nonatomic, strong) ZFReviewPropertyView                  *showInfoContentView;
@property (nonatomic, strong) UIButton                              *submitButton;
@property (nonatomic, assign) NSInteger                             inputTextLength;
@property (nonatomic, strong) UILabel                               *countLabel;
@end

@implementation ZFWriteReviewScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)scrollViewSubButtonAction:(UIButton *)button {
    if (button.tag < 2019) return;
    id object = nil;
    
    if (button.tag == ZFWriteReviewAction_TrueSizeType
        || button.tag == ZFWriteReviewAction_SmallType
        || button.tag == ZFWriteReviewAction_LargeType) {
        self.tempChooseButton.selected = NO;
        self.tempChooseButton = button;
        object = @(button.tag - 2019);
    }
    
    if (button.tag == ZFWriteReviewAction_ShowInfoType) {
        [self changeArrowStatus:button];
    } else {
        button.selected = !button.selected;
    }
    
    if (button.tag == ZFWriteReviewAction_UploadZmeType) {
        object = @(button.selected);
    }
    YWLog(@"scrollViewSubButtonAction==%@", button);
    if (self.reviewBtnActionBlock) {
        self.reviewBtnActionBlock(button.tag, object);
    }
}

- (void)changeArrowStatus:(UIButton *)button {
    if (![button isKindOfClass:[UIButton class]]) return;
    if (button.selected) {
        self.showInfoContentView.hidden = NO;
    }
    [self.showInfoContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.showInfoButton.mas_bottom).offset(0);
        make.leading.trailing.mas_equalTo(self.goodsInfoBgView);
        if (!button.selected) {
            make.height.mas_equalTo(0);//做动画
        }
    }];
    [UIView animateWithDuration:0.2f animations:^{
        if (button.selected) {
            button.imageView.transform = CGAffineTransformIdentity;
        } else {
            button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        button.selected = !button.selected;
        self.showInfoContentView.hidden = button.selected;
    }];
}

- (void)setSelectedPropertyHandler:(void (^)(ZFReviewPropertyView *, ZFReviewPropertyType))selectedPropertyHandler {
    _selectedPropertyHandler = selectedPropertyHandler;
    self.showInfoContentView.selectedPropertyHandler = selectedPropertyHandler;
}

- (void)setDeleteImageActionBlock:(void (^)(NSInteger))deleteImageActionBlock {
    _deleteImageActionBlock = deleteImageActionBlock;
    self.photoContentView.deleteImageActionBlock = self.deleteImageActionBlock;
}

- (void)setReviewModel:(ZFOrderReviewModel *)reviewModel {
    _reviewModel = reviewModel;
    
    @weakify(self);
    [self.markContentView refreshReviewsMark:reviewModel handlerHeight:^(CGFloat height) {
        @strongify(self);
        [self.markContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(height);
        }];
    }];
    
    [self.writeReviewBtn setAttributedTitle:[self myReviewPointsCoupon] forState:UIControlStateNormal];
    self.myShowTipLabel.attributedText = [self myPictureShowReviewPointsCoupon];
    [self.showInfoContentView configurateExtrePoint:[self myInfoFirst]];
}

- (void)setDefaultSizeModeValue:(NSArray *)defaultSizeModelArray {
    BOOL hasSelected = [self.showInfoContentView setDefaultValue:defaultSizeModelArray];
    if (hasSelected) {
        self.showInfoButton.selected = YES;
        self.showInfoButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        self.showInfoContentView.hidden = hasSelected;
        [self.showInfoContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.showInfoButton.mas_bottom).offset(0);
            make.leading.trailing.mas_equalTo(self.goodsInfoBgView);
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)setCommentModel:(ZFWaitCommentModel *)commentModel{
    _commentModel = commentModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:commentModel.goods_thumb]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    
    self.goodsTitleLabel.text = ZFToString(commentModel.goods_title);
    self.goodsSizeLabel.text = ZFToString(commentModel.goods_attr_str);
}

- (NSAttributedString *)myReviewPointsCoupon {
    
    UIImage *pointsImage = [UIImage imageNamed:@"comment_points"];
    UIImage *rewardImage = [UIImage imageNamed:@"commit_reward"];
    
    
    NSMutableAttributedString *attstring;
    
    CGFloat height = [@"xxx" sizeWithAttributes:@{NSFontAttributeName: self.writeReviewBtn.titleLabel.font}].height;
    CGFloat pointY = (18 - height) / 2.0 + 3;

    NSString *youhuilv = ZFToString(self.reviewModel.goods_info.review_coupon.youhuilv);
    NSString *fangshi = ZFToString(self.reviewModel.goods_info.review_coupon.fangshi);
    NSString *pontsMsg = ZFToString(self.reviewModel.goods_info.review_point);
    NSString *couponMsg = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv fangshi:fangshi];
        
    NSString *contentString;
    if (!ZFIsEmptyString(youhuilv)) {
        contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Edit_Text_XXPoints_XXCoupon", nil),pontsMsg,couponMsg];
        
        attstring = [[NSMutableAttributedString alloc] initWithString:contentString];
        
        NSRange range = [NSStringUtils rangeSpecailString:attstring.string specialString:@"+"];
        NSInteger rewardIndex = -100;
        if (range.location != NSNotFound) {
            rewardIndex = range.location;
        }
        
        // 图加在+位置之前
        if (rewardIndex >= 0) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = pointsImage;
            attach.bounds = CGRectMake(0, -pointY, height, height);
            
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attstring insertAttributedString:imageStr atIndex:rewardIndex];
        }
        
        // 图加在最后位置
        NSTextAttachment *rewardAttach = [[NSTextAttachment alloc] init];
        rewardAttach.image = rewardImage;
        
        rewardAttach.bounds = CGRectMake(0, -pointY, height, height);
        
        NSAttributedString *rewardImageStr = [NSAttributedString attributedStringWithAttachment:rewardAttach];
        [attstring insertAttributedString:rewardImageStr atIndex:attstring.string.length];

    } else {
        
        contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Edit_Text_XXPoints", nil),pontsMsg];
        
        attstring = [[NSMutableAttributedString alloc] initWithString:contentString];
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = pointsImage;
        attach.bounds = CGRectMake(0, -pointY, height, height);
        
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
        [attstring insertAttributedString:imageStr atIndex:attstring.string.length];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    }
    [paragraphStyle setLineSpacing:4];  // 设置行距
    [attstring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attstring.string.length)];
    
    return attstring;
}

- (NSAttributedString *)myPictureShowReviewPointsCoupon {
    
    UIImage *pointsImage = [UIImage imageNamed:@"comment_points"];
    UIImage *rewardImage = [UIImage imageNamed:@"commit_reward"];
    
    CGFloat height = [@"xxx" sizeWithAttributes:@{NSFontAttributeName: self.myShowTipLabel.font}].height;
    CGFloat pointY = (18 - height) / 2.0 + 3;
    
    NSMutableAttributedString *attstring;
    
    NSString *youhuilv = ZFToString(self.reviewModel.goods_info.review_show_extra_coupon.youhuilv);
    NSString *fangshi = ZFToString(self.reviewModel.goods_info.review_show_extra_coupon.fangshi);
    NSString *pontsMsg = ZFToString(self.reviewModel.goods_info.review_show_extra_point);
    NSString *couponMsg = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv fangshi:fangshi];
        

    NSString *contentString;
    if (!ZFIsEmptyString(youhuilv)) {
        contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Edit_Picture_XXPoints_XXCoupon", nil),pontsMsg,couponMsg];
        attstring = [[NSMutableAttributedString alloc] initWithString:contentString];
        
        NSRange range = [NSStringUtils rangeSpecailString:attstring.string specialString:@"+"];
        NSInteger rewardIndex = -100;
        if (range.location != NSNotFound) {
            rewardIndex = range.location;
        }
        
        // 图加在+位置之前
        if (rewardIndex >= 0) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = pointsImage;
            attach.bounds = CGRectMake(0, -pointY, height, height);
            
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attstring insertAttributedString:imageStr atIndex:rewardIndex];
        }
        
        // 图加在最后位置
        NSTextAttachment *rewardAttach = [[NSTextAttachment alloc] init];
        rewardAttach.image = rewardImage;
        
        rewardAttach.bounds = CGRectMake(0, -pointY, height, height);
        
        NSAttributedString *rewardImageStr = [NSAttributedString attributedStringWithAttachment:rewardAttach];
        [attstring insertAttributedString:rewardImageStr atIndex:attstring.string.length];
        
    } else {
        contentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Edit_Picture_XXPoints", nil),pontsMsg];
        attstring = [[NSMutableAttributedString alloc] initWithString:contentString];
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = pointsImage;
        attach.bounds = CGRectMake(0, -pointY, height, height);
        
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
        [attstring insertAttributedString:imageStr atIndex:attstring.string.length];
    }
    
    NSAttributedString *myShowAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:",ZFLocalizedString(@"Order_Comment_My_Show", nil)] attributes:@{NSForegroundColorAttributeName:ZFC0x2D2D2D(),NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}];
    [attstring insertAttributedString:myShowAtt atIndex:0];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    if ([SystemConfigUtils isRightToLeftShow]) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    }
    [paragraphStyle setLineSpacing:4];  // 设置行距
    [attstring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attstring.string.length)];
    
    return attstring;
}

- (NSAttributedString *)myInfoFirst {
    
    UIImage *pointsImage = [UIImage imageNamed:@"comment_points"];

    NSString *pontsMsg = ZFToString(_reviewModel.goods_info.review_info_extra_point);
    NSString *imageContentString =  [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_First_Bonus_XXPoints", nil),pontsMsg];
    
    NSMutableAttributedString *imageAttstring = [[NSMutableAttributedString alloc] initWithString:imageContentString];
    
    CGFloat imageHeight = [@"xxx" sizeWithAttributes:@{NSFontAttributeName: self.showInfoButton.titleLabel.font}].height;
    
    CGFloat imagePointY = (18 - imageHeight) / 2.0 + 3;
    
    NSTextAttachment *imageAttach = [[NSTextAttachment alloc] init];
    imageAttach.image = pointsImage;
    imageAttach.bounds = CGRectMake(0, -imagePointY, imageHeight, imageHeight);
    
    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:imageAttach];
    [imageAttstring insertAttributedString:imageStr atIndex:imageAttstring.string.length];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    if ([SystemConfigUtils isRightToLeftShow]) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    }
    [paragraphStyle setLineSpacing:4];  // 设置行距
    [imageAttstring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, imageAttstring.string.length)];

    return imageAttstring;
}

- (void)setPhotosArray:(NSArray *)photosArray {
    _photosArray = photosArray;
    self.photoContentView.photosArray = photosArray;
}

- (NSDictionary *)selectedBodySize {
    return [self.showInfoContentView selectBodySize];
}

#pragma mark - <StarRatingDelegate>
- (void)newRating:(StarRatingControl *)control :(float)rating {
    if (self.reviewBtnActionBlock) {
        self.reviewBtnActionBlock(ZFWriteReviewAction_ChooseRatingType, @(rating));
    }
}

#pragma mark - action methods
- (void)intputViewChangeNotification:(id)notification {
    if (self.inputTextView.text.length > 300) {
        self.inputTextView.text = [self.inputTextView.text substringToIndex:300];
    }
    self.inputTextLength = self.inputTextView.text.length;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/300", self.inputTextLength];
    self.inputPlacehoderLabel.hidden = (self.inputTextView.text.length>0);
    self.inputTextView.scrollsToTop = YES;
    
    if (self.reviewBtnActionBlock) {
        self.reviewBtnActionBlock(ZFWriteReviewAction_InputReviewType, self.inputTextView.text);
    }
}

#pragma mark - <UITextViewDelegate>

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self intputViewChangeNotification:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (ZFIsEmptyString(text)) {
        self.inputTextLength--;
        return YES;
    }
    [self intputViewChangeNotification:nil];
    return self.inputTextLength < 300;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self intputViewChangeNotification:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self performSelector:@selector(textViewDidChange:) withObject:textView afterDelay:0.1f];
}

#pragma mark -<ZFInitViewProtocol>

- (void)zfInitView {
    [self addSubview:self.goodsInfoBgView];
    [self.goodsInfoBgView addSubview:self.goodsImageView];
    [self.goodsInfoBgView addSubview:self.goodsTitleLabel];
    [self.goodsInfoBgView addSubview:self.goodsSizeLabel];
    
    [self addSubview:self.writeReviewBtn];
    [self addSubview:self.overallFitLabel];
    [self addSubview:self.trueSizeButton];
    [self addSubview:self.smallButton];
    [self addSubview:self.largeButton];
    [self addSubview:self.ratingLabel];
    [self addSubview:self.starView];
    [self addSubview:self.contentLabel];
    [self addSubview:self.inputTextView];
    [self addSubview:self.inputPlacehoderLabel];
    [self addSubview:self.countLabel];
    [self addSubview:self.markContentView];
    [self addSubview:self.emptyLineView1];
    [self addSubview:self.myShowTipLabel];
    [self addSubview:self.photoContentView];
    [self addSubview:self.uploadZmeButton];
    [self addSubview:self.emptyLineView2];
    [self addSubview:self.showInfoButton];
    [self addSubview:self.showInfoContentView];
    [self addSubview:self.submitButton];
}

- (void)zfAutoLayoutView {
    [self.goodsInfoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(6);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.width.mas_equalTo(KScreenWidth-16*2);
    }];

    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsInfoBgView.mas_top).offset(6);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading).offset(8);
        make.bottom.mas_equalTo(self.goodsInfoBgView.mas_bottom).offset(-6);
        make.size.mas_equalTo(CGSizeMake(42, 56));
    }];

    [self.goodsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(8);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing).offset(-8);
        make.bottom.mas_equalTo(self.goodsImageView.mas_centerY).offset(-1);
    }];

    [self.goodsSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsTitleLabel.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing).offset(-8);
        make.top.mas_equalTo(self.goodsTitleLabel.mas_bottom).offset(4);
    }];
    
    [self.writeReviewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsInfoBgView.mas_bottom).offset(15);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
    }];
    
    [self.overallFitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.writeReviewBtn.mas_bottom).offset(15);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
    }];
    
    CGFloat btnWidth = (KScreenWidth - 16 * 2)/3;
    [self.trueSizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallFitLabel.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(btnWidth, 36));
    }];
    
    [self.smallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallFitLabel.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.trueSizeButton.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(btnWidth, 36));
    }];
    
    [self.largeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallFitLabel.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.smallButton.mas_trailing);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.height.mas_equalTo(36);
    }];
    
    [self.ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.trueSizeButton.mas_bottom).offset(17);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
    }];
    
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.ratingLabel.mas_centerY);
        make.leading.mas_equalTo(self.ratingLabel.mas_trailing).offset(5);
        make.size.mas_equalTo(CGSizeMake(170, 30));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.ratingLabel.mas_bottom).offset(22);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(9);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
        make.height.mas_equalTo(104);
    }];
    
    [self.inputPlacehoderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputTextView.mas_top).offset(12);
        make.leading.mas_equalTo(self.inputTextView.mas_leading).offset(8);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.inputTextView.mas_bottom).offset(-4);
        make.trailing.mas_equalTo(self.inputTextView.mas_trailing).offset(-6);
    }];
    
    [self.markContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputTextView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
        make.height.mas_greaterThanOrEqualTo(28);
    }];
    
    [self.emptyLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.markContentView.mas_bottom).offset(16);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(12);
    }];
    
    [self.myShowTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyLineView1.mas_bottom).offset(13);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
    }];
    
    [self.photoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myShowTipLabel.mas_bottom).offset(9);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading).offset(-16);//要向左偏移16因为占位icon左间距
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
        make.height.mas_greaterThanOrEqualTo(80);
    }];
    
    [self.uploadZmeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.photoContentView.mas_bottom).offset(11);
        make.leading.mas_equalTo(self.goodsInfoBgView.mas_leading);
        make.trailing.mas_equalTo(self.goodsInfoBgView.mas_trailing);
    }];
    
    [self.emptyLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.uploadZmeButton.mas_bottom).offset(12);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(12);
    }];
    
    [self.showInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyLineView2.mas_bottom).offset(7);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(34);
    }];
    
    [self.showInfoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.showInfoButton.mas_bottom).offset(0);
        make.leading.trailing.mas_equalTo(self.goodsInfoBgView);
        //make.height.mas_equalTo(141);//内容自动撑高
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.showInfoContentView.mas_bottom).offset(16);
        make.leading.trailing.mas_equalTo(self.goodsInfoBgView);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
    }];
}

#pragma mark - Getter

- (UIView *)goodsInfoBgView {
    if (!_goodsInfoBgView) {
        _goodsInfoBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _goodsInfoBgView.backgroundColor = ZFC0xF2F2F2();
        _goodsInfoBgView.clipsToBounds = YES;
    }
    return _goodsInfoBgView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _goodsImageView.image = [UIImage imageNamed:@"letter_activityBg"];
    }
    return _goodsImageView;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel) {
        _goodsTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTitleLabel.font = [UIFont systemFontOfSize:14];
        _goodsTitleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _goodsTitleLabel.preferredMaxLayoutWidth = KScreenWidth - 16 * 2;
        //_goodsTitleLabel.text = @"Belted Flare Sleev Floral Floral";
    }
    return _goodsTitleLabel;
}

- (UILabel *)goodsSizeLabel {
    if (!_goodsSizeLabel) {
        _goodsSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsSizeLabel.font = [UIFont systemFontOfSize:12];
        _goodsSizeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        //_goodsSizeLabel.text = @"Blue/XL";
    }
    return _goodsSizeLabel;
}

- (UIButton *)writeReviewBtn {
    if (!_writeReviewBtn) {
        _writeReviewBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _writeReviewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_writeReviewBtn setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _writeReviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else {
            _writeReviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        _writeReviewBtn.adjustsImageWhenHighlighted = NO;
        _writeReviewBtn.titleLabel.numberOfLines = 2;
    }
    return _writeReviewBtn;
}

- (UILabel *)overallFitLabel {
    if (!_overallFitLabel) {
        _overallFitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _overallFitLabel.font = [UIFont systemFontOfSize:14];
        _overallFitLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        NSArray *textArray = @[@"*", ZFLocalizedString(@"Reviews_OverallFit", nil)];
        NSArray *fontArray = @[ZFFontSystemSize(14)];
        NSArray *colorArray = @[ZFCOLOR(254, 82, 105, 1), ZFCOLOR(45, 45, 45, 1)];
        _overallFitLabel.attributedText = [NSString getAttriStrByTextArray:textArray
                                                                      fontArr:fontArray
                                                                     colorArr:colorArray
                                                                  lineSpacing:0
                                                                    alignment:3];
    }
    return _overallFitLabel;
}

- (UIButton *)trueSizeButton {
    if (!_trueSizeButton) {
        _trueSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trueSizeButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        _trueSizeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_trueSizeButton setTitle:ZFLocalizedString(@"OverallFit_TrueToSize", nil) forState:0];
        [_trueSizeButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
        UIImage *image = [[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()];
        [_trueSizeButton setImage:image forState:UIControlStateSelected];
        [_trueSizeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
        [_trueSizeButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _trueSizeButton.selected = YES;
        _trueSizeButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//标题过长换行
        _trueSizeButton.tag = ZFWriteReviewAction_TrueSizeType;
         self.tempChooseButton = _trueSizeButton;
        
    }
    return _trueSizeButton;
}

- (UIButton *)smallButton {
    if (!_smallButton) {
        _smallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_smallButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        _smallButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_smallButton setTitle:ZFLocalizedString(@"OverallFit_Small", nil) forState:0];
        [_smallButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
        UIImage *image = [[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()];
        [_smallButton setImage:image forState:UIControlStateSelected];
        [_smallButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
        
        [_smallButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _smallButton.tag = ZFWriteReviewAction_SmallType;
    }
    return _smallButton;
}

- (UIButton *)largeButton {
    if (!_largeButton) {
        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_largeButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        _largeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_largeButton setTitle:ZFLocalizedString(@"OverallFit_Large", nil) forState:0];
        [_largeButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
        UIImage *image = [[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()];
        [_largeButton setImage:image forState:UIControlStateSelected];
        [_largeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
        
        [_largeButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _largeButton.tag = ZFWriteReviewAction_LargeType;
    }
    return _largeButton;
}

- (UILabel *)ratingLabel {
    if (!_ratingLabel) {
        _ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ratingLabel.font = [UIFont systemFontOfSize:14];
        _ratingLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        NSArray *textArray = @[@"*", ZFLocalizedString(@"WriteReview_Rating", nil)];
        NSArray *fontArray = @[ZFFontSystemSize(14)];
        NSArray *colorArray = @[ZFCOLOR(254, 82, 105, 1), ZFCOLOR(45, 45, 45, 1)];
        _ratingLabel.attributedText = [NSString getAttriStrByTextArray:textArray
                                                               fontArr:fontArray
                                                              colorArr:colorArray
                                                           lineSpacing:0
                                                             alignment:3];
    }
    return _ratingLabel;
}

- (StarRatingControl *)starView {
    if (!_starView) {
        UIImage *dImage = [UIImage imageNamed:@"starNormal"];
        UIImage *hImage = [UIImage imageNamed:@"starHigh"];
        _starView = [[StarRatingControl alloc] initWithFrame:CGRectZero
                                         andDefaultStarImage:dImage
                                             highlightedStar:hImage];
        _starView.enabled = YES;
        _starView.delegate = self;
        _starView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _starView.rating = 5.f;
    }
    return _starView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        NSArray *textArray = @[@"*", ZFLocalizedString(@"WriteReview_Content", nil)];
        NSArray *fontArray = @[ZFFontSystemSize(14)];
        NSArray *colorArray = @[ZFCOLOR(254, 82, 105, 1), ZFCOLOR(45, 45, 45, 1)];
        _contentLabel.attributedText = [NSString getAttriStrByTextArray:textArray
                                                               fontArr:fontArray
                                                              colorArr:colorArray
                                                           lineSpacing:0
                                                             alignment:3];
    }
    return _contentLabel;
}

- (UILabel *)inputPlacehoderLabel {
    if (!_inputPlacehoderLabel) {
        _inputPlacehoderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _inputPlacehoderLabel.font = [UIFont systemFontOfSize:14];
        _inputPlacehoderLabel.textColor = ZFCOLOR(204, 204, 204, 1);
        _inputPlacehoderLabel.text = ZFLocalizedString(@"WriteReview_Textfiled_Placeholder", nil);
    }
    return _inputPlacehoderLabel;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _inputTextView.backgroundColor = ZFC0xF7F7F7();
//        _inputTextView.layer.borderWidth = .5f;
//        _inputTextView.layer.borderColor = ZFCOLOR(153, 153, 153, 1.f).CGColor;
        _inputTextView.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 25, 5);
        _inputTextView.font = [UIFont systemFontOfSize:12];
        _inputTextView.delegate = self;
        _inputTextView.directionalLockEnabled = YES;
        _inputTextView.showsHorizontalScrollIndicator = NO;
        _inputTextView.showsVerticalScrollIndicator = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intputViewChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return _inputTextView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.text = @"0/300";
    }
    return _countLabel;
}

- (ZFReviewsMarkView *)markContentView {
    if (!_markContentView) {
        _markContentView = [[ZFReviewsMarkView alloc] initWithFrame:CGRectZero];
        _markContentView.backgroundColor = ZFC0xF7F7F7();
        @weakify(self);
        _markContentView.selectedMarkHandler = ^(NSString *mark, BOOL selecte) {
            @strongify(self)
        
            if (self.inputTextView.text.length < 300) {
                NSString *kkText = [NSString stringWithFormat:@" %@", ZFToString(mark)];
                if (selecte) {
                    self.inputTextView.text = [self.inputTextView.text stringByAppendingString:kkText];
                    
                } else if (self.inputTextView.text.length > 0) {
                    self.inputTextView.text = [self.inputTextView.text stringByReplacingOccurrencesOfString:kkText withString:@""];
                }
            }
            [self intputViewChangeNotification:nil];
        };
    }
    return _markContentView;
}

- (UIView *)emptyLineView1 {
    if (!_emptyLineView1) {
        _emptyLineView1 = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyLineView1.backgroundColor = ZFC0xF7F7F7();
    }
    return _emptyLineView1;
}

- (UILabel *)myShowTipLabel {
    if (!_myShowTipLabel) {
        _myShowTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _myShowTipLabel.font = [UIFont systemFontOfSize:14];
        _myShowTipLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _myShowTipLabel.numberOfLines = 0;
    }
    return _myShowTipLabel;
}

- (ZFReviewPhotoView *)photoContentView {
    if (!_photoContentView) {
        _photoContentView = [[ZFReviewPhotoView alloc] initWithFrame:CGRectZero];
        _photoContentView.backgroundColor = [UIColor whiteColor];
        @weakify(self)
        _photoContentView.addImageActionBlock = ^{
            @strongify(self)
            if (self.reviewBtnActionBlock) {
                self.reviewBtnActionBlock(ZFWriteReviewAction_AddImageType, nil);
            }
        };
        _photoContentView.showAddImageActionBlock = ^(NSInteger index, NSArray *rectArray){
            @strongify(self)
            if (self.showAddImageActionBlock) {
                self.showAddImageActionBlock(index, rectArray);
            }
        };
    }
    return _photoContentView;
}

- (UIButton *)uploadZmeButton {
    if (!_uploadZmeButton) {
        _uploadZmeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadZmeButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        _uploadZmeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [_uploadZmeButton setTitle:ZFLocalizedString(@"OrderReviewAgreeToZMe", nil) forState:0];
        [_uploadZmeButton setImage:[UIImage imageNamed:@"default_no"] forState:UIControlStateNormal];
        [_uploadZmeButton setImage:[UIImage imageNamed:@"default_ok"] forState:UIControlStateSelected];
        [_uploadZmeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _uploadZmeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else {
            _uploadZmeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        
        [_uploadZmeButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _uploadZmeButton.tag = ZFWriteReviewAction_UploadZmeType;
    }
    return _uploadZmeButton;
}

- (UIView *)emptyLineView2 {
    if (!_emptyLineView2) {
        _emptyLineView2 = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyLineView2.backgroundColor = ZFC0xF7F7F7();
    }
    return _emptyLineView2;
}

// 首次
- (ZFButton *)showInfoButton {
    if (!_showInfoButton) {
        _showInfoButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_showInfoButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        _showInfoButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_showInfoButton setTitle:[NSString stringWithFormat:@"%@:",ZFLocalizedString(@"Order_Comment_My_Info", nil)] forState:0];
        
        UIImage *normalImage = [UIImage imageNamed:@"cart_unavailable_arrow_up"];
        [_showInfoButton setImage:normalImage forState:UIControlStateNormal];
        CGFloat w = 15*1.2; CGFloat h = 10*1.2;
        _showInfoButton.titleRect = CGRectMake(16, 0, KScreenWidth-16*2, 34);
        _showInfoButton.imageRect = CGRectMake(KScreenWidth-(w+16), (34-h)/2, w, h);
        
        [_showInfoButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _showInfoButton.tag = ZFWriteReviewAction_ShowInfoType;
        
//        if ([SystemConfigUtils isRightToLeftShow]) {
//            _showInfoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        } else {
//            _showInfoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        }
    }
    return _showInfoButton;
}

- (ZFReviewPropertyView *)showInfoContentView {
    if (!_showInfoContentView) {
        _showInfoContentView = [[ZFReviewPropertyView alloc] initWithFrame:CGRectZero];
        _showInfoContentView.backgroundColor = [UIColor whiteColor];
    }
    return _showInfoContentView;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_submitButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_submitButton setBackgroundColor:ColorHex_Alpha(0xcccccc, 1) forState:UIControlStateDisabled];
        
        [_submitButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _submitButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _submitButton.layer.cornerRadius = 3;
        _submitButton.layer.masksToBounds = YES;
        
        NSString *title = [ZFLocalizedString(@"WriteReview_Submit", nil) uppercaseString];
        [_submitButton setTitle:title forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(scrollViewSubButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _submitButton.tag = ZFWriteReviewAction_SubmitType;
    }
    return _submitButton;
}

@end

