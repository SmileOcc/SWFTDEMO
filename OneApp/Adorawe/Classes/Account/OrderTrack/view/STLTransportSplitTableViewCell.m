//
//  OSSVTransportcSplitcTableCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransportcSplitcTableCell.h"
#import "STLTransportSplitCollectionViewCell.h"

//Controllers
#import "OSSVDetailsVC.h"

#import "OSSVTransporteSpliteGoodsModel.h"
#import "UIView+WhenTappedBlocks.h"

@interface OSSVTransportcSplitcTableCell ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UIView  *trackBgView;//整块儿背景
@property (nonatomic, strong) UIView  *carImgBg; //物流车背景
@property (nonatomic, strong) UIImageView *trackCarImgView; //物流小车
@property (nonatomic, strong) UILabel *transitLabel;//物流状态
@property (nonatomic, strong) UILabel *tradingStatusLabel;//状态描述
@property (nonatomic, strong) UILabel *trackCodeNum;//物流单号
@property (nonatomic, strong) YYAnimatedImageView *addressImg;//地址图标
@property (nonatomic, strong) UILabel *addressLabel;//地址
@property (nonatomic, strong) UILabel *timeLabel;   //时间
@property (nonatomic, strong) YYAnimatedImageView *arrowImg; //右箭头
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *goodsNumLabel; //商品总数
@property (nonatomic, strong) NSMutableArray *goodsArray;

@end

@implementation OSSVTransportcSplitcTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = STLThemeColor.col_F5F5F5;
        [self.contentView addSubview:self.trackBgView];
        [self.trackBgView addSubview:self.carImgBg];
        [self.trackBgView addSubview:self.transitLabel];
        [self.trackBgView addSubview:self.tradingStatusLabel];
        [self.trackBgView addSubview:self.trackCodeNum];
        [self.trackBgView addSubview:self.addressImg];
        [self.trackBgView addSubview:self.addressLabel];
        [self.trackBgView addSubview:self.timeLabel];
        [self.trackBgView addSubview:self.arrowImg];
        [self.carImgBg addSubview:self.trackCarImgView];
        [self.trackBgView addSubview:self.bottomLineView];
        [self.contentView addSubview:self.collectionView];
        [self.contentView addSubview:self.goodsNumLabel];
    }
    return self;
}

