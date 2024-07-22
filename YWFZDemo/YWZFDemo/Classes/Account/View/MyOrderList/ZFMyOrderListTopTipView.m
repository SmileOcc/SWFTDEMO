//
//  ZFMyOrderListTopTipView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/29.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFMyOrderListTopTipView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFMyOrderListTopTipView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIImageView           *arrowImageView;
@end

@implementation ZFMyOrderListTopTipView

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)tipText arrow:(BOOL)showArrow {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat contentH = [self calculateTipHeight:tipText showArrow:showArrow];
        frame.size.height = contentH;
        self.frame = frame;
        
        [self zfInitView];
        [self zfAutoLayoutView];
        [self tipText:tipText showArrow:showArrow];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)tipText:(NSString *)tipText showArrow:(BOOL)showArrow {
    self.titleLabel.text = ZFToString(tipText);
    self.arrowImageView.hidden = !showArrow;
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(showArrow ? -32 : -16);
    }];
    
    [self layoutIfNeeded];
}

- (CGFloat)calculateTipHeight:(NSString *)tipText showArrow:(BOOL)showArrow {
    if (ZFIsEmptyString(tipText)) {
        return 0;
    }
    
    CGFloat contentW = showArrow ? KScreenWidth - (32+16) : KScreenWidth - 32;
    CGFloat fontSize = 12.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [tipText boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT)  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return MAX(44.0,  size.height + 14.0 + 10);;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(7);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-32);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-7);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.preferredMaxLayoutWidth = KScreenWidth - (32+16);
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = ZFCOLOR(183, 96, 42, 1);
        [_titleLabel convertTextAlignmentWithARLanguage];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"car_topTip_arrow"];
        _arrowImageView.userInteractionEnabled = YES;
        _arrowImageView.hidden = YES;
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}


@end
