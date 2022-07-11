//
//  OSSVDetailTransportTimePopView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailTransportTimePopView.h"
#import "OSSVTransportTimeCell.h"
#import "OSSVTransportTimeListModel.h"
//#define GOODSDETAIL_TOP_SAPCE  (kIS_IPHONEX ? 400*DSCREEN_HEIGHT_SCALE : 400*DSCREEN_HEIGHT_SCALE)
#define GOODSDETAIL_TOP_SAPCE  SCREEN_HEIGHT * (kIS_IPHONEX ? 0.6 : 0.65)

@interface OSSVDetailTransportTimePopView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *timeListArray;
@property (nonatomic, strong) UIButton       *closeButton;
@end

@implementation OSSVDetailTransportTimePopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        [self addSubview:self.shadeView];
        [self addSubview:self.sheetView];
        [self.sheetView addSubview:self.headerView];
        [self.sheetView addSubview:self.headerTitleLabel];
        [self.sheetView addSubview:self.headerLineView];
        
        [self.sheetView addSubview:self.titleLabel];
        [self.sheetView addSubview:self.subTitleLabel];
        [self.sheetView addSubview:self.lineView];
        [self.sheetView addSubview:self.transportTimeTable];
        [self.sheetView addSubview:self.confirmButton];
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
        
        [self.headerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.centerX.mas_equalTo(self.headerView.mas_centerX);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.size.equalTo(CGSizeMake(16, 16));
        }];
        
        [self.headerLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.headerView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];
                
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.top.mas_equalTo(self.headerLineView.mas_bottom).offset(12);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(12);
            make.height.equalTo(0.5);
        }];
        
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.sheetView.mas_bottom).offset(kIS_IPHONEX ? -STL_TABBAR_IPHONEX_H : -8);
            make.height.mas_equalTo(44);
        }];

        [self.transportTimeTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.titleLabel);
            make.bottom.mas_equalTo(self.confirmButton.mas_top).offset(-20);
            make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
        }];
    }
    return self;
}


#pragma mark ------懒加载创建UI

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
            _sheetView.layer.cornerRadius = 3;
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

- (UILabel *)headerTitleLabel {
    if (!_headerTitleLabel) {
        _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _headerTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _headerTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        _headerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _headerTitleLabel.text = STLLocalizedString_(@"Delivery", nil);
    }
    return _headerTitleLabel;
}

- (UIView *)headerLineView {
    if (!_headerLineView) {
        _headerLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _headerLineView;
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
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _titleLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _titleLabel;
}


- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _subTitleLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _subTitleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
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

- (UITableView *)transportTimeTable {
    if (!_transportTimeTable) {
        _transportTimeTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _transportTimeTable.delegate = self;
        _transportTimeTable.dataSource = self;
        _transportTimeTable.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [_transportTimeTable registerClass:[OSSVTransportTimeCell class] forCellReuseIdentifier:@"OSSVTransportTimeCell"];
        _transportTimeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _transportTimeTable.bounces = NO;
        _transportTimeTable.showsVerticalScrollIndicator = NO;

    }
    return _transportTimeTable;
}


- (NSMutableArray *)timeListArray {
    if (!_timeListArray) {
        _timeListArray = [NSMutableArray array];
    }
    return _timeListArray;
}
#pragma mark ------赋值
- (void)updateTransportTimeList:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    NSArray *array = goodsInforModel.transportTimeModel.childrenContenArray;
    [self.timeListArray removeAllObjects];
    [self.timeListArray addObjectsFromArray:array];
    self.titleLabel.text = STLToString(goodsInforModel.transportTimeModel.titleSting);
    NSString *contentString = STLToString(goodsInforModel.transportTimeModel.contentSting);
    //判断字符串中是否包含：
    if (contentString.length && [contentString containsString:@":"]) {
        //以字符:中分隔成2个元素的数组
        NSArray *array = [contentString componentsSeparatedByString:@":"];
        NSLog(@"拆分的字符串： %@", array);
        NSString *firstStr = [NSString stringWithFormat:@"%@:", array[0]];
        NSString *secondStr = (NSString *)array[1];
        NSLog(@"第一组：%@", firstStr);
        NSLog(@"第二组：%@", secondStr);
        NSString *totalStr = [NSString stringWithFormat:@"%@%@", firstStr, secondStr];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
        [attStr addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(0, firstStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_0D0D0D range:NSMakeRange(firstStr.length, secondStr.length)];
        self.subTitleLabel.attributedText = attStr;
    }
    [self.transportTimeTable reloadData];
}

#pragma mark --UITableViewDatasource And Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVTransportTimeCell *cell  = (OSSVTransportTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"OSSVTransportTimeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    OSSVTransportTimeListModel *model = self.timeListArray[indexPath.row];
    cell.numLabel.text = STLToString(model.numberString);
    cell.contentLabel.text = [NSString stringWithFormat:@"   %@", STLToString(model.titleString)];
    cell.timeLabel.text    = [NSString stringWithFormat:@"   %@", STLToString(model.contentString)];
    
    if (indexPath.row%2 == 0) {
        cell.backgroundColor = OSSVThemesColors.col_FFFFFF;
    } else {
        cell.backgroundColor = OSSVThemesColors.col_F5F5F5;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32.f;
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
            } else if(deltaY <=0) {
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.sheetView.top = topSpace;
                } completion:^(BOOL finished) {
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            
        }
        default:break;
    }
}


#pragma mark  打开显示窗口
-(void)show {
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.sheetView.frame;
        frame.origin.y = SCREEN_HEIGHT - GOODSDETAIL_TOP_SAPCE;
        self.sheetView.frame = frame;
    }];
}


#pragma mark - 关闭收回窗口
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

#pragma mark -----私有方法
- (void)touchContinue:(UIButton *)sender {
    [self dismiss];
}

- (void)dismissPopView {
    [self dismiss];
}

- (void)closePopView {
    [self dismiss];
}

@end