- (NSMutableArray *)goodsArray {
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}
#pragma mark --CELL赋值
- (void)setTrackListModel:(OSSVTrackeListeMode *)trackListModel {
    _trackListModel = trackListModel;
    [self.goodsArray removeAllObjects];
    int totalNum = 0;
    if (STLJudgeNSArray(trackListModel.goodsList)) {
        [self.goodsArray addObjectsFromArray:trackListModel.goodsList];
        if (self.goodsArray.count) {
            for (int i = 0; i < trackListModel.goodsList.count; i++) {
                totalNum += trackListModel.goodsList[i].goodNumber.intValue;
            }
        }
    }
    if (totalNum > 1) {
        self.goodsNumLabel.text = [NSString stringWithFormat:@"%d %@", totalNum, STLLocalizedString_(@"checkOutItems", nil)];

    } else {
        self.goodsNumLabel.text = [NSString stringWithFormat:@"%d %@", totalNum, STLLocalizedString_(@"checkOutItem", nil)];
    }

    if (STLToString(trackListModel.flow_num).length) {
        self.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@", STLLocalizedString_(@"TrackingNo", nil), STLToString(trackListModel.flow_num)];
    } else {
        self.trackCodeNum.text = STLLocalizedString_(@"NoTrackingNumber", nil);
    }
    self.transitLabel.text = STLToString(trackListModel.trackDetail.trackStatusLang);
    self.tradingStatusLabel.text = STLToString(trackListModel.trackDetail.trackText);
    self.timeLabel.text    = STLToString(trackListModel.trackDetail.originTime);
    self.addressLabel.text = STLToString(trackListModel.trackDetail.address);
    if (!self.addressLabel.text.length) {
        self.addressImg.hidden = YES;
        self.addressLabel.hidden = YES;
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.transitLabel.mas_leading);
            make.top.mas_equalTo(self.tradingStatusLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(@13);         }];
    } else {
        self.addressImg.hidden = NO;
        self.addressLabel.hidden = NO;
    }
    NSString *trackStatusStr = STLToString(trackListModel
                                           .trackDetail.trackStatus);
    
    // 运输中[In transit] 待发货[Shipment] 已发货[Shipped] 已签收[Delivered] 拒签【Refused】
    if ([trackStatusStr isEqualToString:@"Delivered"]) {
        self.trackBgView.userInteractionEnabled = YES;
        self.arrowImg.hidden = NO;
        self.trackCarImgView.image = [UIImage imageNamed:@"alreadySign"];
    } else if ([trackStatusStr isEqualToString:@"In transit"]) {
        self.trackBgView.userInteractionEnabled = YES;
        self.arrowImg.hidden = NO;

        self.trackCarImgView.image = [UIImage imageNamed:@"transporting_white"];
    } else if ([trackStatusStr isEqualToString:@"Shipped"]) {
        self.trackBgView.userInteractionEnabled = YES;
        self.arrowImg.hidden = NO;

        self.trackCarImgView.image = [UIImage imageNamed:@"alreadyShip_white"];
    } else if ([trackStatusStr isEqualToString:@"Refused"]) {
        self.trackCarImgView.image = [UIImage imageNamed:@"refuseSign_icon"];
        self.trackBgView.userInteractionEnabled = YES;
        self.arrowImg.hidden = NO;
    } else {
        self.trackCarImgView.image = [UIImage imageNamed:@"wait_ship_white"];
        self.trackBgView.userInteractionEnabled = NO; //待发货状态不跳转物流详情
        self.arrowImg.hidden = YES;

    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.trackBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.equalTo(95*kScale_375);
    }];
    [self.carImgBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.trackBgView.mas_leading).offset(12);
        make.height.width.mas_equalTo(@24);
        make.centerY.mas_equalTo(self.trackBgView.mas_centerY);
    }];
    
    [self.trackCarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.carImgBg.mas_top).offset(4);
        make.leading.mas_equalTo(self.carImgBg.mas_leading).offset(4);
        make.height.width.mas_equalTo(@16);
    }];
    
    [self.transitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.trackBgView.mas_leading).offset(44);
        make.top.mas_equalTo(self.trackBgView.mas_top).offset(10);
        make.height.equalTo(@18);
    }];
    
    [self.tradingStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.transitLabel.mas_leading);
        make.top.mas_equalTo(self.transitLabel.mas_bottom).offset(4);
        make.height.equalTo(@15);
    }];
    
    [self.addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.transitLabel.mas_leading);
        make.top.mas_equalTo(self.tradingStatusLabel.mas_bottom).offset(6);
        make.height.width.equalTo(@12);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressImg.mas_trailing).offset(1.5);
        make.height.equalTo(@15);
        make.trailing.mas_equalTo(self.arrowImg.mas_leading).offset(-4);
        make.top.equalTo(self.addressImg.mas_top);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.transitLabel.mas_leading);
        make.bottom.mas_equalTo(self.trackBgView.mas_bottom).offset(-12);
        make.height.mas_equalTo(@13);
    }];
    
    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.trackBgView.mas_trailing).offset(-12);
        make.height.width.equalTo(@24);
        make.centerY.mas_equalTo(self.trackBgView.mas_centerY);
    }];
    
    [self.trackCodeNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImg.mas_leading);
        make.top.mas_equalTo(self.mas_top).offset(13);
        make.height.equalTo(13);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.trackBgView);
        make.height.equalTo(0.5);
        make.bottom.mas_equalTo(self.trackBgView.mas_bottom).offset(-0.5);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.top.mas_equalTo(self.trackBgView.mas_bottom);
        make.width.equalTo(SCREEN_WIDTH - 62.f);
    }];
    
    [self.goodsNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.collectionView.mas_trailing);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.bottom.equalTo(self.collectionView.mas_bottom);
        make.top.equalTo(self.collectionView.mas_top);
    }];
}

- (UIView *)trackBgView {
    if (!_trackBgView) {
        @weakify(self)
        _trackBgView = [UIView new];
        _trackBgView.userInteractionEnabled = YES;
        _trackBgView.backgroundColor = STLThemeColor.col_FFFFFF;
        [_trackBgView whenTapped:^{
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(jumpIntoTrackingListWithorderNumber:)]) {
                [self.delegate jumpIntoTrackingListWithorderNumber:STLToString(self.trackListModel.trackId)];
            }
        }];
    }
    return _trackBgView;
}

