//
//  OSSVFastSalesCCell.m
// OSSVFastSalesCCell
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailsVC.h"
#import "OSSVFastSalesCCell.h"
#import "OSSVHomeFashSaleGoodsCCell.h"
#import "OSSVSecondsKillsModel.h"
#import "OSSVHomeGoodsListModel.h"
//Helps
#import "UIView+WhenTappedBlocks.h"
#import "MZTimerLabel.h"

#import "OSSVFlasttSaleCellModel.h"
@interface OSSVFastSalesCCell ()<MZTimerLabelDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *timeBgView; //时间背景
@property (nonatomic, strong) UIImageView *flashSaleImageV; //闪购图标
@property (nonatomic, strong) UILabel *flashLabel; //闪购label
@property (nonatomic, strong) UILabel *endLabel;   //endTime
@property (nonatomic, strong) UILabel *hourLabel;  //时
@property (nonatomic, strong) UILabel *minuteLabel; //分
@property (nonatomic, strong) UILabel *secondLabel; //秒
@property (nonatomic, strong) UILabel *pointLabel1; //：
@property (nonatomic, strong) UILabel *pointLabel2; //:
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *pointLabel3; //:

@property (nonatomic, strong) UIImageView *rightArrow; //右侧箭头
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) OSSVSecondsKillsModel *flashSaleModel;
@property (nonatomic, strong) NSMutableArray *goodsArray;
@property (nonatomic, strong) MZTimerLabel *countdownL;

@property (nonatomic, strong) OSSVFlasttSaleCellModel *cellModel;
@end


@implementation OSSVFastSalesCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _goodsArray = [NSMutableArray array];
        [self.contentView addSubview:self.timeBgView];
        [self.timeBgView addSubview:self.flashSaleImageV];
        [self.timeBgView addSubview:self.flashLabel];
        [self.timeBgView addSubview:self.endLabel];
        [self.timeBgView addSubview:self.hourLabel];
        [self.timeBgView addSubview:self.minuteLabel];
        [self.timeBgView addSubview:self.secondLabel];
        [self.timeBgView addSubview:self.pointLabel1];
        [self.timeBgView addSubview:self.pointLabel2];
        [self.timeBgView addSubview:self.rightArrow];
        [self.timeBgView addSubview:self.dayLabel];
        [self.timeBgView addSubview:self.pointLabel3];
        [self.contentView addSubview:self.collectionView];
        
        _countdownL = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
        _countdownL.delegate = self;
        [_countdownL setCountDownTime:0];
    }
    return self;
}

- (OSSVFlasttSaleCellModel *)cellModel {
    if (!_cellModel) {
        _cellModel = [[OSSVFlasttSaleCellModel alloc] init];
    }
    return _cellModel;
}
- (UIView *)timeBgView {
    if (!_timeBgView) {
        @weakify(self)
        _timeBgView = [UIView new];
        _timeBgView.backgroundColor = [UIColor whiteColor];
        _timeBgView.userInteractionEnabled = YES;
        [_timeBgView whenTapped:^{
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(jumpFlashSaleViewController)]) {
                [self.delegate jumpFlashSaleViewController];
            }
        }];
    }
    return _timeBgView;
}

- (UIImageView *)flashSaleImageV {
    if (!_flashSaleImageV) {
        _flashSaleImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash_Icon"]];
    }
    return _flashSaleImageV;
}

- (UILabel *)flashLabel {
    if (!_flashLabel) {
        _flashLabel = [UILabel new];
        _flashLabel.text = STLLocalizedString_(@"Flash_sale", nil);
        _flashLabel.font = [UIFont boldSystemFontOfSize:15];
        _flashLabel.textColor = OSSVThemesColors.col_131313;
    }
    return _flashLabel;
}

- (UILabel *)endLabel {
    if (!_endLabel) {
        _endLabel = [UILabel new];
        _endLabel.textAlignment = NSTextAlignmentRight;
        _endLabel.font = [UIFont systemFontOfSize:13];
        _endLabel.textColor = OSSVThemesColors.col_131313;
    }
    return _endLabel;
}

