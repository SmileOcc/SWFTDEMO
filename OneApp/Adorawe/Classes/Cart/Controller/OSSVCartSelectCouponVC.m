//
//  OSSVCartSelectCouponVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartSelectCouponVC.h"


/*模型数据*/
#import "OSSVCartGoodsModel.h"
#import "OSSVMyCouponsListsModel.h"

/*优惠券*/
#import "STLAlertView.h"
#import "OSSVCouponApplyView.h"
#import "OSSVCouponCellModel.h"
#import "OSSVCouponModel.h"
#import "OSSVCartOrderInfoViewModel.h"
#import "OSSVShowErrorManager.h"

//#import "OSSVCartCouponItemCell.h"
#import "OSSVMysCouponItemsCell.h"
#import "Adorawe-Swift.h"

/*========================================分割线======================================*/


@implementation CartCouponSelectTempModel 

- (instancetype)initWithCartGoodsModel:(OSSVCartGoodsModel *)cartGoodsModel {
    if (self = [super init]) {
        _goods_id = cartGoodsModel.goodsId;
        _wid = cartGoodsModel.wid;
        _goods_number = cartGoodsModel.goodsNumber;
        _goods_discount_price = STLToString(cartGoodsModel.goods_discount_price);
        _shop_price = cartGoodsModel.shop_price;
        _goods_sn = cartGoodsModel.goodsSn;
        _cat_id = cartGoodsModel.cat_id;
        _is_clearance = cartGoodsModel.is_clearance;
        _is_promote_price = cartGoodsModel.is_promote_price;
        
        //新增两个为了闪购商品不能使用优惠券
        _is_flash_sale  = cartGoodsModel.isFlashSale;
        _flash_sale_active_id  = cartGoodsModel.flashSaleId;
    }
    return self;
}

@end

/*========================================分割线======================================*/

@interface OSSVCartSelectCouponVC ()<UIAlertViewDelegate,UIScrollViewDelegate, STLCouponViewDelegate>

/*顶部切换view*/
@property (nonatomic,weak) UIView *topView;

/*available按钮*/
@property (nonatomic,weak) UIButton *availableBtn;

/*unavailable按钮*/
@property (nonatomic,weak) UIButton *unavailableBtn;

/*可滑动view*/
@property (nonatomic,weak) UIScrollView *sliderView;

/*滑动条*/
@property (nonatomic,weak) UIView *sliderPage;

/*Available列表*/
@property (nonatomic,weak) UITableView *AvailableTableView;

/*Unavailable列表*/
@property (nonatomic,weak) UITableView *UnavailableTableView;




/*头部文案背景*/
@property (nonatomic,strong) UIView *titleView;

/*删除头部文案的button*/
@property (nonatomic, strong) UIButton *deleteButton;
//是否展示头部文案
@property (nonatomic, copy)   NSString *isShowHeadTitle;

@property (nonatomic, strong) OSSVCartOrderInfoViewModel *infoViewModel;

@property (nonatomic, copy)  NSString  *codeString; //输入优惠券码
@end

@implementation OSSVCartSelectCouponVC

/*顶部导航栏高度*/
#define SLIDERVIEW_HIGHT 44.0

/*中间分割线*/
#define LINE_HIGHT SLIDERVIEW_HIGHT/2

/*========================================分割线======================================*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*谷歌统计*/
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIApplication.sharedApplication.keyWindow.backgroundColor = UIColor.whiteColor;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _codeString = @"";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowHeadTitle =  STLUserDefaultsGet(kAppShowCouponHeadTitle);

    self.title = STLLocalizedString_(@"selectCoupon",nil);
    
    /*优惠券说明*/
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"coupon_use_desc"] forState:UIControlStateNormal];
    UIBarButtonItem *couponUse = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(touchCoupon:) forControlEvents:UIControlEventTouchUpInside];
    
    /*X 关闭*/
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn1 setImage:[UIImage imageNamed:@"coupon_close"] forState:UIControlStateNormal];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    [btn1 addTarget:self action:@selector(touchClose:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15;
    self.navigationItem.rightBarButtonItems = @[closeItem,spaceItem,couponUse];
    
    /*界面初始化*/
    [self initView];
    
    /*加载数据*/
    [self loadData];
}

/*========================================分割线======================================*/

- (OSSVCartCouponItemViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [OSSVCartCouponItemViewModel new];
        _viewModel.controller = self;
        
        //选中优惠券的回调
        @weakify(self)
        _viewModel.selectedBlock = ^(OSSVMyCouponsListsModel *model){
            @strongify(self)
            self.selectedModel = model;
            self.couponApplyView.selectedModel = model;
            
            ///1.4.4 apply
            self.infoViewModel.couponModel.code = self.codeString;
            [self reloadCheckModel:nil completion:nil];
        };
        
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.AvailableTableView.mj_header beginRefreshing];
            [self.UnavailableTableView.mj_header beginRefreshing];
        };
        
    }
    return _viewModel;
}

