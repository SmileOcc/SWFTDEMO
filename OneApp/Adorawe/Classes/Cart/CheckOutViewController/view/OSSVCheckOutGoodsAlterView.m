//
//  OSSVCheckOutGoodsAlterView.m
// XStarlinkProject
//
//  Created by odd on 2021/1/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCheckOutGoodsAlterView.h"
#import "OSSVProductListCell.h"
#import "Adorawe-Swift.h"
@interface OSSVCheckOutGoodsAlterView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGPoint        panGestureBeginPoint;
@end

@implementation OSSVCheckOutGoodsAlterView


+ (void)fetchSizeShieldTipHeight:(NSMutableArray<OSSVCartGoodsModel *> *)cartGoodsArray message:(NSString *)string completion:(void (^)(NSAttributedString *stringAttributed, CGSize calculateSize))completion {
    
    OSSVCheckOutGoodsAlterView *sizeCell = [[OSSVCheckOutGoodsAlterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    sizeCell.hadManualSelectSize = hadManualSelectSize;
    
    sizeCell.cartGoddsArray = cartGoodsArray;
    sizeCell.message = string;
    sizeCell.completion = completion;
    
    // 使用 NSHTMLTextDocumentType 时，要在子线程初始化，在主线程赋值，否则会不定时出现 webthread crash
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        [attributeString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],
//                                         NSForegroundColorAttributeName:[OSSVThemesColors col_666666],
                                         NSParagraphStyleAttributeName:paragraphStyle
                } range:NSMakeRange(0, attributeString.string.length)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sizeCell.attributeMessage = [attributeString mutableCopy];
            [sizeCell layoutIfNeeded];
            CGFloat calculateHeight = sizeCell.goodsTableView.contentSize.height;
            if (calculateHeight > 282) {
                calculateHeight = 282;
            }
            CGFloat messageSizeHeight = sizeCell.messageLabel.size.height;
            CGFloat titleSizeHeight = sizeCell.titleLabel.size.height;

            calculateHeight = calculateHeight + titleSizeHeight + messageSizeHeight + 24;
            CGSize size = CGSizeMake(SCREEN_WIDTH, calculateHeight + 32 + 116 + kIPHONEX_BOTTOM);
            STLLog(@"---- %f",calculateHeight);
            if (sizeCell.completion) {
                sizeCell.completion([attributeString mutableCopy], size);
            }
        });
    });
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [OSSVThemesColors col_000000:0.4];
        [self addSubview:self.contentView];
        
        UIView *topRound = [[UIView alloc] init];
        topRound.backgroundColor = [UIColor whiteColor];
        topRound.layer.cornerRadius = 6;
        [self.contentView addSubview:topRound];
        [topRound mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(14);
            make.top.equalTo(self.contentView.mas_top).offset(-6);
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.messageLabel];
        
        [self.contentView addSubview:self.goodsTableView];
        [self.contentView insertSubview:self.bottomView belowSubview:self.goodsTableView];
        [self.contentView addSubview:self.backOrPayButton];
        [self.contentView addSubview:self.addressButton];
        [self.contentView addSubview:self.closeButton];
        
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 532 + 32);
        
//        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.bottom.trailing.mas_equalTo(self);
//            make.height.mas_equalTo(532 + 34);
//        }];
        
        self.tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.tipButton setImage:[UIImage imageNamed:@"coupon_use_desc"] forState:UIControlStateNormal];
        [self.tipButton addTarget:self action:@selector(actionTip:) forControlEvents:UIControlEventTouchUpInside];
        self.tipButton.imageView.contentMode = UIViewContentModeCenter;
        self.tipButton.hidden = true;
        [self.contentView addSubview:self.tipButton];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(9);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
        }];
        
        UIView *grayLine = [[UIView alloc] init];
        grayLine.backgroundColor = OSSVThemesColors.col_EEEEEE;
        [self.contentView addSubview:grayLine];
        [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(11);
            make.leading.trailing.equalTo(self.contentView);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-6);
            make.centerY.equalTo(self.titleLabel.mas_centerY);
        }];
        
        [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(24);
            make.centerY.equalTo(self.titleLabel.mas_centerY);
            make.trailing.equalTo(self.closeButton.mas_leading).offset(-10);
        }];
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(24);
        }];
        
        [self.goodsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.top.mas_equalTo(self.messageLabel.mas_bottom).offset(12);
            make.bottom.equalTo(112).offset(-kIPHONEX_BOTTOM);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-kIPHONEX_BOTTOM);
            make.height.mas_equalTo(112);
