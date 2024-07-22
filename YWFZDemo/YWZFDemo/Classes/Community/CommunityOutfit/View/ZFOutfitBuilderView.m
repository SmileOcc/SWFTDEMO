//
//  ZFOutfitBuilderView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOutfitBuilderView.h"
#import "UIImage+ZFExtended.h"
#import "ZFOutfitBuilderSingleton.h"
#import "ZFInitViewProtocol.h"
#import "ZFSystemPhototHelper.h"
#import "ZFOutfitBuilderSingleton.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#import "UIView+ZFViewCategorySet.h"
#import "UIImage+ZFExtended.h"

//static CGFloat const kZFOutfitBuiderHeight = 72.0;
static CGFloat const kZFOutfitBuiderWidth = 100;
static CGFloat const kZFOutfitBuiderLeftSpace = 16.0;

@interface ZFOutfitBuilderView()<ZFInitViewProtocol>

@property (nonatomic, strong) ZFOutfitsWorkSpaceView         *canvasImageView;
@property (nonatomic, strong) UIView                         *borderLineView;
@property (nonatomic, strong) UIView                         *tipView;

@property (nonatomic, strong) UIView                         *bottomOperateView;

@property (nonatomic, strong) UIImageView                    *upImageView;
@property (nonatomic, strong) UILabel                        *upLabel;
@property (nonatomic, strong) UIButton                       *upButton;

@property (nonatomic, strong) UIImageView                    *downImageView;
@property (nonatomic, strong) UILabel                        *downLabel;
@property (nonatomic, strong) UIButton                       *downButton;

@property (nonatomic, strong) UIImageView                    *deleteImageView;
@property (nonatomic, strong) UILabel                        *deleteLabel;
@property (nonatomic, strong) UIButton                       *deleteButton;

@property (nonatomic, strong) UIButton                       *ruleButton;
@property (nonatomic, strong) UILabel                        *ruleLabel;
@property (nonatomic, strong) UIImageView                    *ruleArrowImageView;


@end

@implementation ZFOutfitBuilderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {

    [self addSubview:self.borderLineView];
    [self addSubview:self.canvasImageView];
    [self addSubview:self.tipView];
    [self addSubview:self.bottomOperateView];
    
    [self addSubview:self.deleteImageView];
    [self addSubview:self.deleteLabel];
    [self addSubview:self.deleteButton];
    
    [self addSubview:self.upImageView];
    [self addSubview:self.upLabel];
    [self addSubview:self.upButton];
    
    [self addSubview:self.downImageView];
    [self addSubview:self.downLabel];
    [self addSubview:self.downButton];
    
    [self addSubview:self.ruleButton];
    [self.ruleButton addSubview:self.ruleLabel];
    [self.ruleButton addSubview:self.ruleArrowImageView];
}

- (void)zfAutoLayoutView {
    
    [self.canvasImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(kZFOutfitBuiderLeftSpace);
        make.top.mas_equalTo(self.mas_top).mas_offset(kZFOutfitBuiderLeftSpace);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-kZFOutfitBuiderLeftSpace);
        make.height.mas_equalTo(self.canvasImageView.mas_width).multipliedBy(1.0);
    }];
    
    [self.borderLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(kZFOutfitBuiderLeftSpace - 1.0 );
        make.top.mas_equalTo(self.mas_top).mas_offset(kZFOutfitBuiderLeftSpace - 1.0);
        make.trailing.mas_equalTo(self.canvasImageView.mas_trailing).offset(1.0);
        make.bottom.mas_equalTo(self.canvasImageView.mas_bottom).offset(1.0);
    }];
    
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.canvasImageView);
    }];
    
    [self.bottomOperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.canvasImageView);
        make.top.mas_equalTo(self.canvasImageView.mas_bottom);
        make.height.mas_equalTo([ZFOutfitBuilderView bottomOperateHeight]);
    }];
    
    [self.downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomOperateView.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.downImageView.mas_bottom).mas_offset(7);
        make.centerX.mas_equalTo(self.downImageView.mas_centerX);
    }];
    
    [self.downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.downLabel.mas_bottom);
        make.top.mas_equalTo(self.downImageView.mas_top);
        make.centerX.mas_equalTo(self.downImageView.mas_centerX);
        make.width.mas_equalTo(kZFOutfitBuiderWidth);
    }];
    
    
    
    [self.upImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.downImageView.mas_top);
        make.trailing.mas_equalTo(self.downImageView.mas_leading).mas_offset(-90);
    }];
    
    [self.upLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.upImageView.mas_bottom).mas_offset(7);
        make.centerX.mas_equalTo(self.upImageView.mas_centerX);
    }];
    
    [self.upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.upLabel.mas_bottom);
        make.top.mas_equalTo(self.upImageView.mas_top);
        make.centerX.mas_equalTo(self.upImageView.mas_centerX);
        make.width.mas_equalTo(kZFOutfitBuiderWidth);
    }];
    
    
    [self.deleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.downImageView.mas_top);
        make.leading.mas_equalTo(self.downImageView.mas_trailing).mas_offset(90);
    }];
    
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteImageView.mas_bottom).mas_offset(7);
        make.centerX.mas_equalTo(self.deleteImageView.mas_centerX);
    }];
    
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.deleteLabel.mas_bottom);
        make.top.mas_equalTo(self.deleteImageView.mas_top);
        make.centerX.mas_equalTo(self.deleteImageView.mas_centerX);
        make.width.mas_equalTo(kZFOutfitBuiderWidth);
    }];
    
    [self.ruleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.canvasImageView.mas_bottom).offset(-27);
    }];
    
    [self.ruleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.ruleButton.mas_leading).offset(5);
        make.centerY.mas_equalTo(self.ruleButton.mas_centerY);
    }];

    [self.ruleArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.ruleButton.mas_trailing).offset(-5);
        make.centerY.mas_equalTo(self.ruleButton.mas_centerY);
        make.leading.mas_equalTo(self.ruleLabel.mas_trailing).offset(3);
    }];
    
}