//*******************************请求检查优惠券是否可用*********************************//

-(void)reloadCheckModel:(void(^)(void))failBlock completion:(void(^)(void))completionBlock
{
    @weakify(self)
    [self.infoViewModel requestCartCheckNetwork:self.infoViewModel completion:^(OSSVCartCheckModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVCartCheckModel class]]) {
            if (obj.statusCode == kStatusCode_200 && obj.flag == CartCheckOutResultEnumTypeSuccess) {
                if (completionBlock) {
                    completionBlock();
                }
                if (self.golBackBlock) {
                    self.golBackBlock(self.selectedModel);
//                    [self.navigationController popViewControllerAnimated:YES];
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }
            }else{
               [obj modalErrorMessage:self errorManager:[OSSVShowErrorManager new]];
            }
        }
    } failure:^(id obj) {
        ///失败的时候给个回调，为了方便刷新用户操作数据
        if (failBlock) {
            failBlock();
        }
    }];
}

/*========================================分割线======================================*/

#pragma mark - 界面初始化
- (void)initView {
    /*顶部导航栏*/
    UIView *topView = [UIView new];
    topView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(SLIDERVIEW_HIGHT);
        make.top.mas_equalTo(self.view.mas_top);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
    }];
    self.topView = topView;
    
    UIView *greayLine1 = [[UIView alloc] init];
    UIView *greayLine2 = [[UIView alloc] init];
    greayLine1.backgroundColor = greayLine2.backgroundColor = OSSVThemesColors.col_EEEEEE;
    
    [topView addSubview:greayLine1];
    [topView addSubview:greayLine2];
    [greayLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(0);
        make.height.equalTo(0.5);
    }];
    [greayLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(0.5);
    }];
    
    
    /*available按钮*/
    UIButton *availableBtn = [UIButton new];
    availableBtn.tag = AvaliableViewTagBtnSpecial;
    availableBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    availableBtn.selected = YES;
    [availableBtn setTitleColor:OSSVThemesColors.col_6C6C6C forState:UIControlStateNormal];
    [availableBtn setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateSelected];
    [availableBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    [availableBtn setTitle:STLLocalizedString_(@"available",nil) forState:UIControlStateNormal];
    [topView addSubview:availableBtn];
    
    CGFloat btnCenterxOffset = OSSVSystemsConfigsUtils.isRightToLeftShow ? SCREEN_WIDTH / 4 : -SCREEN_WIDTH / 4;
    
    [availableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top);
        make.centerX.equalTo(topView.mas_centerX).offset(btnCenterxOffset);
        make.height.mas_equalTo(SLIDERVIEW_HIGHT-3);
    }];
    self.availableBtn = availableBtn;
    
    /*unavailable按钮*/
    UIButton *unavailableBtn = [UIButton new];
    unavailableBtn.tag = AvaliableViewTagBtnDefault;
    unavailableBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [unavailableBtn setTitleColor:OSSVThemesColors.col_6C6C6C forState:UIControlStateNormal];
    [unavailableBtn setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateSelected];
    [unavailableBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    [unavailableBtn setTitle:STLLocalizedString_(@"unavailable",nil) forState:UIControlStateNormal];
    [topView addSubview:unavailableBtn];
    
    [unavailableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top);
        make.centerX.equalTo(topView.mas_centerX).offset(-btnCenterxOffset);
        make.height.mas_equalTo(SLIDERVIEW_HIGHT-3);
    }];
    self.unavailableBtn = unavailableBtn;

    /*可左右滑动View*/
    UIScrollView *sliderView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    sliderView.showsVerticalScrollIndicator = NO;
    sliderView.showsHorizontalScrollIndicator = NO;
    sliderView.pagingEnabled = YES;
    sliderView.delegate = self;
    sliderView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        sliderView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    }
    sliderView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    [self.view addSubview:sliderView];
    
    [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
//        make.bottom.mas_equalTo(self.confirmButton.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    self.sliderView = sliderView;
    
    /*滑动条*/
    UIView *sliderPage = [UIView new];
    
    sliderPage.backgroundColor = [OSSVThemesColors col_262626];
    [topView addSubview:sliderPage];
    self.sliderPage = sliderPage;
    
    [sliderPage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(31);
        make.leading.trailing.equalTo(availableBtn);
        make.height.equalTo(2);
    }];
    
    /*AvailableT列表*/
    UITableView *AvailableTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    AvailableTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    AvailableTableView.backgroundColor = OSSVThemesColors.col_F6F6F6;
    AvailableTableView.tag = AvaliableViewTagSpecial ;
    AvailableTableView.showsVerticalScrollIndicator = NO;
    AvailableTableView.emptyDataSetDelegate = self.viewModel;
    AvailableTableView.emptyDataSetSource = self.viewModel;
    AvailableTableView.dataSource = self.viewModel;
    AvailableTableView.delegate = self.viewModel;
    AvailableTableView.mj_footer.hidden = YES;
    [sliderView  addSubview:AvailableTableView];
    self.AvailableTableView = AvailableTableView;
    AvailableTableView.contentInset = UIEdgeInsetsMake(0, 0, 12+34, 0);
    
    
   
    
    
    /*Unavailable列表*/
    UITableView *UnavailableTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    UnavailableTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UnavailableTableView.backgroundColor = OSSVThemesColors.col_F6F6F6;
    UnavailableTableView.tag = AvaliableViewTagDefault ;
    UnavailableTableView.showsVerticalScrollIndicator = NO;
    UnavailableTableView.emptyDataSetDelegate = self.viewModel;
    UnavailableTableView.emptyDataSetSource = self.viewModel;
    UnavailableTableView.dataSource = self.viewModel;
    UnavailableTableView.delegate = self.viewModel;
    UnavailableTableView.mj_footer.hidden = YES;
    UnavailableTableView.contentInset = UIEdgeInsetsMake(0, 0, 12+34, 0);
    [sliderView  addSubview:UnavailableTableView];
    self.UnavailableTableView = UnavailableTableView;
    
    NSArray *tableArray = OSSVSystemsConfigsUtils.isRightToLeftShow ? @[UnavailableTableView,AvailableTableView] : @[AvailableTableView,UnavailableTableView];
    [tableArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [tableArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sliderView.mas_height);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.mas_equalTo(sliderView.mas_top);
        make.bottom.mas_equalTo(sliderView.mas_bottom);
    }];
    
    //************************这个头部是固定的，文案也是固定的
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 42)];
    [header addSubview:self.titleView];
    if (APP_TYPE == 3) {
        
    } else {
        AvailableTableView.tableHeaderView = self.isShowHeadTitle.intValue ?  header : nil;
    }
    if (self.isShowHeadTitle.intValue) {
        UILabel *label = [[UILabel alloc] init];
        label.text = STLLocalizedString_(@"fullCutAndFlashsaleTip", nil);
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 2;
        label.textColor = OSSVThemesColors.col_6C6C6C;
        [self.titleView addSubview:label];
      
      [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.leading.trailing.top.bottom.equalTo(0);
          make.height.equalTo(42);
      }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.titleView.mas_trailing).offset(-32);
            make.top.mas_equalTo(self.titleView.mas_top).offset(2);
            make.bottom.mas_equalTo(self.titleView.mas_bottom).offset(-2);
        }];
        
      [self.titleView addSubview:self.deleteButton];
      [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.mas_equalTo(self.titleView.mas_centerY);
          make.trailing.mas_equalTo(self.titleView.mas_trailing).offset(-16);
          make.size.equalTo(CGSizeMake(24, 24));
      }];
    }
}

