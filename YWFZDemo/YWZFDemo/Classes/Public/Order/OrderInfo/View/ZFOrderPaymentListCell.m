//
//  ZFOrderPaymentListCell.m
//  ZZZZZ
//
//  Created by YW on 18/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderPaymentListCell.h"
#import "ZFInitViewProtocol.h"
#import "PaymentListModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ExchangeManager.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "UIImage+ZFExtended.h"

@interface ZFOrderPaymentListCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton              *selectButton;
//@property (nonatomic, strong) YYAnimatedImageView   *payImageView;
@property (nonatomic, strong) UILabel               *infoLabel;
@property (nonatomic, strong) UILabel               *topInfoLabel;
//显示支付图标的视图
@property (nonatomic, strong) UIView                *paymentImageListView;
@end

@implementation ZFOrderPaymentListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.selectButton];
//    [self.contentView addSubview:self.payImageView];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.topInfoLabel];
    [self.contentView addSubview:self.paymentImageListView];
    [self.contentView addSubview:self.separatorLine];
}

- (void)zfAutoLayoutView {
//    [self.payImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.contentView.mas_leading).offset(12);
//        make.centerY.equalTo(self.topInfoLabel);
//        make.size.mas_equalTo(CGSizeMake(24, 24));
//    }];
    
    [self.topInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.selectButton.mas_leading).offset(-12);
        make.top.equalTo(self.contentView).offset(12);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topInfoLabel.mas_leading);
        make.trailing.equalTo(self.selectButton.mas_leading).offset(-12);
        make.top.equalTo(self.topInfoLabel.mas_bottom).offset(5);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
 
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.paymentImageListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topInfoLabel.mas_leading);
        make.trailing.equalTo(self.selectButton.mas_leading).offset(-12);
        make.top.equalTo(self.topInfoLabel.mas_bottom).offset(5);
    }];
    
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(0);
        make.leading.mas_equalTo(12);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - Setter
- (void)setIsChoose:(BOOL)isChoose {
    if (!self.paymentListmodel.isOnlyOne) {
        _isChoose = isChoose;
        self.selectButton.selected = isChoose;
    }
}

- (void)setPaymentListmodel:(PaymentListModel *)paymentListmodel
{
    _paymentListmodel = paymentListmodel;

    self.infoLabel.text = paymentListmodel.pay_shuoming;
    self.infoLabel.textColor = ZFCOLOR(178, 178, 178, 1);
    
    self.topInfoLabel.text = paymentListmodel.pay_name;
    self.selectButton.hidden = NO;

    if (_paymentListmodel.isOnlyOne) {
        ///只有一个支付方式的显示逻辑
        self.selectButton.hidden = YES;
        self.topInfoLabel.textColor = [self gainPayNameColorWithCode:paymentListmodel];
        self.topInfoLabel.font = ZFFontBoldSize(14);
        
        if ([paymentListmodel isCodePayment] && [paymentListmodel.default_select integerValue] == 0) {
            ///如果支付方式只有一个，并且是COD，并且不是默认选择的时候，显示成感叹号
            self.selectButton.selected = NO;
            self.selectButton.hidden = NO;
            [self.selectButton setImage:[UIImage imageNamed:@"Check_Mark"] forState:UIControlStateNormal];
        }
    }else{
        ///多个支付方式的显示逻辑
        [_selectButton setImage:[UIImage imageNamed:@"order_unchoose"] forState:UIControlStateNormal];
        self.topInfoLabel.textColor = [self gainPayNameColorWithCode:paymentListmodel];
        self.topInfoLabel.font = ZFFontBoldSize(14);
    }

    if ([paymentListmodel isOnlinePayment]) {
        //显示一个折扣金额
        if (ZFToString(paymentListmodel.offer_message.tips).length) {
            NSString *offerMessage = paymentListmodel.offer_message.tips;
            NSString *discount = [ExchangeManager transforPrice:ZFToString(paymentListmodel.offer_message.discount)];
            NSString *amount = [ExchangeManager transPurePriceforPrice:ZFToString(paymentListmodel.offer_message.amount)];
            offerMessage = [offerMessage stringByReplacingOccurrencesOfString:@"$discount" withString:discount];
            offerMessage = [offerMessage stringByReplacingOccurrencesOfString:@"$amount" withString:amount];
            
            NSString *message = [NSString stringWithFormat:@"(%@)", offerMessage];
            self.topInfoLabel.text = [NSString stringWithFormat:@"%@   %@", paymentListmodel.pay_name, message];
            NSRange offRanage = [self.topInfoLabel.text rangeOfString:message];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.topInfoLabel.text];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFE5269()} range:offRanage];
            [attri addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11]} range:offRanage];
            self.topInfoLabel.attributedText = attri; 
        }
    }
    if ([paymentListmodel isCodePayment]) {
        if (ZFToString(paymentListmodel.offer_message.tips).length) {
            NSString *offerMessage = paymentListmodel.offer_message.tips;
            NSString *message = [NSString stringWithFormat:@"(%@)", offerMessage];
            self.topInfoLabel.text = [NSString stringWithFormat:@"%@   %@", paymentListmodel.pay_name, message];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.topInfoLabel.text];
            NSRange offRanage = [self.topInfoLabel.text rangeOfString:message];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFE5269()} range:offRanage];
            [attri addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11]} range:offRanage];
            self.topInfoLabel.attributedText = attri;
        }
    }
    
    //重置按钮大小
    [self.selectButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(20, 20));
    }];
    ///是否可以使用cod  0 正常可用 1 soa风控  2 网站风控
    self.accessoryType = UITableViewCellAccessoryNone;
    NSInteger codGray = paymentListmodel.cod_state;
    if (codGray && [_paymentListmodel isCodePayment]) {
        self.topInfoLabel.textColor = ZFCOLOR(204, 204, 204, 1.0);
        self.selectButton.hidden = YES;
        if (codGray == 2) {
            self.infoLabel.textColor = ZFCOLOR(178, 178, 178, 1);
        }
        if (codGray == 1) {
            self.infoLabel.textColor = [UIColor colorWithHexString:@"FE5269"];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //当非COD会员的时候，隐藏按钮的大小，多显示一点文案
            [self.selectButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_offset(CGSizeZero);
            }];
        }
    }
}