+ (CGFloat)bottomOperateHeight {
    return 69;
}
#pragma mark - action


/**
 穿搭规则
 */
- (void)actionRule:(UIButton *)sender {
    if (self.outfitRuleBlock) {
        self.outfitRuleBlock(@"");
    }
}

/**
 添加新的 饰品
 */
- (void)addNewItemWithItemModel:(ZFOutfitItemModel *)itemModel {
    [self.canvasImageView addNewOutfitItemWithItemModel:itemModel];
    [self setOperaterButton];
}

/**
 改变画布边框
 */
- (void)changeBorderItemModel:(ZFCommunityOutfitBorderModel *)borderModel {
    
    if ([ZFOutfitBuilderSingleton shareInstance].borderModel) {
        [self setCanvasBackgroudView:[ZFOutfitBuilderSingleton shareInstance].borderModel.border_img_url];
        [self setOperaterButton];
    }
}

/**
 获取画布图片
 */
- (UIImage *)imageOfOutfitsView {
    [self.canvasImageView resetAllItemStatus:YES];
    return [UIImage zf_shortImageFromView:self.canvasImageView];
}


/**
 删除当前选中的 饰品
 */
- (void)deleteOutfitItemAction {
    [self.canvasImageView deleteSelectOutfitItemView];
    [self setOperaterButton];
}


/**
 移动当前饰品到上一层
 */
- (void)upOutfitItemAction {
    [self.canvasImageView upOutfitItem];
}


/**
 移动当前饰品到下一层
 */
- (void)downOutfitItemAction {
    [self.canvasImageView downOufitItem];
}


- (void)exChangeButtonEdge:(UIButton *)button {
    CGFloat space     = 5.0;
    CGRect imageFrame = button.imageView.frame;
    CGRect titleFrame = button.titleLabel.frame;
    CGFloat imageX    = (button.width - imageFrame.size.width) / 2 - imageFrame.origin.x;
    CGFloat titleLX   = - titleFrame.origin.x;
    CGFloat titleRX   = button.width - titleFrame.size.width - titleFrame.origin.x;
    CGFloat imageY    = ((imageFrame.size.height + titleFrame.size.height) / 2 + space) / 2;
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        button.titleEdgeInsets = UIEdgeInsetsMake(imageY, 0, -imageY, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(-imageY, 0, imageY, 50);
    } else {
        button.titleEdgeInsets = UIEdgeInsetsMake(imageY, titleLX, -imageY, -titleRX);
        button.imageEdgeInsets = UIEdgeInsetsMake(-imageY, imageX, imageY, - imageX);
    }
}

#pragma mark - getter/setter

- (id)currentImage {
    id image = [UIImage zf_createImageWithColor:[UIColor colorWithHex:0xffffff]];
    return image;
}

