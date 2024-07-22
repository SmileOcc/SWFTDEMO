//
//  ZFAccountUnpaidOrderCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountUnpaidOrderCell.h"
#import "ZFAccountCategorySectionModel.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFAccountHeaderCellTypeModel.h"
#import "ZFMyOrderListGoodsImageView.h"
#import "MyOrdersModel.h"
#import "ExchangeManager.h"
#import "ZFCountDownView.h"
#import "ZFTimerManager.h"
#import "ZFNotificationDefiner.h"

@interface ZFAccountUnpaidOrderCell ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIImageView       *topArrowView;
@property (nonatomic, strong) UIView            *mainBgView;
@property (nonatomic, strong) UIView            *tagIconView;
@property (nonatomic, strong) UILabel           *statusLabel;
@property (nonatomic, strong) UIButton          *timeButton;;
@property (nonatomic, strong) UIButton          *payButton;
@property (nonatomic, strong) UICollectionView  *imageCollectionView;
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *priceLabel;
@property (nonatomic, strong) UILabel           *countLabel;
@property (nonatomic, copy) NSString            *startTimeStamp;
@property (nonatomic, copy) NSString            *startTimerKey;
@end

@implementation ZFAccountUnpaidOrderCell

@synthesize cellTypeModel = _cellTypeModel;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.startTimerKey) {
        [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotificatio];
        self.contentView.backgroundColor = ZFCClearColor();
        self.backgroundColor = ZFCClearColor();
        self.clipsToBounds = NO; //不能删除topArrowView会漏出Cell
    }
    return self;
}

- (void)addNotificatio {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCountDownTimer) name:kTimerManagerUpdate object:nil];
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.mainBgView];
    [self.mainBgView addSubview:self.tagIconView];
    [self.mainBgView addSubview:self.statusLabel];
    [self.mainBgView addSubview:self.timeButton];
    [self.mainBgView addSubview:self.payButton];
    [self.mainBgView addSubview:self.imageCollectionView];
    [self.mainBgView addSubview:self.titleLabel];
    [self.mainBgView addSubview:self.priceLabel];
    [self.mainBgView addSubview:self.countLabel];
    [self.contentView addSubview:self.topArrowView];
}

- (void)zfAutoLayoutView {
    [self.mainBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 12, 0, 12));
    }];
    
    [self.topArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainBgView.mas_leading).offset(34);
        make.bottom.mas_equalTo(self.mainBgView.mas_top);
    }];
    
    [self.tagIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainBgView.mas_top).offset(8);
        make.leading.mas_equalTo(self.mainBgView.mas_leading);
        make.size.mas_equalTo(CGSizeMake(2, 15));
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tagIconView.mas_trailing).offset(12);
        make.centerY.mas_equalTo(self.tagIconView.mas_centerY);
    }];
    
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.statusLabel.mas_trailing).offset(12);
        make.centerY.mas_equalTo(self.tagIconView.mas_centerY);
        make.height.mas_greaterThanOrEqualTo(16);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mainBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.tagIconView.mas_centerY);
        make.height.mas_equalTo(22);
    }];
    
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.statusLabel.mas_leading);
        make.height.mas_equalTo(66).priorityHigh();
        make.trailing.mas_equalTo(self.payButton.mas_leading);
        make.bottom.mas_equalTo(self.mainBgView.mas_bottom).offset(-12);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.imageCollectionView.mas_trailing);
        make.centerY.mas_equalTo(self.imageCollectionView.mas_centerY).offset(-10);
        make.trailing.mas_equalTo(self.payButton.mas_trailing);
        make.width.mas_lessThanOrEqualTo(90);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.payButton.mas_trailing);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainBgView.mas_leading).offset(73);
        make.trailing.mas_equalTo(self.payButton.mas_leading).offset(-15);
        make.centerY.mas_equalTo(self.imageCollectionView.mas_centerY);
    }];
}

#pragma mark - Setter Method