-(UIColor *)gainPayNameColorWithCode:(PaymentListModel *)model
{
    if ([model isCodePayment]) {
        return ZFCOLOR(21, 127, 177, 1);
    }else if ([model isOnlinePayment]){
        return ZFCOLOR(73, 146, 91, 1);
    }else{
        return ZFCOLOR(45, 45, 45, 1);
    }
}

- (void)addPayiconImage:(NSArray *)imageList
{
    if ([self.paymentImageListView.subviews count]) {
        [self.paymentImageListView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.superview) {
                [obj removeFromSuperview];
            }
        }];
    }
    [self.paymentImageListView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topInfoLabel.mas_leading);
        make.trailing.equalTo(self.selectButton.mas_leading).offset(-12);
        make.top.equalTo(self.topInfoLabel.mas_bottom).offset(12);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-12);
    }];
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    self.infoLabel.hidden = YES;
    
    NSMutableArray *rectList = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageList.count; i++) {
        NSValue *valueSize = imageList[i];
        [rectList addObject:valueSize];
    }
    
    __block CGFloat currentMaxY = 0;
    UIView *lastView = nil;
    CGFloat leftPadding = 4;
    CGFloat topPadding = 4;
    for (int i = 0; i < rectList.count; i++) {
        NSValue *valueSize = rectList[i];
        CGSize size = valueSize.CGSizeValue;
        id payIcon = _paymentListmodel.payIconImageList[i];
        if ([payIcon isKindOfClass:[UIImage class]]) {
            UIImageView *payIcon = [[UIImageView alloc] init];
            payIcon.image = _paymentListmodel.payIconImageList[i];
            NSURL *imgUrl = [NSURL URLWithString:_paymentListmodel.pay_desc_list[i].pay_icon];
            [payIcon yy_setImageWithURL:imgUrl placeholder:_paymentListmodel.payIconImageList[i]];
            [self.paymentImageListView addSubview:payIcon];
        } else if ([payIcon isKindOfClass:[UILabel class]]) {
            [self.paymentImageListView addSubview:(UILabel *)payIcon];
        } 

        currentMaxY += size.width + (leftPadding * i);
        UIView *currentView = self.paymentImageListView.subviews.lastObject;
        if (i == 0) {
            [currentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(size);
                make.leading.mas_equalTo(self.paymentImageListView.mas_leading);
                make.top.mas_equalTo(self.paymentImageListView.mas_top);
            }];
        } else {
            lastView = self.paymentImageListView.subviews[i - 1];
            BOOL need = currentMaxY > (KScreenWidth - 32);
            [currentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(size);
                if (need) {
                    currentMaxY = size.width + (leftPadding * i);
                    make.top.mas_equalTo(lastView.mas_bottom).mas_offset(topPadding);
                    make.leading.mas_equalTo(self.paymentImageListView.mas_leading);
                } else {
                    make.leading.mas_equalTo(lastView.mas_trailing).mas_offset(leftPadding);
                    make.top.mas_equalTo(lastView.mas_top);
                }
                if (i == rectList.count - 1) {
                    make.bottom.mas_equalTo(self.paymentImageListView.mas_bottom);
                } 
            }];
        }
    }
    if (rectList.count == 1) {
        [self.paymentImageListView.subviews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.paymentImageListView.mas_bottom);
        }];
    }
}

#pragma mark - Getter
- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
        [_selectButton setImage:[[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
         _selectButton.userInteractionEnabled = NO;
    }
    return _selectButton;
}

//- (YYAnimatedImageView *)payImageView {
//    if (!_payImageView) {
//        _payImageView = [YYAnimatedImageView new];
//    }
//    return _payImageView;
//}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = ZFCOLOR(178, 178, 178, 1);
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _infoLabel.preferredMaxLayoutWidth = KScreenWidth - 12 - 12 - 20 - 12;
    }
    return _infoLabel;
}

-(UILabel *)topInfoLabel
{
    if (!_topInfoLabel) {
        _topInfoLabel = [[UILabel alloc] init];
        _topInfoLabel.font = [UIFont systemFontOfSize:14];
        _topInfoLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _topInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _topInfoLabel.numberOfLines = 0;
        _topInfoLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _topInfoLabel;
}

-(UIView *)paymentImageListView
{
    if (!_paymentImageListView) {
        _paymentImageListView = [[UIView alloc] init];
    }
    return _paymentImageListView;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _separatorLine;
}

@end
