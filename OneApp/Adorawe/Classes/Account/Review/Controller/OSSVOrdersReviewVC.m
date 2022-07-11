//
//  OSSVOrdersReviewVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdersReviewVC.h"
#import "OSSVWritesReviewsVC.h"
#import "OSSVChecksReviewsVC.h"
#import "OSSVOrdereRevieweModel.h"
#import "OSSVOrdeerRevieweAip.h"
#import "OSSVOrdereRevieweWriteAip.h"

@interface OSSVOrdersReviewVC ()

@property (nonatomic, strong) NSIndexPath      *selectedIndexPath;

@property (nonatomic, strong) OSSVOrdereRevieweModel   *reviewModel;
@end

@implementation OSSVOrdersReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"reviews", nil);
    
    [self initView];
    [self requestDatasMore:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    
    [self.view addSubview:self.reviewsTableView];
    [self.reviewsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.reviewsTableView.contentInset = UIEdgeInsetsMake(0, 0, kIS_IPHONEX ? 37 : 5, 0);
}
#pragma mark - Request

- (void)refresh {
    [self requestDatasMore:NO];
}
- (void)requestDatasMore:(BOOL)loadMore {
    
    OSSVOrdeerRevieweAip *reviewApi = [[OSSVOrdeerRevieweAip alloc] initWithDict:@{@"order_id":STLToString(self.orderId)}];
    
    [reviewApi.accessoryArray addObject:[[STLRequestAccessory alloc] init]];

    @weakify(self)
    [reviewApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        self.reviewModel = [self dataAnalysisFromJson: requestJSON request:reviewApi];
        self.reviewsTableView.reviewModel = self.reviewModel;
        [self.reviewsTableView reloadData];
        self.reviewsTableView.hidden = NO;
        if (_emptyView) {
            _emptyView.hidden = YES;
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        @strongify(self)
        self.reviewsTableView.hidden = YES;
        self.emptyView.hidden = NO;
    }];
}

#pragma mark 评论订单

#pragma mark - private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVOrdeerRevieweAip class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVOrdereRevieweModel yy_modelWithJSON:json[kResult]];
        }
    }
    return nil;
}

#pragma mark - STLOrderReviewTableViewDelegate
- (void)STL_OrderReviewTableView:(OSSVOrdersReviewsTableView *)tableView transoprt:(CGFloat)transport goods:(CGFloat)goods pay:(CGFloat)pay service:(CGFloat)service {
    NSLog(@"---%f %f %f %f",transport,goods,pay,service);
    
    
    NSDictionary *paramsDic = @{@"order_id":STLToString(self.orderId),
                                @"transport_rate":[NSString stringWithFormat:@"%f",transport],
                                @"goods_rate":[NSString stringWithFormat:@"%f",goods],
                                @"pay_rate":[NSString stringWithFormat:@"%f",pay],
                                @"service_rate":[NSString stringWithFormat:@"%f",service],
                                };
    
    OSSVOrdereRevieweWriteAip *reviewApi = [[OSSVOrdereRevieweWriteAip alloc] initWithDict:paramsDic];
    
    @weakify(self)
    [reviewApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            
            [tableView reviewSuccess];
            // 评论成功回调
            if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_OrderReviewViewController:refresh:)]) {
                [self.myDelegate STL_OrderReviewViewController:self refresh:YES];
            }
        }else{
            NSString *message = STLToString(requestJSON[kMessagKey]);
            if (message.length > 0) {
                [HUDManager showHUDWithMessage:message];
            }

        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        //失败
    }];
   
}


- (void)STL_OrderReviewTableView:(OSSVOrdersReviewsTableView *)tableView indexPath:(NSIndexPath *)indexPath {

    self.selectedIndexPath = indexPath;
    if (tableView.goodsDatas.count > indexPath.row) {
        OSSVAccounteOrdersDetaileGoodsModel *goodsModel = tableView.goodsDatas[indexPath.row];
        
        if (goodsModel.isReview == 1) {
            OSSVChecksReviewsVC *checkReviewCtrl = [[OSSVChecksReviewsVC alloc] init];
            checkReviewCtrl.goodsModel = goodsModel;
            [self.navigationController pushViewController:checkReviewCtrl animated:YES];

        } else {
            OSSVWritesReviewsVC *writeReviewCtrl = [[OSSVWritesReviewsVC alloc] init];
            writeReviewCtrl.orderId = self.orderId;
            writeReviewCtrl.goodsModel = goodsModel;
            
            @weakify(self)
            writeReviewCtrl.block = ^{
                @strongify(self)
                goodsModel.isReview = 1;
                [self updateTable];
            };
            [self.navigationController pushViewController:writeReviewCtrl animated:YES];
        }
    }
    
}

- (void)updateTable{
    if (self.selectedIndexPath) {
        //数据更改 刷新
        [self.reviewsTableView reloadData];
    }
}


- (OSSVOrdersReviewsTableView *)reviewsTableView {
    if (!_reviewsTableView) {
        _reviewsTableView = [[OSSVOrdersReviewsTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _reviewsTableView.orderId = self.orderId;
        _reviewsTableView.myDelegate = self;
        _reviewsTableView.mj_header.hidden = YES;
        _reviewsTableView.mj_footer.hidden = YES;
        _reviewsTableView.hidden = YES;

    }
    return _reviewsTableView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [self makeCustomNoDataView];
    }
    return _emptyView;
}

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView *customView = [[UIView alloc] initWithFrame:self.view.bounds];
    customView.backgroundColor = [UIColor whiteColor];
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    imageView.userInteractionEnabled = YES;
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    /**
     emptyOperationTouch
     emptyJumpOperationTouch
     暂时两个动态选择
     */
    [button addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    
    [self.view addSubview:customView];
    return customView;
}

@end