- (ZFOutfitsWorkSpaceView *)canvasImageView {
    if (!_canvasImageView) {
        _canvasImageView = [[ZFOutfitsWorkSpaceView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, self.width)];
        id image = [self currentImage];
        [self setCanvasBackgroudView:image];
        @weakify(self)
        _canvasImageView.deleteItem = ^{
            @strongify(self)
            [self setOperaterButton];
        };
        
        _canvasImageView.cancelAllSelectBlock = ^(BOOL flag) {
            @strongify(self)
            [self setOperaterButton];
        };
    }
    return _canvasImageView;
}

- (UIView *)borderLineView {
    if (!_borderLineView) {
        _borderLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, self.width)];
        CGFloat width    = KScreenWidth - 2 * kZFOutfitBuiderLeftSpace + 2;
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.bounds = CGRectMake(0, 0, width, width); //中心点位置
        borderLayer.position = CGPointMake(width *0.5, width *0.5);
        borderLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, width)].CGPath;
        borderLayer.lineWidth = 0.5; //边框的宽度
        borderLayer.lineDashPattern = @[@3,@3]; //边框虚线线段的宽度
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = ZFC0x979797().CGColor;
        [_borderLineView.layer addSublayer:borderLayer];
    }
    return _borderLineView;
}

- (void)setCanvasBackgroudView:(id)image {
    if ([image isKindOfClass:[UIImage class]]) {
        _canvasImageView.image  = image;
    } else {
        self.tipView.hidden = YES;
        [_canvasImageView yy_setImageWithURL:[NSURL URLWithString:image]
                                 placeholder:nil];
    }
}

- (void)setOperaterButton {

    // 当商品数少于2 或 没选择商品时
    if ([[ZFOutfitBuilderSingleton shareInstance] selectedCount] < 2 || ![self.canvasImageView currentSelectItemView]) {

        self.upImageView.image = [UIImage imageNamed:@"z-me_outfits_item_forward_gray"];
        self.upLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        self.upButton.userInteractionEnabled = NO;
        
        self.downImageView.image = [UIImage imageNamed:@"z-me_outfits_item_back_gray"];
        self.downLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        self.downButton.userInteractionEnabled = NO;
        
    } else {
        
        self.upImageView.image = [UIImage imageNamed:@"z-me_outfits_item_forward"];
        self.upLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        self.upButton.userInteractionEnabled = YES;
        
        self.downImageView.image = [UIImage imageNamed:@"z-me_outfits_item_back"];
        self.downLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        self.downButton.userInteractionEnabled = YES;
    }
    
    // 当前有选中
    if ([[ZFOutfitBuilderSingleton shareInstance] selectedCount] > 0 && [self.canvasImageView currentSelectItemView]) {
        
        self.deleteImageView.image = [UIImage imageNamed:@"z-me_outfits_delete_light"];
        self.deleteLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        self.deleteButton.userInteractionEnabled = YES;
    } else {
        self.deleteImageView.image = [UIImage imageNamed:@"z-me_outfits_delete"];
        self.deleteLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        self.deleteButton.userInteractionEnabled = NO;
    }
    
    // 但只没有商品时
//    if ([[ZFOutfitBuilderSingleton shareInstance] selectedCount] <= 0 && ![ZFOutfitBuilderSingleton shareInstance].borderModel) {

    if ([[ZFOutfitBuilderSingleton shareInstance] selectedCount] <= 0) {
        self.ruleButton.hidden = NO;
        self.tipView.hidden = NO;
        if ([ZFOutfitBuilderSingleton shareInstance].borderModel) {
            self.tipView.hidden = YES;
        }
    } else {
        self.ruleButton.hidden = YES;
        self.tipView.hidden = YES;
    }
}



#pragma mark - getter/setter

- (UIView *)bottomOperateView {
    if (!_bottomOperateView) {
        _bottomOperateView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomOperateView;
}
- (UIImageView *)deleteImageView {
    if (!_deleteImageView) {
        _deleteImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _deleteImageView.image = [UIImage imageNamed:@"z-me_outfits_delete"];
    }
    return _deleteImageView;
}

- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deleteLabel.font = ZFFontSystemSize(12.0);
        _deleteLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _deleteLabel.text = ZFLocalizedString(@"Address_List_Cell_Delete", nil);
    }
    return _deleteLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self action:@selector(deleteOutfitItemAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.userInteractionEnabled = NO;
    }
    return _deleteButton;
}

- (UIImageView *)upImageView {
    if (!_upImageView) {
        _upImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _upImageView.image = [UIImage imageNamed:@"z-me_outfits_item_forward_gray"];
    }
    return _upImageView;
}