- (UILabel *)hourLabel {
    if (!_hourLabel) {
        _hourLabel = [UILabel new];
        _hourLabel.font = [UIFont systemFontOfSize:12];
        _hourLabel.textColor = [UIColor whiteColor];
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _hourLabel;
}

- (UILabel *)minuteLabel {
    if (!_minuteLabel) {
        _minuteLabel = [UILabel new];
        _minuteLabel.font = [UIFont systemFontOfSize:12];
        _minuteLabel.textColor = [UIColor whiteColor];
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _minuteLabel;
}
- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [UILabel new];
        _secondLabel.font = [UIFont systemFontOfSize:12];
        _secondLabel.textColor = [UIColor whiteColor];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _secondLabel;
}
- (UILabel *)pointLabel1 {
    if (!_pointLabel1) {
        _pointLabel1 = [UILabel new];
        _pointLabel1.text = @":";
        _pointLabel1.backgroundColor = [UIColor whiteColor];
        _pointLabel1.font = [UIFont systemFontOfSize:12];
        _pointLabel1.textColor = OSSVThemesColors.col_131313;
        _pointLabel1.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel1;
}

- (UILabel *)pointLabel2 {
    if (!_pointLabel2) {
        _pointLabel2 = [UILabel new];
        _pointLabel2.text = @":";
        _pointLabel2.backgroundColor = [UIColor whiteColor];
        _pointLabel2.font = [UIFont systemFontOfSize:12];
        _pointLabel2.textColor = OSSVThemesColors.col_131313;
        _pointLabel2.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel2;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel new];
        _dayLabel.font = [UIFont systemFontOfSize:12];
        _dayLabel.textColor = [UIColor whiteColor];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _dayLabel;
}
- (UILabel *)pointLabel3 {
    if (!_pointLabel3) {
        _pointLabel3 = [UILabel new];
        _pointLabel3.text = @"D";
        _pointLabel3.backgroundColor = [UIColor whiteColor];
        _pointLabel3.font = [UIFont systemFontOfSize:11];
        _pointLabel3.textColor = OSSVThemesColors.col_0D0D0D;
        _pointLabel3.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel3;
}


- (UIImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"flash_Sale_rightArrow"];
        [_rightArrow convertUIWithARLanguage]; //自动适配阿语翻转
    }
    return _rightArrow;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[OSSVHomeFashSaleGoodsCCell class] forCellWithReuseIdentifier:@"STLFashSaleProductCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
    }
    return _collectionView;
}

#pragma mark --UICollectionViewDelegate And UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVHomeGoodsListModel *goodList = self.goodsArray[indexPath.row];
    OSSVHomeFashSaleGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLFashSaleProductCollectionViewCell" forIndexPath:indexPath];
    [cell.productImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(goodList.goodsImageUrl)]
                                placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                    options:kNilOptions
                                 completion:nil];
    
    cell.priceLabel.text = STLToString(goodList.active_price_converted);
    
    if (STLIsEmptyString(goodList.lineMarketPrice.string)) {
        
        NSString *oldPrice = STLToString(goodList.market_price_converted);
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:oldPrice];
        
        [attStr addAttributes:@{NSForegroundColorAttributeName:OSSVThemesColors.col_999999,
                                NSFontAttributeName:[UIFont systemFontOfSize:9],
                                NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)
        } range:NSMakeRange(0, oldPrice.length)];
        goodList.lineMarketPrice = attStr;
    }

    cell.oldPriceLabel.attributedText = goodList.lineMarketPrice;
    cell.activityStateView.hidden = YES;
    if (STLToString(goodList.discount).intValue > 0) {
        cell.activityStateView.hidden = NO;
        [cell.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodList.discount)];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.model.channelName];
    NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                      @"attr_node_1":attrNode1,
                                      @"attr_node_2":@"home_channel_flash",
                                      @"attr_node_3":@"",
                                      @"position_number":@(indexPath.row + 1),
                                      @"venue_position":@(0),
                                      @"action_type":@(0),
                                      @"url":@"",
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
    
    //数据GA埋点曝光 广告点击
                        
                        // item
                        NSMutableDictionary *item = [@{
                    //          kFIRParameterItemID: $itemId,
                    //          kFIRParameterItemName: $itemName,
                    //          kFIRParameterItemCategory: $itemCategory,
                    //          kFIRParameterItemVariant: $itemVariant,
                    //          kFIRParameterItemBrand: $itemBrand,
                    //          kFIRParameterPrice: $price,
                    //          kFIRParameterCurrency: $currency
                        } mutableCopy];


                        // Prepare promotion parameters
                        NSMutableDictionary *promoParams = [@{
                    //          kFIRParameterPromotionID: $promotionId,
                    //          kFIRParameterPromotionName:$promotionName,
                    //          kFIRParameterCreativeName: $creativeName,
                    //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                    //          @"screen_group":@"Home"
                        } mutableCopy];

                        // Add items
                        promoParams[kFIRParameterItems] = @[item];
                        
                        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    
    ///**********************更改跳转到闪购列表*************************//
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpFlashSaleViewController)]) {
        [self.delegate jumpFlashSaleViewController];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (APP_TYPE == 3) {
        return CGSizeMake(90*kScale_375, 126*kScale_375);
    } else {
        return CGSizeMake(90*kScale_375, 156*kScale_375);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 12, 9, 12);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0001;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(44*kScale_375));
    }];
    
    [self.flashSaleImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.timeBgView.mas_leading).offset(12);
        make.height.width.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.flashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.flashSaleImageV.mas_trailing).offset(2);
        make.height.mas_equalTo(@24);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.timeBgView.mas_trailing).offset(-12);
        make.width.height.mas_equalTo(@24);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.rightArrow.mas_leading).offset(-1);
        make.width.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.pointLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.secondLabel.mas_leading);
        make.width.mas_equalTo(@8);
        make.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.pointLabel2.mas_leading);
        make.width.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.pointLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.minuteLabel.mas_leading);
        make.width.mas_equalTo(@8);
        make.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];

    [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.pointLabel1.mas_leading);
        make.width.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];

    [self.pointLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.hourLabel.mas_leading).offset(-2);
        make.width.mas_equalTo(@9);
        make.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];

    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.pointLabel3.mas_leading).offset(-2);
        make.width.height.mas_equalTo(@18);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];

    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.dayLabel.mas_leading).offset(-10);
        make.height.mas_equalTo(@24);
        make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.timeBgView.mas_bottom);
        if (APP_TYPE == 3) {
            make.height.mas_equalTo(@(135*kScale_375));
        } else {
            make.height.mas_equalTo(@(165*kScale_375));
        }
    }];
    
 }