/*========================================分割线======================================*/

#pragma mark - 加载数据
- (void)loadData {
    [self requestNetwork:nil tableView:self.AvailableTableView];
    [self requestNetwork:nil tableView:self.UnavailableTableView];
}

/*========================================分割线======================================*/

- (void)requestNetwork:(id)reques tableView:(UITableView*)tableView {
    
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshTableView:tableView];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    tableView.mj_header = header;
    
//    tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        @strongify(self)
//        [self.viewModel requestNetwork:[tempArray yy_modelToJSONObject] completion:^(id obj) {
//            [tableView reloadData];
//            [tableView.mj_footer endRefreshing];
//        } failure:^(id obj) {
//            [tableView reloadData];
//            [tableView.mj_footer endRefreshing];
//        }];
//    }];
    
//    [tableView.mj_header beginRefreshing];
    
    [self refreshTableView:tableView];
}

-(void)refreshTableView:(UITableView*)tableView{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    [self.cartGoodsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CartCouponSelectTempModel *tempModel = [[CartCouponSelectTempModel alloc] initWithCartGoodsModel:obj];
        [tempArray addObject:tempModel];
    }];
    if (!tableView.mj_header.isRefreshing) {
        [HUDManager showLoading];
    }
    @weakify(tableView)
    @weakify(self)
    [self.viewModel requestNetwork:[tempArray yy_modelToJSONObject] completion:^(id obj) {
        [HUDManager hiddenHUD];
        @strongify(tableView)
        @strongify(self)
//        if (tableView == self.AvailableTableView) {
//            self.selectedModel = nil;
//        }
        
        if ([obj integerValue] == EmptyViewShowTypeNoData) {
            self.view.backgroundColor = OSSVThemesColors.col_F6F6F6;
            if (tableView == self.AvailableTableView) {
                self.viewModel.noCouponTitle = STLLocalizedString_(@"Coupon_NoData_Available_titleLabel", nil);
            }else{
                self.viewModel.noCouponTitle= STLLocalizedString_(@"Coupon_NoData_Unavailable_titleLabel", nil);
            }
        } else {
            self.view.backgroundColor = OSSVThemesColors.col_F6F6F6;
        }
        [tableView reloadData];
        [tableView.mj_header endRefreshing];
    } failure:^(id obj) {
        [tableView reloadData];
        [tableView.mj_header endRefreshing];
    }];
}

