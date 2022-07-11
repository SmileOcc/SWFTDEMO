//
//  OSSVDetailServiceDescView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailServiceDescView.h"
#import "OSSVDetailServiceTipModel.h"
#import "UIView+STLCategory.h"

//#define GOODSDETAIL_TOP_SAPCE  (kIS_IPHONEX ? 260*DSCREEN_HEIGHT_SCALE : 230*DSCREEN_HEIGHT_SCALE)
//#define GOODSDETAIL_TOP_SAPCE  (kIS_IPHONEX ? 375 : 315)

#define GOODSDETAIL_TOP_SAPCE  SCREEN_HEIGHT * (kIS_IPHONEX ? 0.6 : 0.65)

@interface OSSVDetailServiceDescView ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray        *imageArray;
@property (nonatomic, strong) UIView         *headerView;
@property (nonatomic, strong) UIView         *lineView;
@property (nonatomic, strong) UIButton       *closeButton;
@property (nonatomic, assign) CGPoint        panGestureBeginPoint;


@end
@implementation OSSVDetailServiceDescView

#pragma mark - 初始化界面
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.hidden = YES;

        
        [self addSubview:self.shadeView];
        [self addSubview:self.sheetView];
        
        [self.sheetView addSubview:self.headerView];
        [self.sheetView addSubview:self.titleLabel];
        [self.sheetView addSubview:self.confirmButton];
        [self.sheetView addSubview:self.serviceTable];
        [self.sheetView addSubview:self.lineView];
        [self.sheetView addSubview:self.closeButton];
        
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGetst:)];
        [self.sheetView addGestureRecognizer:panGest];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopView)];
        [self.shadeView addGestureRecognizer:tap];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.sheetView);
            make.top.mas_equalTo(self.sheetView);
            make.height.mas_equalTo(49);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.centerX.mas_equalTo(self.headerView.mas_centerX);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.size.equalTo(CGSizeMake(16, 16));
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.headerView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];

        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.sheetView.mas_bottom).offset(kIS_IPHONEX ? -STL_TABBAR_IPHONEX_H : -8);
            make.height.mas_equalTo(44);
        }];
        
        [self.serviceTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.sheetView);
            make.top.mas_equalTo(self.headerView.mas_bottom).offset(12);
            make.bottom.mas_equalTo(self.confirmButton.mas_top).mas_offset(0);
        }];
        
    }
    return self;
}

- (void)updateServices:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    
//    NSArray *tipsArray = goodsInforModel.tips_info;
//    __block NSString *secureShopping = @"";
//    __block NSString *paymentMethods = @"";
//    __block NSString *fastShipping = @"";
//    __block NSString *easyReturns = @"";
//
//    [tipsArray enumerateObjectsUsingBlock:^(OSSVTipsInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.position == 5) {
//            secureShopping = STLToString(obj.content);
//        } else if(obj.position == 6) {
//            paymentMethods = STLToString(obj.content);
//        } else if(obj.position == 7) {
//            fastShipping = STLToString(obj.content);
//        } else if(obj.position == 8) {
//            easyReturns = STLToString(obj.content);
//        }
//    }];
//
//    NSMutableArray *datasArray = [[NSMutableArray alloc] init];
//
//    [datasArray addObject:@{@"imgName" : @"detail_secure_shopping",
//                            @"title" : STLLocalizedString_(@"Secure_shopping", nil),
//                            @"content" : secureShopping}];
//
//    [datasArray addObject:@{@"imgName" : @"detail_payment_methods",
//                            @"title" : STLLocalizedString_(@"Payment_methods", nil),
//                            @"content" : paymentMethods}];
//
//    [datasArray addObject:@{@"imgName" : @"icon_fast_shipping_orange",
//                            @"title" : STLLocalizedString_(@"Fast_shipping", nil),
//                            @"content" : fastShipping}];
//
//    [datasArray addObject:@{@"imgName" : @"detail_eas_Returns",
//                            @"title" : STLLocalizedString_(@"Easy_Returns", nil),
//                            @"content" : easyReturns}];
//
//    self.serviceDatas = [[NSArray alloc] initWithArray:datasArray];
    
    UIImage *image1 = [UIImage imageNamed:@"detail_secure_shopping"];
    UIImage *image2 = [UIImage imageNamed:@"detail_payment_methods"];
    UIImage *image3 = [UIImage imageNamed:@"icon_fast_shipping_orange"];
    UIImage *image4 = [UIImage imageNamed:@"detail_eas_Returns"];
    self.imageArray = [NSArray arrayWithObjects:image1,image2,image3,image4,nil];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:goodsInforModel.serviceTipModel];
    [self.serviceTable reloadData];
}