- (void)setCellTypeModel:(ZFAccountHeaderCellTypeModel *)cellTypeModel {
    if ([_cellTypeModel.unpaidOrderModel isEqual:cellTypeModel.unpaidOrderModel]) return;
    
    _cellTypeModel = cellTypeModel;
    
    MyOrdersModel *unpaidOrderModel = self.cellTypeModel.unpaidOrderModel;
    NSInteger count = unpaidOrderModel.totalCount;
    if (count > 1) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.text = ZFToString(unpaidOrderModel.goods.firstObject.goods_title);
        self.titleLabel.hidden = NO;
    }
    self.countLabel.text = [NSString stringWithFormat:@"%@%ld",ZFLocalizedString(@"Bag_Total", nil) , count];
    self.countLabel.hidden = (count <= 1);
    
    CGFloat offsetY = (count <= 1) ? 0 : -10;
    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.imageCollectionView.mas_centerY).offset(offsetY);
    }];
    
    self.priceLabel.text =  [ExchangeManager transAppendPrice:unpaidOrderModel.total_fee
                                                     currency:unpaidOrderModel.order_currency
                                                    rateModel:unpaidOrderModel.order_exchange];
    
    self.timeButton.hidden = YES;
    if ([unpaidOrderModel.order_status integerValue] == 0) {  // 显示 payNow
        if (unpaidOrderModel.pay_left_time.integerValue > 0) {
            
            self.timeButton.hidden = NO;
            self.startTimerKey = [NSString stringWithFormat:@"%@%@", unpaidOrderModel.order_id, @"ZFAccountUnpaidOrderCell"];
            [[ZFTimerManager shareInstance] startTimer:self.startTimerKey];
            
            ///根据相应的key开启倒计时
            self.startTimeStamp = unpaidOrderModel.pay_left_time;
            [self reloadCountDownTimer];
            
        } else {
            if (self.startTimerKey) {
                [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
            }
        }
    }
    [self.imageCollectionView reloadData];
}

#pragma mark - ReloadTimer

///刷新倒计时
- (void)reloadCountDownTimer {
    if (!self.startTimerKey) return;
    double startTime = [[ZFTimerManager shareInstance] timeInterval:self.startTimerKey];
    double startTimeStamp = [self.startTimeStamp doubleValue];
    int timeOut =  startTimeStamp - startTime;
    
    if(timeOut <= 0){ //倒计时结束，关闭
        [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
        NSString *timeStamp = @"00 00:00:00";
        [self.timeButton setTitle:timeStamp forState:0];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        ZFPostNotification(kAccountUnpaidCountDownStopNotify, nil);
        
    } else {
        int day = timeOut / 3600 / 24;
        int hours = timeOut / 3600 % 24;
        int minute = timeOut / 60 % 60;
        int second = timeOut % 60;
        
        NSString *dayString = @"";
        NSString *hourString = @"";
        NSString *minuteString = @"";
        NSString *secondString = @"";
        
        if (day < 10) {
            dayString = [NSString stringWithFormat:@"%dD",day];
        } else {
            if (day > 99) day = 99;
            dayString = [NSString stringWithFormat:@"%d",day];
        }
        
        if (hours < 10) {
            hourString = [NSString stringWithFormat:@"0%d",hours];
        } else {
            hourString = [NSString stringWithFormat:@"%d",hours];
        }
        
        if (minute < 10) {
            minuteString = [NSString stringWithFormat:@"0%d",minute];
        } else {
            minuteString = [NSString stringWithFormat:@"%d",minute];
        }
        
        if (second < 10) {
            secondString = [NSString stringWithFormat:@"0%d",second];
        } else {
            secondString = [NSString stringWithFormat:@"%d",second];
        }
        
        NSString *countDownStamp = nil;
        if (day < 1) {
            countDownStamp = [NSString stringWithFormat:@"%@:%@:%@", hourString, minuteString, secondString];
        } else {
            countDownStamp = [NSString stringWithFormat:@"%@ %@:%@:%@", dayString, hourString, minuteString, secondString];
        }
        [self.timeButton setTitle:countDownStamp forState:0];
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellTypeModel.unpaidOrderModel.goods.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    if (![cell.backgroundView isKindOfClass:[UIImageView class]]) {
        cell.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 66)];
        cell.backgroundView.userInteractionEnabled = YES;
    }
    MyOrderGoodListModel *goodListModel = self.cellTypeModel.unpaidOrderModel.goods[indexPath.item];
    NSURL *url = [NSURL URLWithString:goodListModel.wp_image];
    [((UIImageView *)cell.backgroundView) yy_setImageWithURL:url
                                                 placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                                    progress:nil
                                                   transform:nil
                                                  completion:nil];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(48, 66);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self showOrderDetailAction];
}