/*========================================分割线======================================*/

#pragma mark - 优惠券说明提示框
- (void)touchCoupon:(UIButton*)sender {
    [GATools logCouponPageEventWithAction:@"Application"];
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:[NSString couponUseDesc] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
    }];
  
}

-(void)touchClose:(UIButton *)sender{
    if (self.selectedModel.couponCode.length == 0 && self.infoViewModel.couponModel.code.length == 0) {
        [self reloadCheckModel:nil completion:nil];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark  使用优惠券
-(void)STL_CouponCellDidClickApply:(OSSVCouponCellModel *)model
{
    self.selectedModel = [[OSSVMyCouponsListsModel alloc] init];
    //点击remove的时候
    if (model.status == ApplyButtonStatusClear /*|| [self.viewModel.couponCode isEqualToString:STLToString(self.couponApplyView.couponInputTF.text)]*/) {
        model.couponModel.code = @"";
        self.selectedModel.couponCode = @"";
        self.couponApplyView.couponInputTF.text = @"";
        self.couponApplyView.couponModel = nil;
        [self.couponApplyView.applyButton setTitle:STLLocalizedString_(@"category_filter_apply", nil).uppercaseString forState:UIControlStateNormal];
        self.couponApplyView.applyButton.backgroundColor = OSSVThemesColors.col_CCCCCC;
        self.couponApplyView.couponInputTF.userInteractionEnabled = YES;
        model.status = ApplyButtonStatusApply;
    
        self.selectedModel.couponCode = @"";
        self.infoViewModel.couponModel.code = @"";
        
        
        for (OSSVMyCouponsListsModel* item in self.viewModel.available) {
            item.isSelected = false;
        }
        [self.AvailableTableView reloadData];
        
    }else if(model.status == ApplyButtonStatusApply){
        self.selectedModel.couponCode = model.couponModel.code;
        self.infoViewModel.couponModel.code = model.couponModel.code;
        [self reloadCheckModel:nil completion:nil];
        
    }
    
 /*****************------V1.2.8之前选择cell 回调返回下单页**/
//    if (self.golBackBlock) {
//        self.golBackBlock(self.selectedModel);
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)useCouponAction:(NSString *)codeString {
//    self.selectedModel = [[OSSVMyCouponsListsModel alloc] init];
//    self.selectedModel.couponCode = model.couponModel.code;
//    self.infoViewModel.couponModel.code = model.couponModel.code;
//    [self reloadCheckModel:nil completion:nil];
    self.selectedModel = [[OSSVMyCouponsListsModel alloc] init];
    self.selectedModel.couponCode = self.codeString;
    self.infoViewModel.couponModel.code = self.codeString;
    [self reloadCheckModel:nil completion:nil];
    
}
/*========================================分割线======================================*/

#pragma mark - 滚动时滚动条代理
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.availableBtn.selected = NO;
    self.unavailableBtn.selected = NO;
    if (targetContentOffset->x > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(31);
                make.leading.trailing.equalTo(OSSVSystemsConfigsUtils.isRightToLeftShow ? self.availableBtn : self.unavailableBtn);
                make.height.equalTo(2);
            }];
            [self.sliderPage.superview layoutIfNeeded];
            self.unavailableBtn.selected = YES;
            [GATools logCouponPageEventWithAction:@"Unavailable"];
        }];
        

    }else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(31);
                make.leading.trailing.equalTo(OSSVSystemsConfigsUtils.isRightToLeftShow ? self.unavailableBtn : self.availableBtn);
                make.height.equalTo(2);
            }];
            [self.sliderPage.superview layoutIfNeeded];
            self.availableBtn.selected = YES;
            [GATools logCouponPageEventWithAction:@"Available"];
        }];
        

    }
}