#pragma mark - action
- (void)dismiss {

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.sheetView.frame;
        frame.origin.y = SCREEN_HEIGHT;
        self.sheetView.frame = frame;
        
        @weakify(self)
        if (self.closeViewBlock) {
            @strongify(self)
            self.closeViewBlock();
        }
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

-(void)show {
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.sheetView.frame;
        frame.origin.y = SCREEN_HEIGHT- GOODSDETAIL_TOP_SAPCE;
        self.sheetView.frame = frame;
    }];
}

- (void)closePopView {
    [self dismiss];
}
- (void)touchContinue:(UIButton*)sender {
    
    [self dismiss];
}

- (void)dismissPopView {
    [self dismiss];
}

- (void)panGetst:(UIPanGestureRecognizer *)pan {
    
    CGFloat topSpace = SCREEN_HEIGHT- GOODSDETAIL_TOP_SAPCE;
    
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
                self.sheetView.top = topSpace + deltaY;
            } else if(deltaY <= 0) {
                self.sheetView.top = topSpace;
            }
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            //CGPoint v = [pan velocityInView:self];
            CGPoint p = [pan locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (deltaY > 0) {
                
                @weakify(self)
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    if (deltaY >= 160) {
                        self.sheetView.top = SCREEN_HEIGHT;
                    } else {
                        self.sheetView.top = topSpace;
                    }
                } completion:^(BOOL finished) {
                    if (deltaY >= 160) {
                        if (self.closeViewBlock) {
                            @strongify(self)
                            self.closeViewBlock();
                            self.hidden = YES;
                        }
                    }
                }];
            } else if(deltaY <= 0){
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.sheetView.top = topSpace;
                } completion:^(BOOL finished) {
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            STLLog(@"----: canceled");

        }
        default:break;
    }
}


#pragma mark - UITableViewDelegate And UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailServiceDescCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailServiceDescCell" forIndexPath:indexPath];
    OSSVDetailServiceTipModel *model = self.dataArray[indexPath.row];
    if (self.imageArray.count > indexPath.row) {
        UIImage *image = self.imageArray[indexPath.row];
        cell.iconImageView.image = image;
    }
   
    NSString *titleString = STLToString(model.titleString);
    NSString *titleExt    = STLToString(model.titleExt);
    cell.descLabel.text   = [NSString stringWithFormat:@"%@%@", titleString, titleExt];
    
    NSString *contentStr = STLToString(model.contentString);
    NSString *contentExt = STLToString(model.contentExt);

    NSString *totalContentStr = [NSString stringWithFormat:@"%@%@", contentStr, contentExt];
    NSRange range = NSMakeRange(totalContentStr.length - contentExt.length, contentExt.length);
    
    NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;//连字符
    NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                              NSParagraphStyleAttributeName:paragraphStyle};
    
    NSMutableAttributedString * mutableAttrStr = [[NSMutableAttributedString alloc] initWithString:totalContentStr attributes:attrDict];
    
    if (contentExt.length) {
        if (indexPath.row == 0) {
            [mutableAttrStr yy_setColor:[OSSVThemesColors col_6C6C6C] range:NSMakeRange(0, totalContentStr.length - contentExt.length)];
            [mutableAttrStr yy_setColor:[OSSVThemesColors col_6C6C6C] range:range];
            [mutableAttrStr yy_setUnderlineStyle:NSUnderlineStyleSingle range:range];
            [mutableAttrStr yy_setUnderlineColor:[OSSVThemesColors col_6C6C6C] range:range];
            [mutableAttrStr yy_setFont:[UIFont systemFontOfSize:12] range:range];

            @weakify(self)
            [mutableAttrStr yy_setTextHighlightRange:range color:[OSSVThemesColors col_6C6C6C] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                STLLog(@"点击了 Terms Of Use");
                @strongify(self)
                if (self.gotoWebViewBlock) {
                    self.gotoWebViewBlock();
                }
            }];

        } else if (indexPath.row == 1) {
            [mutableAttrStr yy_setColor:[OSSVThemesColors col_6C6C6C] range:NSMakeRange(0, totalContentStr.length - contentExt.length)];

            [mutableAttrStr addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_6C6C6C] range:range];
            [mutableAttrStr yy_setFont:[UIFont systemFontOfSize:12] range:NSMakeRange(0, totalContentStr.length - contentExt.length)];

            
        } else {
            [mutableAttrStr addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_6C6C6C] range:NSMakeRange(0, totalContentStr.length)];
            [mutableAttrStr yy_setFont:[UIFont systemFontOfSize:12] range:NSMakeRange(0, totalContentStr.length)];
        }
    }
    cell.contentLabel.attributedText = mutableAttrStr;
     if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
       cell.contentLabel.textAlignment = NSTextAlignmentRight;
     } else {
     cell.contentLabel.textAlignment = NSTextAlignmentLeft;
    }

    return cell;
}