//            make.top.mas_equalTo(self.goodsTableView.mas_bottom);
        }];
        
        [self.backOrPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.bottomView.mas_top).offset(8);
            make.height.mas_equalTo(44);
        }];
        
        [self.addressButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.backOrPayButton.mas_bottom).offset(8);
            make.height.mas_equalTo(44);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGetst:)];
        [self.contentView addGestureRecognizer:panGest];
        
    }
    return self;
}

- (void)setCartGoddsArray:(NSMutableArray<OSSVCartGoodsModel *> *)cartGoddsArray {
    _cartGoddsArray = cartGoddsArray;
    [self.goodsTableView reloadData];
}

- (void)setShielInfoModel:(AddressGoodsShieldInfoModel *)shielInfoModel {
    _shielInfoModel = shielInfoModel;
}

- (void)setHasCanShip:(BOOL)hasCanShip {
    _hasCanShip = hasCanShip;
    
    if (hasCanShip) {
        [self.backOrPayButton setTitle:[STLLocalizedString_(@"Remove_Pay", nil) uppercaseString] forState:UIControlStateNormal];
        [self.addressButton setTitle:[STLLocalizedString_(@"Check_Product_List", nil) uppercaseString] forState:UIControlStateNormal];
    } else {
        [self.backOrPayButton setTitle:[STLLocalizedString_(@"Back_to_Homepage", nil) uppercaseString] forState:UIControlStateNormal];
        [self.addressButton setTitle:[STLLocalizedString_(@"Change_Shipping_Address", nil) uppercaseString] forState:UIControlStateNormal];
    }
    
    if (self.justList) {
        self.tipButton.hidden = hasCanShip;
        
        for (OSSVCartGoodsModel *model in self.cartGoddsArray) {
            if ([model.shield_status integerValue] == 1) {
                self.tipButton.hidden = NO;
                break;
            }
        }
        
        [self.goodsTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(0);
        }];

    }
    
    [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(self.justList ? 0 : 24);
    }];
    
}
- (void)setContentHeight:(CGFloat)contentHeight {
    
    if (contentHeight <= 0) {
        contentHeight = 532 + 32;
    }
    _contentHeight = contentHeight;
    CGRect frame = self.contentView.frame;
    frame.size.height = contentHeight;
    self.contentView.frame = frame;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self) {
        return YES;
    }
    return NO;
}


#pragma mark  展示商品列表
-(void)show {
    
    if (self.justList) {
        self.titleLabel.text = STLLocalizedString_(@"productList", nil);
        self.backOrPayButton.hidden = YES;
        self.addressButton.hidden = YES;
    }else{
        self.titleLabel.text = STLLocalizedString_(@"Tips", nil);
        self.backOrPayButton.hidden = NO;
        self.addressButton.hidden = NO;
    }
    
    self.hidden = NO;
    
    if (self.contentHeight <= 0) {
        self.contentHeight = 532 + 32;
    }
    
    self.goodsTableView.scrollEnabled = YES;
    if (self.cartGoddsArray.count <= 2) {
        self.goodsTableView.scrollEnabled = NO;
    }
    //121
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [OSSVThemesColors col_000000:0.4];
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetHeight(self.frame) - self.contentHeight;
        self.contentView.frame = frame;
    }];

}

- (void)dismiss {

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = SCREEN_HEIGHT;
        self.contentView.frame = frame;
        self.backgroundColor = [OSSVThemesColors col_000000:0.0];

        @weakify(self)
        if (self.cancelViewBlock) {
            @strongify(self)
            self.cancelViewBlock();
        }

    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)actionTap {
    [self dismiss];
}

- (void)actionClose:(UIButton *)sender {
    [self dismiss];
}

