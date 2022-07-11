//
//  OSSVThemesCouponsCCell.m
// OSSVThemesCouponsCCell
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemesCouponsCCell.h"
#import "OSSVHomeCThemeModel.h"
#import <SVGKit.h>

@interface OSSVThemesCouponsCCell()

<
UICollectionViewDelegate,
UICollectionViewDataSource
>
@property (nonatomic, strong) UIImageView                             *bgImgV;
@property (nonatomic, strong) UICollectionView                        *collectionView;
@property (nonatomic, strong) UIButton                                *getAllBtn;

@property (nonatomic, assign) CGSize                                  itemSize;
@property (nonatomic, assign) CGSize                                  subItemSize;

@property (nonatomic, strong) OSSVHomeCThemeModel                    *couponsModel;

@property (nonatomic, copy) NSString                                 *selected_coupon_code;
@end

@implementation OSSVThemesCouponsCCell

@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

+ (CGSize)itemSize:(CGFloat)imageScale{

    return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*211/375);
}

+ (CGSize)subItemSize:(CGFloat)imageScale {
    return CGSizeMake(200, 86);
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemSize = CGSizeZero;
        self.subItemSize = CGSizeZero;
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self addSubview:self.bgImgV];
        [self addSubview:self.getAllBtn];
        [self addSubview:self.collectionView];
        
        [self.bgImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.bgImgV.image = [UIImage imageNamed:@"western"];
        
        [self.getAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.height.mas_equalTo(@0);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(0);
            make.trailing.mas_equalTo(self.mas_trailing).offset(0);
            make.bottom.mas_equalTo(self.getAllBtn.mas_top).offset(-12);
            make.height.mas_equalTo(@0);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCouponsSuccess:) name:kNotif_getCouponsSuccess object:nil];
    }
    return self;
}

- (void)getCouponsSuccess:(NSNotification *)notification{
    if ([self.selected_coupon_code containsString:@","]) {
        // 一键领取成功
        [self oneKeyGetSuccess];
    }else{
        // 单个领取成功
        [self onlyOneGetSuccessWithCode:self.selected_coupon_code];
    }
    
    NSDictionary *sensorsDic = @{@"coupon_id":self.selected_coupon_code, @"get_method":@"initiative"};
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ReceiveDiscount" parameters:sensorsDic];
}

// 一键领取
-(void)getAllBtnAction:(UIButton *)sender{
    [self getCouponsWithCouponCode:_couponsModel.coupon_real_str];
}

- (void)getCouponsWithCouponCode:(NSString *)coupon_code{
    if ([OSSVNSStringTool isEmptyString:coupon_code]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeCouponsCCell:couponsString:)]) {
        self.selected_coupon_code = coupon_code;
        [self.delegate stl_themeCouponsCCell:self couponsString:coupon_code];
    }
}

- (void)oneKeyGetSuccess{
    OSSVHomeCThemeModel *couponsModel = _couponsModel;
    NSArray <Coupon_item *> *couponItems = couponsModel.coupon_items;
    for (Coupon_item *item in couponItems) {
        item.is_received = 1;
        couponsModel.received = 1;
    }
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [HUDManager showHUDWithMessage:[couponsModel.btn_multi objectForKey:@"toast_ar"]];
    }else{
        [HUDManager showHUDWithMessage:[couponsModel.btn_multi objectForKey:@"toast_en"]];
    }
    _model.dataSource = couponsModel;
    self.model = _model;
    
}

- (void)onlyOneGetSuccessWithCode:(NSString *)coupon_code{
    OSSVHomeCThemeModel *couponsModel = _couponsModel;
    NSArray <Coupon_item *> *couponItems = couponsModel.coupon_items;
    for (Coupon_item *item in couponItems) {
        if ([item.coupon_code isEqualToString:self.selected_coupon_code] ) {
            item.is_received = 1;
            break;
        }
    }
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [HUDManager showHUDWithMessage:[couponsModel.btn objectForKey:@"toast_ar"]];
    }else{
        [HUDManager showHUDWithMessage:[couponsModel.btn objectForKey:@"toast_en"]];
    }
    _model.dataSource = couponsModel;
    self.model = _model;
}