#pragma mark - LazyLoad


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _shadeView.backgroundColor = [OSSVThemesColors stlBlackColor];
        _shadeView.userInteractionEnabled = YES;
        [_shadeView setAlpha:0.3];
        
    }
    return _shadeView;
}

- (UIView *)sheetView {
    if (!_sheetView) {
        _sheetView = [[UIView alloc] init];
        _sheetView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, GOODSDETAIL_TOP_SAPCE);
        [_sheetView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
        if (APP_TYPE == 3) {
            
        }else{
            _sheetView.layer.cornerRadius = 3.f;
        }
        _sheetView.layer.masksToBounds = YES;
    }
    return _sheetView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headerView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"close_16"] forState:UIControlStateNormal];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"close_16"] forState:UIControlStateSelected];
        [_closeButton addTarget:self action:@selector(closePopView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = STLLocalizedString_(@"Service_Description", nil);
    }
    return _titleLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_confirmButton setTitle:STLLocalizedString_(@"confirm", nil) forState:UIControlStateNormal];
            _confirmButton.titleLabel.font = [UIFont stl_buttonFont:18];

        } else {
            [_confirmButton setTitle:STLLocalizedString_(@"confirm", nil).uppercaseString forState:UIControlStateNormal];
            _confirmButton.titleLabel.font = [UIFont stl_buttonFont:14];

        }
        _confirmButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        [_confirmButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(touchContinue:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}
- (UITableView *)serviceTable {
    if (!_serviceTable) {
        _serviceTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _serviceTable.delegate = self;
        _serviceTable.dataSource = self;
        _serviceTable.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [_serviceTable registerClass:[DetailServiceDescCell class] forCellReuseIdentifier:@"DetailServiceDescCell"];
        _serviceTable.estimatedRowHeight = 140.0;
        _serviceTable.rowHeight = UITableViewAutomaticDimension;
        _serviceTable.bounces = NO;
        _serviceTable.showsVerticalScrollIndicator = NO;
        _serviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _serviceTable;
}

@end





@implementation DetailServiceDescCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.contentLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(8);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(8);
            make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImageView.mas_bottom).mas_offset(6);
            make.leading.mas_equalTo(self.descLabel.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_greaterThanOrEqualTo(30);
        }];
        
    }
    return self;
}


- (void)setContentDic:(NSDictionary *)contentDic {
    _contentDic = contentDic;
    
    self.iconImageView.image = [UIImage imageNamed:contentDic[@"imgName"]];
    self.descLabel.text = contentDic[@"title"];
    
    self.contentLabel.text = @"";
    if (STLToString(contentDic[@"content"]).length > 0) {
        NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4;//连字符
        NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                  NSParagraphStyleAttributeName:paragraphStyle};
        
        NSAttributedString *attrStr =[[NSAttributedString alloc] initWithString:contentDic[@"content"] attributes:attrDict];
        
        self.contentLabel.attributedText = attrStr;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.contentLabel.textAlignment = NSTextAlignmentRight;
        } else {
            self.contentLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
}


#pragma mark - LazyLoad

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _descLabel.font = [UIFont systemFontOfSize:14];
    }
    return _descLabel;
}

- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 80;
        _contentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _contentLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _contentLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _contentLabel;
}


@end
