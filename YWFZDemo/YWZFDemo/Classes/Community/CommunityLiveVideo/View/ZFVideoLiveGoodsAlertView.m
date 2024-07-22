//
//  ZFVideoLiveGoodsAlertView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveGoodsAlertView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFFullLiveTryOnView.h"

@interface ZFVideoLiveGoodsAlertView()

@property (nonatomic, assign) CGFloat      offset;
@property (nonatomic, assign) NSInteger    direct;
@property (nonatomic, assign) CGFloat      arrowH;
@property (nonatomic, assign) CGFloat      arrowW;

@property (nonatomic, assign) CGFloat      offsetLeading;
@property (nonatomic, assign) CGFloat      offsetTrailing;


//可扩充
@property (nonatomic, strong) UIView       *defaultView;

@end



@implementation ZFVideoLiveGoodsAlertView

- (instancetype)initTipArrowOffset:(CGFloat)offset
                      leadingSpace:(CGFloat)leading
                     trailingSpace:(CGFloat)trailing
                            direct:(ZFTitleArrowTipDirect)direct
                       contentView:(UIView *)content {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.shadowColor = ColorHex_Alpha(0x000000, 0.2).CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
        
        self.offsetLeading = leading >= 0 ? leading : 18;
        self.offsetTrailing = trailing >= 0 ? trailing : 12;
        
        self.offset = offset;
        self.direct = direct;
        self.arrowW = 16.0;
        self.arrowH = 8.0;
        self.defaultView = content;
        
        [self showDefaultView:content updateConstraints:YES];
        
    }
    return self;
}

- (void)showDefaultView:(UIView *)content updateConstraints:(BOOL)update{
    
    if (update && content) {
        [self showContentViewConstraints:content];
    }
}

- (void)showContentViewConstraints:(UIView *)showView {
    
    //若显示过默认内容视图，先移除
    if (self.defaultView) {
        [self.defaultView removeFromSuperview];
    }
    
    if (!showView) {
        return;
    }
    if (showView.superview) {
        if (showView.superview != self) {
            [showView removeFromSuperview];
            [self addSubview:showView];
            
            [showView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(self.arrowH + self.offsetTrailing);
                make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-self.offsetLeading);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-self.offsetTrailing);
            }];
        }
    } else {
        [self addSubview:showView];
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.arrowH + self.offsetTrailing);
            make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-self.offsetLeading);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-self.offsetTrailing);
        }];
    }
    
    
    if (self.direct == ZFTitleArrowTipDirectUpLeft || self.direct == ZFTitleArrowTipDirectUpRight) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.arrowH + self.offsetTrailing);
            make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-self.offsetLeading);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-self.offsetTrailing);
        }];
        
    } else if (self.direct == ZFTitleArrowTipDirectDownLeft || self.direct == ZFTitleArrowTipDirectDownRight) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.offsetTrailing);
            make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-self.offsetLeading);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-(self.arrowH + self.offsetTrailing));
        }];
        
    } else if (self.direct == ZFTitleArrowTipDirectLeftUp || self.direct == ZFTitleArrowTipDirectLeftDown) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.offsetTrailing);
            make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading + self.arrowH);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-self.offsetLeading);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-self.offsetTrailing);
        }];
    } else if (self.direct == ZFTitleArrowTipDirectRightUp || self.direct == ZFTitleArrowTipDirectRightDown) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.offsetTrailing);
            make.leading.mas_equalTo(self.mas_leading).offset(self.offsetLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-(self.offsetLeading + self.arrowH));
            make.bottom.mas_equalTo(self.mas_bottom).offset(-self.offsetTrailing);
        }];
    }
}


#pragma mark - 更新

- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFTitleArrowTipDirect)direct
                 contentView:(UIView *)contentView {
    
    if (contentView) {
        self.offset = offset;
        self.direct = direct;
        [self showContentViewConstraints:contentView];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    } else {
        self.hidden = YES;
    }
}

#pragma mark - 隐藏
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion{
    if (time < 0) {
        time = 3;
    }
    //    CGRect frame = self.frame;
    //    frame.size.height = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [UIView animateWithDuration:0.25 animations:^{
        //            self.frame = frame;
        //            [self layoutIfNeeded];
        //        } completion:^(BOOL finished) {
        //            self.hidden = YES;
        //        }];
        
        self.hidden = YES;
        if (completion) {
            completion();
        }
    });
}