#pragma mark - datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _couponsModel.coupon_items.count;
}
//首页和专题页滑动商品cell
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STLScrollerCouponsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLScrollerCouponsItemCell.class) forIndexPath:indexPath];
    cell.model = self.couponsModel;
    cell.itemModel = _couponsModel.coupon_items[indexPath.item];
    @weakify(self);
    cell.couponsBlock = ^(NSString * _Nonnull coupon_code) {
        @strongify(self);
        [self getCouponsWithCouponCode:coupon_code];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = collectionView.bounds.size.height;
    return CGSizeMake(200, h);
}

#pragma mark - setter and getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    
    self.itemSize = CGSizeZero;
    self.subItemSize = CGSizeZero;
    OSSVHomeCThemeModel *couponsModel = (OSSVHomeCThemeModel *)model.dataSource;
    
    _couponsModel = couponsModel;
    
    if (![OSSVNSStringTool isEmptyString:couponsModel.bg_image]) {
        [self.bgImgV yy_setImageWithURL:[NSURL URLWithString:couponsModel.bg_image] placeholder:nil];
    }else if (![OSSVNSStringTool isEmptyString:couponsModel.bg_color_val]){
        self.bgImgV.backgroundColor = [UIColor colorWithHexString:couponsModel.bg_color_val];
    }
    if ([couponsModel.get_type integerValue] == 1) {
        // 一件领取
        [self.getAllBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@36);
        }];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.getAllBtn.mas_top).offset(-12);
        }];
        self.getAllBtn.hidden = NO;
    }else{
        // 单个领取
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.getAllBtn.mas_top);
        }];
        self.getAllBtn.hidden = YES;
    }
    
    CGFloat h = [self getCollHeightWith:couponsModel.coupon_items withType:[couponsModel.get_type integerValue]];
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(h);
    }];
    
    
    NSString *btn_muti = [couponsModel.btn_multi objectForKey:@"theme"];
    NSArray *themeBtnS = [btn_muti componentsSeparatedByString:@","];
    
    [self.getAllBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor colorWithHexString:themeBtnS[0]]] forState:UIControlStateNormal];
    [self.getAllBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor colorWithHexString:themeBtnS[2]]] forState:UIControlStateSelected];
    if (self.getAllBtn.isSelected) {
        self.getAllBtn.layer.borderWidth = 1;
        self.getAllBtn.layer.borderColor = [UIColor colorWithHexString:themeBtnS[0]].CGColor;
    }else{
        self.getAllBtn.layer.borderWidth = 0;
    }
    [self.getAllBtn setTitleColor:[UIColor colorWithHexString:themeBtnS[1]] forState:UIControlStateNormal];
    [self.getAllBtn setTitleColor:[UIColor colorWithHexString:themeBtnS[3]] forState:UIControlStateSelected];
    
    NSString *str = nil;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        str = [_couponsModel.btn_multi objectForKey:@"text_ar"];
    }else{
        str = [_couponsModel.btn_multi objectForKey:@"text_en"];
    }
    [self.getAllBtn setTitle:str forState:UIControlStateSelected];
    
    if (self.couponsModel.received) {
        self.getAllBtn.selected = YES;
    }
    
    [self.collectionView layoutIfNeeded];
    
    
    if (![OSSVNSStringTool isEmptyString:self.selected_coupon_code] && ![self.selected_coupon_code containsString:@","]) {
        // 选中的单个
        OSSVHomeCThemeModel *couponsModel = _couponsModel;
        NSArray <Coupon_item *> *couponItems = couponsModel.coupon_items;
        for (int i= 0; i<couponItems.count ; i++) {
            Coupon_item *item = couponItems[i];
            if ([item.coupon_code isEqualToString:self.selected_coupon_code] ) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                break;
            }
        }
    }else{
        [self.collectionView reloadData];
    }
    
    if (_couponsModel.coupon_items.count - 1 >=0 && [OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.collectionView.contentOffset = CGPointMake(self.collectionView.contentSize.width - SCREEN_WIDTH,0);
    }
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 8;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[STLScrollerCouponsItemCell class] forCellWithReuseIdentifier:NSStringFromClass(STLScrollerCouponsItemCell.class)];
            
            collectionView;
        });
    }
    return _collectionView;
}