#pragma mark ---数据赋值
-(void)setModel:(id<CollectionCellModelProtocol>)model {
    _model = model;
    if ([_model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        OSSVSecondsKillsModel *model = (OSSVSecondsKillsModel *)_model.dataSource;
        self.flashSaleModel = model;
        self.endLabel.text = self.flashSaleModel.endStr;
        [self.goodsArray removeAllObjects];
        NSArray *goods = [NSArray array];
        if ([self.flashSaleModel.goodsList isKindOfClass:[NSArray class]]) {
            goods = self.flashSaleModel.goodsList;
        }
        [self.goodsArray addObjectsFromArray:goods];
        //取出离活动结束剩余的秒数
        double endTime = self.flashSaleModel.timeCount;
        NSLog(@"返回的剩余秒数：%lf", endTime);
        if (endTime > 0) {
            [_countdownL reset];
            [_countdownL setCountDownTime:endTime];
            [_countdownL start];

        } else {
            [_countdownL reset];
            [_countdownL setCountDownTime:0];
            [_countdownL start];
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - MZTimerLabelDelegate
-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    
}

-(void)timerLabel:(MZTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType {
    NSInteger second = (int)time  % 60;
    NSInteger minute = ((int)time / 60) % 60;
    NSInteger hours = ((int)time / 3600) % 24;
    NSInteger  days  = ((int)time / 3600)/24 ;
    if (second < 0) {
        second = 0;
    }
    if (minute < 0) {
        minute = 0;
    }
    if (hours < 0) {
        hours = 0;
    }
    if (days < 1) {
        days = 0;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.secondLabel.hidden = YES;
            self.pointLabel2.hidden = YES;
            [self.minuteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.rightArrow.mas_leading).offset(-30); //这个约束有点奇怪，只有这样才能更接近设计的要求
                make.width.height.mas_equalTo(@18);
                make.centerY.mas_equalTo(self.timeBgView.centerY);
            }];

        }else {
            self.dayLabel.hidden = YES;
            self.pointLabel3.hidden = YES;
            [self.endLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.hourLabel.mas_leading).offset(-10);
                make.height.mas_equalTo(@18);
                make.centerY.mas_equalTo(self.timeBgView.centerY);
            }];
        }
    }
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",(long)hours];
        self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(long)minute];
        self.dayLabel.text = [NSString stringWithFormat:@"%02ld",(long)second];
        self.secondLabel.text =  [NSString stringWithFormat:@"%02ld",(long)days];
        self.pointLabel3.text = @":";
        self.pointLabel2.text = @"D";
        [self.pointLabel3 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(4);
        }];
        
        [self.pointLabel2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(10);
        }];


    } else {
        self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(long)hours];
        self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",(long)minute];
        self.secondLabel.text = [NSString stringWithFormat:@"%02ld",(long)second];
        self.dayLabel.text =  [NSString stringWithFormat:@"%02ld",(long)days];
    }
    
}

@end
