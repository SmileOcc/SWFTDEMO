//
//  STLSecondKillBannerView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveySecondsKillAdvsView.h"
#import "ZJJTimeCountDown.h"
#import "OSSVPuresImgCCell.h"

@interface OSSVDiscoveySecondsKillAdvsView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) YYAnimatedImageView *headerView;
@property (nonatomic, strong) UIView *countView;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) ZJJTimeCountDownLabel *countDownLabel;
@property (nonatomic, strong) UICollectionView *bannerView;
@property (nonatomic, assign) SecondKillViewType type;
@property (nonatomic, strong) ZJJTimeCountDown *countDown;
@property (nonatomic, assign) BOOL isLoadCountDown;
@end

@implementation OSSVDiscoveySecondsKillAdvsView

-(instancetype)initWithType:(SecondKillViewType)type
{
    self = [super init];
    
    if (self) {
        self.type = type;
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.headerView];
    [self addSubview:self.countView];
    [self.countView addSubview:self.iconImage];
    [self.countView addSubview:self.iconLabel];
    [self.countView addSubview:self.countDownLabel];
    [self addSubview:self.countDownLabel];
    [self addSubview:self.bannerView];
    
    CGFloat height = HeaderHeight;
    if (self.type == Scroll_Type) {
        height = ScrollHeaderHeight;
    }
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).mas_offset(HeaderPadding);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_offset(height);//临时高度
    }];
    
    CGFloat countDownHeight = CountDownHeight;
    if (self.type == SecondKill_Type) {
        [self.countView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerView.mas_bottom);
            make.height.mas_offset(countDownHeight);
            make.centerX.mas_equalTo(self.headerView.mas_centerX);
        }];
        
        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.countView.mas_leading).mas_offset(15);
            make.trailing.mas_equalTo(self.iconLabel.mas_leading).mas_offset(-5);
        }];
        
        [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.iconImage.mas_trailing).mas_offset(5);
            make.height.mas_equalTo(self.countView);
            make.trailing.mas_equalTo(self.countDownLabel.mas_leading).mas_offset(-5);
        }];
        
        [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.iconLabel.mas_trailing).mas_offset(5);
            make.height.mas_equalTo(self.countView);
            make.trailing.mas_equalTo(self.countView.mas_trailing).mas_offset(-15);
            ///如果不设置一个固定的宽度，时间在变化的时候会相应的有微微的移动
            ///24是小黑宽的宽度，16是 : 的宽度  15是一个缺省宽度
            make.width.mas_offset(24 * 3 + 16 * 2 + 15);
        }];
    }
    
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.type == Scroll_Type) {
            make.top.mas_equalTo(self.headerView.mas_bottom);
        }else if (self.type == SecondKill_Type){
            make.top.mas_equalTo(self.countDownLabel.mas_bottom);
        }
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_offset(ProductCollectionHeight);
    }];
}

-(CGFloat)viewHeight
{
    if (self.type == SecondKill_Type) {
        return ProductCollectionHeight + HeaderHeight + CountDownHeight + HeaderPadding;
    }else if (self.type == Scroll_Type){
        return ProductCollectionHeight + ScrollHeaderHeight + HeaderPadding;
    }
    return 0;
}

-(void)reloadSecond:(ZJJTimeCountDown *)countDown
{
    if (self.type == SecondKill_Type) {
        [countDown deleteTimeLabel:self.countDownLabel];
        NSInteger time = self.model.timing.integerValue;
        ///拿到天数
        NSString *str_day = [NSString stringWithFormat:@"%ld",(long)time/86400];
        if (str_day.integerValue > 0) {
            //加一个 X D
            self.iconLabel.text = STLLocalizedString_(@"endIn", nil);
            NSString *XD = [NSString stringWithFormat:@"%@D", str_day];
            NSMutableAttributedString *iconDay = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.iconLabel.text, XD]];
            NSRange dayRange = [iconDay.string rangeOfString:XD];
            [iconDay addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:dayRange];
            self.iconLabel.attributedText = iconDay;
        }
        [countDown addTimeLabel:self.countDownLabel time:[NSString stringWithFormat:@"%ld", (long)time]];
    }
}