- (UIImageView *)bgImgV{
    if (!_bgImgV) {
        _bgImgV = [[UIImageView alloc] init];
        _bgImgV.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    return _bgImgV;
}

- (UIButton *)getAllBtn{
    if (!_getAllBtn) {
        _getAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAllBtn.backgroundColor = [OSSVThemesColors stlBlackColor];
        _getAllBtn.titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _getAllBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_getAllBtn setTitle:STLLocalizedString_(@"receiveAll", nil) forState:UIControlStateNormal];
        [_getAllBtn addTarget:self action:@selector(getAllBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getAllBtn;
}

- (CGFloat)getCollHeightWith:(NSArray <Coupon_item *>*)copons withType:(NSInteger)type{
    NSInteger count = 0;
    for (Coupon_item *item in copons) {
        count = MAX(item.content.count, count);
    }
    if (type == 1) {
        // 一件领取 有底部按钮
        return 74 + count * 16;
    }else{
        // 单个领取 无底部按钮 但是把时效label移到上面了 所以要加16
        return 82 + count * 16 + 16;
    }
}


@end

@interface STLScrollerCouponsItemCell()

@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UIImageView       *imgV;

@property (nonatomic, strong) UILabel           *titLab;
@property (nonatomic, strong) UILabel           *titFirstLab;
@property (nonatomic, strong) UILabel           *titSecondLab;
@property (nonatomic, strong) UILabel           *titThirdLab;

@property (nonatomic, strong) UILabel           *descLab;
@property (nonatomic, strong) UIButton          *getBtn;

@property (nonatomic, strong) UIView            *flagView;
@property (nonatomic, strong) UILabel           *flagLab;

@property (nonatomic, assign) CGFloat startY;// 圆角起始y的值

@end

@implementation STLScrollerCouponsItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.imgV];
        [self.contentView addSubview:self.titLab];
        [self.contentView addSubview:self.titFirstLab];
        [self.contentView addSubview:self.titSecondLab];
        [self.contentView addSubview:self.titThirdLab];
        [self.contentView addSubview:self.descLab];
        
        [self.contentView addSubview:self.getBtn];
        [self.contentView addSubview:self.flagView];
        [self.flagView addSubview:self.flagLab];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.top.mas_equalTo(self.bgView.mas_top);
            make.trailing.mas_equalTo(self.bgView.mas_trailing);
        }];
        
        [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(8);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(22);
        }];
        
        [self.titFirstLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titLab.mas_bottom).offset(2);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(0);
        }];
        [self.titSecondLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titFirstLab.mas_bottom).offset(2);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(0);
        }];
        [self.titThirdLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titSecondLab.mas_bottom).offset(2);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(0);
        }];

        
        [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(12);
        }];
        
        [self.getBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.height.mas_equalTo(24);
        }];
        
        [self.flagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titLab.mas_trailing).offset(2);;
            make.centerY.mas_equalTo(self.titLab.mas_centerY);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(@12);
        }];
        
        [self.flagLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flagView.mas_leading).offset(2);
            make.top.mas_equalTo(self.flagView.mas_top).offset(1);
            make.trailing.mas_equalTo(self.flagView.mas_trailing).offset(-2);
            make.bottom.mas_equalTo(self.flagView.mas_bottom).offset(-1);
        }];
        
        [self.contentView layoutIfNeeded];
        
    }
    return self;
}

- (void)setModel:(id)model{
    _model = model;
    OSSVHomeCThemeModel   *couponsModel = (OSSVHomeCThemeModel *)model;
    if ([couponsModel.get_type integerValue]== 1) {
        // 一件领取 有底部按钮
        self.startY = self.bounds.size.height - 36;
        self.getBtn.hidden = YES;
    }else if ([couponsModel.get_type integerValue] == 2){
        // 单个领取
        [self.descLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titThirdLab.mas_bottom).offset(2);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(12);
        }];
        
        self.startY = self.bounds.size.height - 48;
        self.getBtn.hidden = NO;
    }
    
    NSString *theme = couponsModel.theme;
    NSArray *themes = [theme componentsSeparatedByString:@","];
    
    NSString *color1 = themes[0];// 渐变1
    NSString *color2 = themes[1];// 渐变2
    NSString *color3 = themes[2];// 边框虚线
    
    [self addlayerWithView:self.bgView withStokeColor:[UIColor colorWithHexString:color3] fromColor:color1 toColor:color2 lineColor:color3];
    
    NSString *color4 = themes[3];// 标题描述
    self.titLab.textColor = [UIColor colorWithHexString:color4];
    NSString *color5 = themes[4];// 角标背景
    NSString *color6 = themes[5];// 角标文字
    
    NSString *color7 = themes[6];// 使用条件
    self.titFirstLab.textColor = [UIColor colorWithHexString:color7];
    self.titSecondLab.textColor = [UIColor colorWithHexString:color7];
    self.titThirdLab.textColor = [UIColor colorWithHexString:color7];
    NSString *color8 = themes[7];// 时效
    self.descLab.textColor = [UIColor colorWithHexString:color8];
    NSString *color9 = themes[8];// 邮戳
    
    NSString *btn = [couponsModel.btn objectForKey:@"theme"];
    NSArray *themeBtnS = [btn componentsSeparatedByString:@","];
    
    [self.getBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor colorWithHexString:themeBtnS[0]]] forState:UIControlStateNormal];
    [self.getBtn setBackgroundImage:[UIImage yy_imageWithColor:[UIColor colorWithHexString:themeBtnS[2]]] forState:UIControlStateSelected];
    [self.getBtn setTitleColor:[UIColor colorWithHexString:themeBtnS[1]] forState:UIControlStateNormal];
    [self.getBtn setTitleColor:[UIColor colorWithHexString:themeBtnS[3]] forState:UIControlStateSelected];
    
    self.imgV.tintColor = [UIColor colorWithHexString:color9];
    
    self.flagLab.textColor = [UIColor colorWithHexString:color6];
    self.flagView.backgroundColor = [UIColor colorWithHexString:color5];
    
}

