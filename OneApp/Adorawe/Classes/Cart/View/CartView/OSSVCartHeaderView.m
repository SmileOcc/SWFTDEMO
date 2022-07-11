//
//  OSSVCartHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartHeaderView.h"
#import "CartModel.h"
#import "YYText.h"

@interface OSSVCartHeaderView ()
/** SALE图标*/
@property (nonatomic, strong) UIImageView          *saleMarkImageView;
/** 箭头图片*/
@property (nonatomic, strong) UIImageView          *arrowImgView;
/** 活动名称*/
@property (nonatomic, strong) UILabel              *activityThemeLabel;
/** 活动二名称*/
//@property (nonatomic, strong) UILabel               *activityThemeTwoLabel;
/** 去凑单*/
@property (nonatomic, strong) UIButton              *goShopButton;
@property (nonatomic, strong) UIView                *lineView;

/** 新人免费*/
//@property (nonatomic, assign) BOOL                  isFreeGift;
@end

@implementation OSSVCartHeaderView

+ (OSSVCartHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[OSSVCartHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass(OSSVCartHeaderView.class)];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(OSSVCartHeaderView.class)];
}


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        //添加约束，进行自动布局
        UIView *ws = self.contentView;
        [ws addSubview:self.saleMarkImageView];
        [ws addSubview:self.activityThemeLabel];
        [ws addSubview:self.arrowImgView];
        [ws addSubview:self.goShopButton];
        [ws addSubview:self.lineView];
        
        [self.saleMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(14);
            make.centerY.mas_equalTo(self.centerY);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        

        [self.goShopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.top.bottom.mas_equalTo(ws);
        }];
        
        [self.activityThemeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                make.trailing.mas_equalTo(self.saleMarkImageView.mas_leading).mas_offset(-5);
            } else {
                make.leading.mas_equalTo(self.saleMarkImageView.mas_trailing).mas_offset(5);

            }
            make.trailing.mas_lessThanOrEqualTo(self.mas_trailing).mas_offset(-40);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(@(0.5));
        }];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (APP_TYPE == 3) {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(0, 0)];
    } else {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    }
}

#pragma mark -

- (void)updateInfoModel:(ActivityInfoModel *)infoModel freeGift:(BOOL)isFreeGift {
//    self.isFreeGift = isFreeGift;
    self.infoModel = infoModel;
}

- (void)setInfoModel:(ActivityInfoModel *)infoModel {
    _infoModel = infoModel;
     

        //满减活动 cart
   NSMutableAttributedString *titleAtt = [ActivityInfoModel activityTitle:STLToString(infoModel.cartTips)];
        //需要重新设置字体，不然不起作用
    NSRange range = NSMakeRange(0, titleAtt.string.length);
    if (APP_TYPE == 3) {
        //添加文本 下方 虚线
        [titleAtt yy_setAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternDot) range:range];
        [titleAtt yy_setAttribute:NSUnderlineColorAttributeName value:[OSSVThemesColors col_000000:0.5] range:range];
        self.activityThemeLabel.attributedText = titleAtt;
        self.activityThemeLabel.font = [UIFont systemFontOfSize:12];
    } else {
        self.activityThemeLabel.attributedText = titleAtt;
        self.activityThemeLabel.font = [UIFont boldSystemFontOfSize:13];
    }
        self.activityThemeLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft ;
        self.activityThemeLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    //新增判断根据specialUrl来判断箭头的展示
    self.arrowImgView.hidden = infoModel.specialUrl.length > 0 ? NO : YES;
    self.goShopButton.hidden = NO;
}


#pragma mark - LazyLoad

- (UIImageView *)saleMarkImageView {
    if (!_saleMarkImageView) {
        _saleMarkImageView = [UIImageView new];
        _saleMarkImageView.image = [UIImage imageNamed:@"shopBag_sale"];
    }
    return _saleMarkImageView;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"detail_right_arrow"];
//        _arrowImgView.hidden = YES;
        [_arrowImgView convertUIWithARLanguage];
    }
    return _arrowImgView;
}

- (UILabel *)activityThemeLabel {
    if (!_activityThemeLabel) {
        _activityThemeLabel = [[UILabel alloc] init];
        if (APP_TYPE == 3) {
            _activityThemeLabel.font = [UIFont systemFontOfSize:12];
        } else {
            _activityThemeLabel.font = [UIFont boldSystemFontOfSize:13];
        }
        _activityThemeLabel.numberOfLines = 2;
        
    }
    return _activityThemeLabel;
}


- (UIButton *)goShopButton {
    if (!_goShopButton) {
        _goShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goShopButton addTarget:self action:@selector(actionShop:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goShopButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _lineView.hidden = APP_TYPE == 3 ? YES : NO;
    }
    return _lineView;
}

#pragma mark -
- (void)actionShop:(UIButton *)sender {
    NSLog(@"-----");
    
    if (self.operateBlock) {
        self.operateBlock(self.infoModel);
    }
}
@end