#pragma mark - datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger isMore = [self isMoreButton] ? 1 : 0;
    return [self.model.goods_list count] + isMore;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreButton] && indexPath.row == [self.model.goods_list count]) {
        OSSVPuresImgCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PureCell" forIndexPath:indexPath];
        cell.advEventModel = self.model.end_more;
        cell.size = CGSizeMake(ProductImageWidth, ProductImageHeight);
        return cell;
    }else{
        OSSVPductGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.model = self.model.goods_list[indexPath.row];
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreButton] && indexPath.row == [self.model.goods_list count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(STLDiscoverySecondKillDidClickViewMore:)]) {
            [self.delegate STLDiscoverySecondKillDidClickViewMore:self.model.end_more];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(STLDiscoverySecondKillDidChildView:jumpMode:type:)]) {
        OSSVHomeGoodsListModel *goodsModel = self.model.goods_list[indexPath.row];
        [self.delegate STLDiscoverySecondKillDidChildView:goodsModel jumpMode:self.model.banner type:self.type];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ProductImageWidth, ProductCollectionHeight - 10);
}

-(void)didClickHeader
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STLDiscoverySecondKillDidClickHeader:)]) {
        [self.delegate STLDiscoverySecondKillDidClickHeader:self.model.banner];
    }
}

-(BOOL)isMoreButton
{
    BOOL isMore = self.model.end_more ? YES : NO;
    return isMore;
}

#pragma mark - setter and getter

-(void)setModel:(OSSVSecondsKillsModel *)model
{
    _model = model;
    
    [self.headerView yy_setImageWithURL:[NSURL URLWithString:_model.banner.imageURL]
                                       placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                           options:kNilOptions
                                        completion:nil];
    
//    if ([self isMoreButton]) {
//        NSMutableArray *list = [_model.goods_list mutableCopy];
//        [list addObject:_model.end_more];
//        _model.goods_list = [list copy];
//    }
    
    [self.bannerView reloadData];
}

-(YYAnimatedImageView *)headerView
{
    if (!_headerView) {
        _headerView = ({
            YYAnimatedImageView *view = [[YYAnimatedImageView alloc] init];
            view.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickHeader)];
            [view addGestureRecognizer:tap];
            view;
        });
    }
    return _headerView;
}

-(UIView *)countView
{
    if (!_countView) {
        _countView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _countView;
}

-(UIImageView *)iconImage
{
    if (!_iconImage) {
        _iconImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"flash"];
            imageView;
        });
    }
    return _iconImage;
}

-(UILabel *)iconLabel
{
    if (!_iconLabel) {
        _iconLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"endIn", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:15];
            label;
        });
    }
    return _iconLabel;
}

-(ZJJTimeCountDownLabel *)countDownLabel
{
    if (!_countDownLabel) {
        _countDownLabel = ({
            ZJJTimeCountDownLabel *label = [[ZJJTimeCountDownLabel alloc] init];
            label.font = [UIFont systemFontOfSize:12];
            //设置文本自适应
            label.textAdjustsWidthToFitFont = YES;
            //边框模式
            label.textStyle = ZJJTextStlyeHHMMSSBox;
            //字体颜色
            label.textColor = [UIColor whiteColor];
            label.textHeight = 24;
            label.textWidth = 24;
            //单个文本背景颜色
            label.textBackgroundColor = [UIColor blackColor];
            //每个文本背景间隔
            label.textBackgroundInterval = 16;
            //设置圆角
            label.textBackgroundRadius = 2;
            label.textIntervalSymbol = @":";
            label.textIntervalSymbolColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.isRetainFinalValue = YES;
            label;
        });
    }
    return _countDownLabel;
}

-(UICollectionView *)bannerView
{
    if (!_bannerView) {
        _bannerView = ({
            CGFloat padding = 5;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumInteritemSpacing = padding;
            layout.minimumLineSpacing = padding;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.sectionInset = UIEdgeInsetsMake(padding*2, padding, 0, padding);
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = YES;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = OSSVThemesColors.col_F6F6F6;
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[OSSVPductGoodsCCell class] forCellWithReuseIdentifier:@"Cell"];
            [collectionView registerClass:[OSSVPuresImgCCell class] forCellWithReuseIdentifier:@"PureCell"];
            
            collectionView;
        });
    }
    return _bannerView;
}

@end