- (UIView *)carImgBg {

    if (!_carImgBg) {
        _carImgBg = [UIView new];
        _carImgBg.backgroundColor = STLThemeColor.col_0D0D0D;
        _carImgBg.layer.cornerRadius = 12.f;
        _carImgBg.layer.masksToBounds = YES;
    }
    return _carImgBg;
}

- (UIImageView *)trackCarImgView {
    if (!_trackCarImgView) {
        _trackCarImgView = [UIImageView new];
    }
    return _trackCarImgView;
}

- (UILabel *)transitLabel {
    if (!_transitLabel) {
        _transitLabel = [UILabel new];
        _transitLabel.textColor = STLThemeColor.col_0D0D0D;
        _transitLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _transitLabel;
}

- (UILabel *)tradingStatusLabel {
    if (!_tradingStatusLabel) {
        _tradingStatusLabel = [UILabel new];
        _tradingStatusLabel.textColor = STLThemeColor.col_0D0D0D;
        _tradingStatusLabel.font = [UIFont systemFontOfSize:13];
    }
    return _tradingStatusLabel;
}

- (UILabel *)trackCodeNum {
    if (!_trackCodeNum) {
        _trackCodeNum = [UILabel new];
        _trackCodeNum.textColor = STLThemeColor.col_666666;
        _trackCodeNum.font = [UIFont systemFontOfSize:11];
        _trackCodeNum.textAlignment = NSTextAlignmentRight;
    }
    return _trackCodeNum;
}

- (YYAnimatedImageView *)addressImg {
    if (!_addressImg) {
        _addressImg = [YYAnimatedImageView new];
        _addressImg.image = [UIImage imageNamed:@"address_min" ];
    }
    return _addressImg;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel new];
        _addressLabel.textColor = STLThemeColor.col_0D0D0D;
        _addressLabel.font = [UIFont systemFontOfSize:13];
    }
    return _addressLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = STLThemeColor.col_999999;
        _timeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _timeLabel;
}

- (YYAnimatedImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [YYAnimatedImageView new];
        [_arrowImg convertUIWithARLanguage]; //自动适配阿语翻转
        _arrowImg.image = [UIImage imageNamed:@"arrow_right_gray"];
    }
    return _arrowImg;
}
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = STLThemeColor.col_EEEEEE;
    }
    return _bottomLineView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[STLTransportSplitCollectionViewCell class] forCellWithReuseIdentifier:@"STLTransportSplitCollectionViewCell"];
        _collectionView.backgroundColor = STLThemeColor.col_FFFFFF;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.showsVerticalScrollIndicator = NO;

    }
    return _collectionView;
}

- (UILabel *)goodsNumLabel {
    if (!_goodsNumLabel) {
        _goodsNumLabel = [UILabel new];
        _goodsNumLabel.backgroundColor = STLThemeColor.col_FFFFFF;
        _goodsNumLabel.textColor = STLThemeColor.col_666666;
        _goodsNumLabel.font = [UIFont systemFontOfSize:11];
        _goodsNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _goodsNumLabel;
}

#pragma mark -- UICollectionDatasource And UICollectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVTransporteSpliteGoodsModel *goodModel = self.goodsArray[indexPath.item];
    STLTransportSplitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLTransportSplitCollectionViewCell" forIndexPath:indexPath];
    
    [cell.productImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(goodModel.goodImgUrl)]
                                placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                    options:kNilOptions
                                    completion:nil];
    NSInteger goodNum = STLToString(goodModel.goodNumber).integerValue;
    cell.numberLabel.text = [NSString stringWithFormat:@"X%ld",goodNum];
    cell.numberLabel.hidden = goodNum >1 ? NO : YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OSSVTransporteSpliteGoodsModel *goodModel = self.goodsArray[indexPath.item];

    OSSVDetailsVC *vc = [[OSSVDetailsVC alloc] init];
    vc.goodsId = STLToString(goodModel.goodId);
    vc.wid     = STLToString(goodModel.wid);
    vc.coverImageUrl = STLToString(goodModel.goodImgUrl);
    [self.viewController.navigationController pushViewController:vc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(72*kScale_375, 96*kScale_375);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0001;
}

@end