- (void)actionPay:(UIButton *)sender {
    if (self.checkTipEventBlock) {
        self.checkTipEventBlock(self.hasCanShip ? CheckOutEventPay: CheckOutEventHome);
    }
    [self dismiss];
}

- (void)actionAddress:(UIButton *)sender {
    if (self.checkTipEventBlock) {
        self.checkTipEventBlock(self.hasCanShip ? CheckOutEventProducts: CheckOutEventAddress);
    }
    [self dismiss];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cartGoddsArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return APP_TYPE == 3 ? 96 : 121;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVProductListCell.class) forIndexPath:indexPath];
    cell.rateModel = self.rateModel;
    cell.cartGoodsModel = self.cartGoddsArray[indexPath.row];
//    cell.lineView.hidden = YES;
//    cell.showLeftCount = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)actionTip:(UIButton *)sender {
    self.tipMessage = [NSString couponUseDesc];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:self.tipMessage];
    [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
            } range:NSMakeRange(0, att.string.length)];
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:YES showHeightIndex:0 title:@"" message:att buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
    }];
}

- (void)setAttributeMessage:(NSAttributedString *)attributeMessage {
    _attributeMessage = attributeMessage;
    self.messageLabel.attributedText = attributeMessage;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    _messageLabel.font = [UIFont systemFontOfSize:13];
    _messageLabel.numberOfLines = 0;
}
#pragma mark - setter/getter

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_16"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = STLLocalizedString_(@"Tips", nil);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _messageLabel.numberOfLines = 0;
        
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _messageLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _messageLabel;
}

- (UITableView *)goodsTableView {
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _goodsTableView.contentInset = UIEdgeInsetsMake(0, 0, 12 + 34, 0);
        _goodsTableView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _goodsTableView.delegate = self;
        _goodsTableView.dataSource = self;
        _goodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_goodsTableView registerClass:[OSSVProductListCell class] forCellReuseIdentifier:NSStringFromClass(OSSVProductListCell.class)];
    }
    return _goodsTableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomView;
}

- (UIButton *)backOrPayButton {
    if (!_backOrPayButton) {
        _backOrPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backOrPayButton setTitle:STLLocalizedString_(@"Back_to_Homepage", nil) forState:UIControlStateNormal];
        _backOrPayButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_backOrPayButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _backOrPayButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _backOrPayButton.layer.cornerRadius = 2;
        _backOrPayButton.layer.masksToBounds = YES;
        
        [_backOrPayButton addTarget:self action:@selector(actionPay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backOrPayButton;
}

- (UIButton *)addressButton {
    if (!_addressButton) {
        _addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressButton setTitle:STLLocalizedString_(@"Change_Shipping_Address", nil) forState:UIControlStateNormal];
        [_addressButton setTitleColor:[OSSVThemesColors col_666666] forState:UIControlStateNormal];
        _addressButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _addressButton.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _addressButton.layer.cornerRadius = 2;
        _addressButton.layer.masksToBounds = YES;
        _addressButton.layer.borderWidth = 1;
        _addressButton.layer.borderColor = [OSSVThemesColors col_999999].CGColor;
        [_addressButton addTarget:self action:@selector(actionAddress:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _addressButton;
}

- (void)panGetst:(UIPanGestureRecognizer *)pan {
    
    CGFloat topSpace = SCREEN_HEIGHT * 0.2;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _panGestureBeginPoint = [pan locationInView:self];

        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [pan locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            STLLog(@"----: move %f",deltaY);
            
            if (deltaY > 0) {
                self.contentView.top = topSpace + deltaY;
            } else if(deltaY <= 0) {
                self.contentView.top = topSpace;
            }
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            //CGPoint v = [pan velocityInView:self];
            CGPoint p = [pan locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (deltaY > 0) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    if (deltaY >= 160) {
                        self.contentView.top = SCREEN_HEIGHT;
                    } else {
                        self.contentView.top = topSpace;
                    }
                } completion:^(BOOL finished) {
                    if (deltaY >= 160) {
                        [self dismiss];
                    }
                }];
            } else if(deltaY <=0) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.contentView.top = topSpace;
                } completion:^(BOOL finished) {
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            
        }
        default:break;
    }
}
@end