#pragma mark - <ButtonAction>

- (void)showOrderDetailAction {
    if (self.cellTypeModel.accountCellActionBlock) {
        self.cellTypeModel.accountCellActionBlock(ZFAccountUnpaidCell_DetailAction, self.cellTypeModel.unpaidOrderModel);
    }
}

- (void)payButtonAction:(UIButton *)button {
    self.cellTypeModel.accountCellActionBlock(ZFAccountUnpaidCell_GoPayAction, self.cellTypeModel.unpaidOrderModel);
}

#pragma mark - <get lazy Load>


- (UIImageView *)topArrowView {
    if (!_topArrowView) {
        _topArrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topArrowView.image = [UIImage imageNamed:@"unpaid_arrow_up"];
    }
    return _topArrowView;
}

- (UIView *)mainBgView {
    if (!_mainBgView) {
        _mainBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainBgView.backgroundColor = [UIColor whiteColor];
        _mainBgView.layer.cornerRadius = 4;
        _mainBgView.layer.masksToBounds = YES;
        @weakify(self);
        [_mainBgView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self showOrderDetailAction];
        }];
    }
    return _mainBgView;
}

- (UIView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [[UIView alloc] initWithFrame:CGRectZero];
        _tagIconView.backgroundColor = ZFC0xFE5269();
    }
    return _tagIconView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = ZFC0xFE5269();
        _statusLabel.text = ZFLocalizedString(@"ZFPayStateWaiting", nil);
        _statusLabel.font = [UIFont systemFontOfSize:12.0];
        _statusLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _statusLabel;
}

- (UIButton *)timeButton {
    if (!_timeButton) {
        _timeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _timeButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_timeButton setTitle:ZFLocalizedString(@"6D 23:12:25", nil) forState:0];
        _timeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_timeButton setTitleColor:ZFCOLOR(0, 0, 0, 1) forState:0];
        _timeButton.userInteractionEnabled = NO;
        [_timeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        _timeButton.layer.cornerRadius = 8;
        _timeButton.layer.masksToBounds = YES;
    }
    return _timeButton;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_payButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_payButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        _payButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _payButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _payButton.titleLabel.contentMode = NSTextAlignmentCenter;
        [_payButton setTitle:ZFLocalizedString(@"CartOrderInfo_TotalPrice_Cell_PayNow",nil) forState:UIControlStateNormal];
        [_payButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _payButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _payButton.layer.cornerRadius = 11;
        _payButton.layer.masksToBounds = YES;
    }
    return _payButton;
}

- (UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 8;
        flowLayout.minimumInteritemSpacing = 0;
        //flowLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
        
        _imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _imageCollectionView.tag = 444;
        _imageCollectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.showsVerticalScrollIndicator = NO;
        _imageCollectionView.showsHorizontalScrollIndicator = NO;
        _imageCollectionView.alwaysBounceHorizontal = NO;
        
        [_imageCollectionView registerClass:[UICollectionViewCell class]  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _imageCollectionView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = ZFCOLOR_WHITE;
        _titleLabel.numberOfLines = 2;
        @weakify(self);
        [_titleLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self showOrderDetailAction];
        }];
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _priceLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _priceLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _priceLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.backgroundColor = ZFCOLOR_WHITE;
        _countLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _countLabel.font = [UIFont systemFontOfSize:11.0];
    }
    return _countLabel;
}

@end