- (void)hideView {
    self.hidden = YES;
}


- (void)drawRect:(CGRect)rect {
    CGRect frame = rect;
    
    CGFloat frameWidth = CGRectGetWidth(frame);
    CGFloat frameHeight = CGRectGetHeight(frame);
    //箭头宽、高
    CGFloat arrowW = self.arrowW;
    CGFloat arrowH = self.arrowH;
    
    //FIXME: occ Bug 1101 完善待
    CGFloat arcR = 5;

    CGFloat moveOffset = 0.0;
    CGFloat moveDirect = self.direct;
    if (self.offset >= 0) {
        moveOffset = self.offset;
    } else {
        if (moveDirect == ZFTitleArrowTipDirectUpRight || moveDirect == ZFTitleArrowTipDirectUpLeft
            || moveDirect == ZFTitleArrowTipDirectDownLeft || moveDirect == ZFTitleArrowTipDirectDownRight) {
            moveOffset = frameWidth / 2.0;
        } else {
            moveOffset = frameHeight / 2.0;
        }
    }
    if (moveOffset < arrowW / 2.0) {
        moveOffset = arrowW / 2.0;
    }
    
    // 设置最新圆角
    if ((moveOffset - arrowW / 2.0) < arcR) {
        arcR = moveOffset - arrowW / 2.0;
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.0] set];
    
    if (moveDirect == ZFTitleArrowTipDirectUpRight || moveDirect == ZFTitleArrowTipDirectUpLeft) {
        
        CGContextMoveToPoint(contextRef, 0.0, arrowH + arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, 0, arrowH, arcR, arrowH, arcR);
        
        if (moveDirect == ZFTitleArrowTipDirectUpLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, arrowH);
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (arrowW / 2.0 + moveOffset), arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, arrowH, frameWidth, arrowH + arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight, frameWidth - arcR, frameHeight, arcR);
        CGContextAddLineToPoint(contextRef, arcR, frameHeight);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight, 0, frameHeight - arcR, arcR);
        CGContextAddLineToPoint(contextRef, 0.0, arrowH + arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == ZFTitleArrowTipDirectDownLeft || moveDirect == ZFTitleArrowTipDirectDownRight) {
        
        CGContextMoveToPoint(contextRef, 0.0, arcR);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, 0, arcR, 0, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth - arcR, 0);
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, 0, frameWidth, arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arrowH - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight - arrowH, frameWidth - arcR, frameHeight - arrowH, arcR);
        
        if (moveDirect == ZFTitleArrowTipDirectDownLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset + arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight - arrowH, 0, frameHeight - arrowH - arcR, arcR);
        CGContextAddLineToPoint(contextRef, 0.0, arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
    }
    
    else if (moveDirect == ZFTitleArrowTipDirectLeftUp || moveDirect == ZFTitleArrowTipDirectLeftDown) {
        
        CGContextMoveToPoint(contextRef, arrowH, 0.0);
        
        if (moveDirect == ZFTitleArrowTipDirectLeftUp) {
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, 0, moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset + arrowW / 2.0);
            
        } else {
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, 0, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight -(moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        CGContextAddLineToPoint(contextRef, arrowH, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == ZFTitleArrowTipDirectRightUp || moveDirect == ZFTitleArrowTipDirectRightDown) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0.0);
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, 0);
        
        if (moveDirect == ZFTitleArrowTipDirectRightUp) {
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, frameWidth, moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset + arrowW / 2.0);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
}

@end




@interface ZFVideoLiveGoodsAlertItemView ()

@property (nonatomic, strong) UIView        *mainView;

@property (nonatomic, strong) UIButton      *closeButton;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *shopPrice;
@property (nonatomic, strong) UILabel       *marketPrice;
@property (nonatomic, strong) UIButton      *cartButton;

@property (nonatomic, strong) ZFFullLiveTryOnView *tryOnView;

@property (nonatomic, assign) BOOL          isTryOn;



@property (nonatomic, strong) ZFCommunityVideoLiveGoodsModel *goodsModel;



@end

@implementation ZFVideoLiveGoodsAlertItemView