- (void)setItemModel:(id)itemModel{
    Coupon_item   *coupon = (Coupon_item *)itemModel;
    _itemModel = itemModel;
    self.titLab.text = coupon.title;
    switch (coupon.content.count) {
        case 1:{
            [self.titFirstLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            [self.titSecondLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.titThirdLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            self.titFirstLab.text = coupon.content[0];
        }
            break;
        case 2:{
            [self.titFirstLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            [self.titSecondLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            [self.titThirdLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            self.titFirstLab.text = coupon.content[0];
            self.titSecondLab.text = coupon.content[1];
        }
            break;
        case 3:{
            [self.titFirstLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            [self.titSecondLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            [self.titThirdLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
            }];
            self.titFirstLab.text = coupon.content[0];
            self.titSecondLab.text = coupon.content[1];
            self.titThirdLab.text = coupon.content[2];
        }
            break;
            
        default:
            [self.titFirstLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.titSecondLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.titThirdLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            break;
    }
    
    self.descLab.text = coupon.expiry_date_str;
    if (coupon.is_received) {
        self.getBtn.selected = YES;
        self.imgV.hidden = NO;
    }else{
        self.getBtn.selected = NO;
        self.imgV.hidden = YES;
    }
    if (self.getBtn.isSelected) {
        OSSVHomeCThemeModel   *couponsModel = (OSSVHomeCThemeModel *)_model;
        NSString *btn = [couponsModel.btn objectForKey:@"theme"];
        NSArray *themeBtnS = [btn componentsSeparatedByString:@","];
        self.getBtn.layer.borderWidth = 1;
        self.getBtn.layer.borderColor = [UIColor colorWithHexString:themeBtnS[0]].CGColor;
        
    }else{
        self.getBtn.layer.borderWidth = 0;
    }
    
    if (![OSSVNSStringTool isEmptyString:coupon.type_name]) {
        NSString *str = STLToString(coupon.type_name);
        CGFloat width = [self getLabStringWidthWithText:str];
        [self.flagView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width + 5);
        }];
        self.flagLab.text = str;
        self.flagView.hidden = NO;
    }else{
        [self.flagView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        self.flagView.hidden = YES;
    }
}

// 计算文字宽度
- (CGFloat)getLabStringWidthWithText:(NSString *)text{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:8]};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    return width;
}

- (void)onlyItemGetAction:(UIButton *)sender{
    Coupon_item   *coupon = (Coupon_item *)_itemModel;
    NSString *cupon_code = coupon.coupon_code;
    if (self.couponsBlock) {
        self.couponsBlock(cupon_code);
    }
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

- (UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        UIImage *img = [UIImage imageNamed:@"postMark"];
        [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imgV.image = img;
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        
        self.imgV.hidden = YES;
    }
    return _imgV;
}

-(UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font = [UIFont boldSystemFontOfSize:18];
        _titLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _titLab;
}
-(UILabel *)titFirstLab{
    if (!_titFirstLab) {
        _titFirstLab = [UILabel new];
        _titFirstLab.font = FontWithSize(12);
        _titFirstLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _titFirstLab;
}
-(UILabel *)titSecondLab{
    if (!_titSecondLab) {
        _titSecondLab = [UILabel new];
        _titSecondLab.font = FontWithSize(12);
        _titSecondLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _titSecondLab;
}
-(UILabel *)titThirdLab{
    if (!_titThirdLab) {
        _titThirdLab = [UILabel new];
        _titThirdLab.font = FontWithSize(12);
        _titThirdLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _titThirdLab;
}


-(UILabel *)descLab{
    if (!_descLab) {
        _descLab = [UILabel new];
        _descLab.font = [UIFont systemFontOfSize:10];
        _descLab.textColor = OSSVThemesColors.col_B62B21;
    }
    return _descLab;
}

- (UIButton *)getBtn{
    if (!_getBtn) {
        _getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getBtn setTitle:STLLocalizedString_(@"receive", nil) forState:UIControlStateNormal];
        [_getBtn setTitle:STLLocalizedString_(@"received", nil) forState:UIControlStateSelected];
        [_getBtn addTarget:self action:@selector(onlyItemGetAction:) forControlEvents:UIControlEventTouchUpInside];
        _getBtn.titleLabel.font = FontWithSize(12);
    }
    return _getBtn;
}

- (UIView *)flagView{
    if (!_flagView) {
        _flagView = [UIView new];
    }
    return _flagView;
}

- (UILabel *)flagLab{
    if (!_flagLab) {
        _flagLab = [UILabel new];
        _flagLab.font = [UIFont boldSystemFontOfSize:8];
    }
    return _flagLab;
}

/// 绘制控件
/// @param view 对哪个控件进行绘制
/// @param stokeColor 边框的颜色
/// @param fromColor 渐变初始颜色
/// @param toColor 渐变最终颜色
/// @param lineColor 虚线的颜色
 - (void)addlayerWithView:(UIView *)view withStokeColor:(UIColor *)stokeColor fromColor:(NSString *)fromColor toColor:(NSString *)toColor lineColor:(NSString *)lineColor{
     //缺角固定半径6
     
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapSquare;
    path.lineJoinStyle = kCGLineCapSquare;
    [path moveToPoint:CGPointMake(0, 0)];

    [path addLineToPoint:CGPointMake(view.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(view.bounds.size.width, self.startY)];
    [path addArcWithCenter:CGPointMake(view.bounds.size.width, self.startY+6) radius:6 startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];
    [path addLineToPoint:CGPointMake(view.bounds.size.width, view.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, view.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, self.startY + 2*6)];
    [path addArcWithCenter:CGPointMake(0, self.startY+6) radius:6 startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path stroke];


    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = stokeColor.CGColor;
//    layer.fillColor = [UIColor orangeColor].CGColor;


    CAGradientLayer *jianBianLayer = [self setGradualChangingColor:self.bgView fromColor:fromColor toColor:toColor];
    jianBianLayer.mask = layer;

    [self.bgView.layer addSublayer: jianBianLayer];

    CAShapeLayer *borderlayer = [[CAShapeLayer alloc] init];
    borderlayer.frame = view.bounds;
    borderlayer.path = path.CGPath;
    borderlayer.lineWidth = 1;
    borderlayer.strokeColor = stokeColor.CGColor;
    borderlayer.fillColor = [UIColor clearColor].CGColor;
    [self.bgView.layer addSublayer: borderlayer];

//    [self.bgView.layer addSublayer:self.imgV.layer];

    [self drawLineOfDashByCAShapeLayer:self.bgView lineLength:5 lineSpacing:2 lineColor:[UIColor colorWithHexString:lineColor]];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr{

//    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;

    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:fromHexColorStr].CGColor,(__bridge id)[UIColor colorWithHexString:toHexColorStr].CGColor];

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);

    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];

    return gradientLayer;
}


/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 **/
- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(lineView.bounds.size.width / 2.0,       lineView.bounds.size.height/2.0)];
//    //设置虚线颜色
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //设置虚线宽度
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //设置虚线的线宽及间距
     [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
     //创建虚线绘制路径
     CGMutablePathRef path = CGPathCreateMutable();
     //设置虚线绘制路径起点
     CGPathMoveToPoint(path, NULL, 6, self.startY + 6);
     //设置虚线绘制路径终点
      CGPathAddLineToPoint(path, NULL, lineView.bounds.size.width - 6, self.startY + 6);
       //设置虚线绘制路径
     [shapeLayer setPath:path];
     CGPathRelease(path);
     //添加虚线
     [lineView.layer addSublayer:shapeLayer];
}

@end