/*========================================分割线======================================*/
#pragma mark ---切换有效或者无效的slider
- (void)changeList:(UIButton*)sender {
    self.availableBtn.selected = NO;
    self.unavailableBtn.selected = NO;
    sender.selected = YES;
    switch (sender.tag) {
        case AvaliableViewTagBtnSpecial:
        {
            [GATools logCouponPageEventWithAction:@"Available"];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.sliderView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
                    [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(31);
                        make.leading.trailing.equalTo(sender);
                        make.height.equalTo(2);
                    }];
                    [self.sliderPage.superview layoutIfNeeded];
                }];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.sliderView.contentOffset = CGPointMake(0, 0);
                    [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(31);
                        make.leading.trailing.equalTo(sender);
                        make.height.equalTo(2);
                    }];
                    [self.sliderPage.superview layoutIfNeeded];
                }];
            }
            
            if (self.viewModel.available.count > 0 /*&& self.UnavailableArray.count > 0*/) {
                self.viewModel.emptyViewShowType = EmptyViewShowTypeHide;
            }else {
                self.viewModel.emptyViewShowType = EmptyViewShowTypeNoData;
            }
            self.viewModel.noCouponTitle = STLLocalizedString_(@"Coupon_NoData_Available_titleLabel", nil);
            [self.AvailableTableView reloadData];
        }
            break;
        case AvaliableViewTagBtnDefault:
        {
            [GATools logCouponPageEventWithAction:@"Unavailable"];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.sliderView.contentOffset = CGPointMake(0, 0);
                    [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(31);
                        make.leading.trailing.equalTo(sender);
                        make.height.equalTo(2);
                    }];
                    [self.sliderPage.superview layoutIfNeeded];
                }];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.sliderView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
                    [self.sliderPage mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(31);
                        make.leading.trailing.equalTo(sender);
                        make.height.equalTo(2);
                    }];
                    [self.sliderPage.superview layoutIfNeeded];
                }];
            }
            
            if (self.viewModel.unavailable.count > 0 /*&& self.UnavailableArray.count > 0*/) {
                self.viewModel.emptyViewShowType = EmptyViewShowTypeHide;
            }else {
                self.viewModel.emptyViewShowType = EmptyViewShowTypeNoData;
            }
            self.viewModel.noCouponTitle= STLLocalizedString_(@"Coupon_NoData_Unavailable_titleLabel", nil);
            [self.UnavailableTableView reloadData];
        }
            break;
        default:
            break;
    }
}

/*========================================分割线======================================*/

#pragma mark - 懒加载创建视图
- (OSSVCouponApplyView *)couponApplyView {
    if (!_couponApplyView) {
        _couponApplyView = [[OSSVCouponApplyView alloc] init];
        _couponApplyView.delegate = self;
        //输入框 输入的回调
        @weakify(self)
        _couponApplyView.textFieldBlock = ^(NSString *text) {
            @strongify(self)
            if (text.length) {
                self.codeString = text;
            }
        };
    }
    return _couponApplyView;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [UIView new];
        _titleView.backgroundColor = OSSVThemesColors.col_FFF3E4;
    }
    return _titleView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"close_desc_coupon"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(removeTitleView) forControlEvents:UIControlEventTouchUpInside];

    }
    return _deleteButton;
}

- (void)removeTitleView {
    STLUserDefaultsSet(kAppShowCouponHeadTitle, @"0");
    self.AvailableTableView.tableHeaderView = nil;
    [self.AvailableTableView reloadData];
}

-(OSSVCartOrderInfoViewModel *)infoViewModel
{
    if (!_infoViewModel) {
        _infoViewModel = [[OSSVCartOrderInfoViewModel alloc] init];
        _infoViewModel.controller = self;
    }
    return _infoViewModel;
}

@end