- (UILabel *)upLabel {
    if (!_upLabel) {
        _upLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _upLabel.font = ZFFontSystemSize(12.0);
        _upLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _upLabel.text = ZFLocalizedString(@"community_outfititem_position_forward", nil);
    }
    return _upLabel;
}

- (UIButton *)upButton {
    if (!_upButton) {
        _upButton       = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upButton addTarget:self action:@selector(upOutfitItemAction) forControlEvents:UIControlEventTouchUpInside];
        _upButton.userInteractionEnabled = NO;
    }
    return _upButton;
}


- (UIImageView *)downImageView {
    if (!_downImageView) {
        _downImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _downImageView.image = [UIImage imageNamed:@"z-me_outfits_item_back_gray"];
    }
    return _downImageView;
}

- (UILabel *)downLabel {
    if (!_downLabel) {
        _downLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _downLabel.font = ZFFontSystemSize(12.0);
        _downLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _downLabel.text = ZFLocalizedString(@"ZFPaymentView_Close_Title", nil);
    }
    return _downLabel;
}

- (UIButton *)downButton {
    if (!_downButton) {
        _downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downButton addTarget:self action:@selector(downOutfitItemAction) forControlEvents:UIControlEventTouchUpInside];
        _downButton.userInteractionEnabled = NO;
    }
    return _downButton;
}

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:self.canvasImageView.frame];
        _tipView.backgroundColor = [UIColor clearColor];
        
        UIImage *image         = [UIImage imageNamed:@"z-me_outfits_kong"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_tipView.width - image.size.width) / 2, 0.0, image.size.width, image.size.height)];
        imageView.image        = image;
        [_tipView addSubview:imageView];
        
        UILabel *tipTitleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _tipView.width, 18.0)];
        tipTitleLabel.textColor     = [UIColor blackColor];
        tipTitleLabel.font          = [UIFont systemFontOfSize:16.0];
        tipTitleLabel.textAlignment = NSTextAlignmentCenter;
        tipTitleLabel.numberOfLines = 0;
        tipTitleLabel.text          = ZFLocalizedString(@"Community_outfitBuilderTitle", nil);
        [_tipView addSubview:tipTitleLabel];
        
        CGFloat width = _tipView.width - 24.0;
        NSString *msg = ZFLocalizedString(@"community_addoutfit_tip", nil);
        CGSize size   = [msg boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]} context:nil].size;
        UILabel *tipLabel      = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, width, size.height)];
        tipLabel.textColor     = [UIColor colorWithHex:0x999999];
        tipLabel.font          = [UIFont systemFontOfSize:12.0];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.numberOfLines = 0;
        tipLabel.text          = msg;
        [_tipView addSubview:tipLabel];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.tipView.mas_centerX);
            make.top.mas_equalTo(self.tipView.mas_top).mas_offset(80);
        }];
        
        [tipTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.tipView);
            make.top.mas_equalTo(imageView.mas_bottom).mas_offset(30);
            //make.height.mas_equalTo(18.0);
        }];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.tipView);
            make.top.mas_equalTo(tipTitleLabel.mas_bottom).mas_offset(10);
        }];
        
    }
    return _tipView;
}


- (UIButton *)ruleButton {
    if (!_ruleButton) {
        _ruleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ruleButton addTarget:self action:@selector(actionRule:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ruleButton;
}

- (UILabel *)ruleLabel {
    if (!_ruleLabel) {
        _ruleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ruleLabel.text = ZFLocalizedString(@"Community_outfit_rules", nil);
        _ruleLabel.font = ZFFontSystemSize(14);
        _ruleLabel.textColor = ZFC0x999999();
        _ruleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _ruleLabel;
}

- (UIImageView *)ruleArrowImageView {
    if (!_ruleArrowImageView) {
        _ruleArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *arrowImage = [UIImage imageNamed:@"size_arrow_right"];
        _ruleArrowImageView.image = arrowImage;
//        _ruleArrowImageView.image = [arrowImage imageWithColor:ZFCThemeColor()];
        [_ruleArrowImageView convertUIWithARLanguage];
        
    }
    return _ruleArrowImageView;
}

- (void)setEditStatus:(ZFOutfitsEditStatus)editStatus {
    _editStatus = editStatus;
    switch (editStatus) {
        case ZFOutfitsEditStatusNormal: {
            if (!self.tipView.superview) {
                [self addSubview:self.tipView];
            }
            self.tipView.hidden = NO;
            break;
        }
        case ZFOutfitsEditStatusEditing: {
            self.tipView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

@end