- (instancetype)initFrame:(CGRect)frame goodsModel:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.goodsModel = goodsModel;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (instancetype)initFrame:(CGRect)frame goodsModel:(ZFCommunityVideoLiveGoodsModel *)goodsModel tryOn:(BOOL)tryOn {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.isTryOn = tryOn;
        self.goodsModel = goodsModel;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCClearColor();
    [self addSubview:self.mainView];
    [self.mainView addSubview:self.imageView];
    [self.mainView addSubview:self.titleLabel];
    [self.mainView addSubview:self.shopPrice];
    [self.mainView addSubview:self.marketPrice];
    [self.mainView addSubview:self.tryOnView];
    [self.mainView addSubview:self.cartButton];
    [self.mainView addSubview:self.closeButton];
}

- (void)zfAutoLayoutView {
    
    CGSize size = CGSizeEqualToSize(self.frame.size, CGSizeZero) ? CGSizeMake(230, 116) : self.frame.size;
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self);
        make.size.mas_equalTo(size);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self.mainView);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainView.mas_leading).offset(10);
        make.top.mas_equalTo(self.mainView.mas_top).offset(12);
        make.bottom.mas_equalTo(self.mainView.mas_bottom).offset(-10);
        make.width.mas_equalTo(self.imageView.mas_height).multipliedBy(64.0/86.0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.imageView.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-5);
        make.top.mas_equalTo(self.imageView.mas_top);
    }];
    
    [self.shopPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    
    [self.marketPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.shopPrice.mas_bottom).offset(2);
    }];
    
    if (self.isTryOn) {
        [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mainView.mas_trailing);
            make.bottom.mas_equalTo(self.mainView.mas_bottom);
        }];
    } else {
        [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-8);
            make.bottom.mas_equalTo(self.mainView.mas_bottom).offset(-12);
        }];
    }
    
    [self.tryOnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.shopPrice.mas_bottom).offset(2);
        make.height.mas_equalTo(16);
        make.width.mas_lessThanOrEqualTo(93);
    }];
}

- (void)updateCloseSize:(CGSize)size {
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [self.closeButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
        }];
    }
}

- (void)setGoodsModel:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    self.titleLabel.text = ZFToString(_goodsModel.title);
    self.shopPrice.text = [ExchangeManager transforPrice:ZFToString(_goodsModel.shop_price)];
    
    NSString *marketPrice = [ExchangeManager transforPrice:_goodsModel.price];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
    self.marketPrice.attributedText = attribtStr;

    [self.imageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.pic_url]
                               placeholder:[UIImage imageNamed:@"community_loading_product"]];
    
    if (self.isTryOn) {
        self.tryOnView.hidden = NO;
        self.marketPrice.hidden = YES;
        [self.tryOnView startLoading];
    } else {
        self.tryOnView.hidden = YES;
        [self.tryOnView endLoading];
        self.marketPrice.hidden = NO;
    }
}

#pragma mark - action

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
}

- (void)actionCart:(UIButton *)sender {
    if (self.addCartBlock) {
        self.addCartBlock(self.goodsModel);
    }
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 116)];
        _mainView.layer.cornerRadius = 5;
        _mainView.layer.masksToBounds = YES;
    }
    return _mainView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x999999();
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UILabel *)shopPrice {
    if (!_shopPrice) {
        _shopPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPrice.textColor = ZFC0xFE5269();
        _shopPrice.font = ZFFontSystemSize(14);
    }
    return _shopPrice;
}

- (UILabel *)marketPrice {
    if (!_marketPrice) {
        _marketPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        _marketPrice.textColor = ZFC0x999999();
        _marketPrice.font = ZFFontSystemSize(12);
    }
    return _marketPrice;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:ZFImageWithName(@"community_cart_add") forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(actionCart:) forControlEvents:UIControlEventTouchUpInside];
        [_cartButton setContentEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    }
    return _cartButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:ZFImageWithName(@"attribute_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton convertUIWithARLanguage];

    }
    return _closeButton;
}

- (ZFFullLiveTryOnView *)tryOnView {
    if (!_tryOnView) {
        _tryOnView = [[ZFFullLiveTryOnView alloc] initWithFrame:CGRectZero];
        _tryOnView.backgroundColor = ZFC0xFE5269();
        _tryOnView.layer.cornerRadius = 8;
        _tryOnView.layer.masksToBounds = YES;
        _tryOnView.hidden = YES;
    }
    return _tryOnView;
}
@end
