//
//  OSSVMyHelpVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyHelpVC.h"
#import "OSSVFeedbackVC.h"
#import "OSSVFeedbackReplayVC.h"

#import "OSSVHelpsdViewModel.h"
#import "OSSVMyleHeopItemsModel.h"

#import "OSSVHelpsCategorysCCell.h"
#import "OSSVHelpsQuestiCCell.h"
#import "OSSVHelpsServicCCell.h"

#import "OSSVHelpsHeadView.h"
#import "JSBadgeView.h"

#import <MessageUI/MFMailComposeViewController.h>
#import "Adorawe-Swift.h"
@interface OSSVMyHelpVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong)  UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UILabel           *tipLabel;
@property (nonatomic, strong) UIButton          *replyButton;
@property (nonatomic, strong) JSBadgeView       *badgeView;
@property (nonatomic, strong) UIButton          *feedbackButton;
@property (nonatomic, strong) OSSVHelpsdViewModel     *viewModel;

@property (nonatomic, strong) NSArray           *datas;
@property (nonatomic, strong) NSMutableArray    *sectionBgViews;

@end

@implementation OSSVMyHelpVC

#pragma mark -Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [OSSVThemesColors stlWhiteColor];
    self.title = STLLocalizedString_(@"Help", nil);
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
    
    [self changeBadgeValue];
}

#pragma mark - MakeUI;
- (void)initView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.rowHeight = 40;
    self.tableView.separatorColor = OSSVThemesColors.col_F1F1F1;
    //隐藏滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self.viewModel;
    self.tableView.tableFooterView = [UIView new];
    self.viewModel.controller = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
    self.tableView.hidden = YES;
    
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.replyButton];
    [self.view addSubview:self.feedbackButton];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(kIS_IPHONEX ? (83+34) : 84);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.top.mas_equalTo(self.bottomView.mas_top).offset(8);
        make.bottom.mas_equalTo(self.feedbackButton.mas_top).offset(-8);
    }];
    
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading);
        make.centerY.mas_equalTo(self.feedbackButton.mas_centerY);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(44);
    }];
    
    [self.feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.replyButton.mas_trailing);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.bottomView.mas_top).offset(31);
        make.height.mas_equalTo(44);
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.datas.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.datas.count > section) {
        OSSVMyleHeopItemsModel *model = self.datas[section];
        return model.datas.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.datas.count > indexPath.section) {
        OSSVHelpsQuestiCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHelpsQuestiCCell.class) forIndexPath:indexPath];

        
        OSSVMyleHeopItemsModel *model = self.datas[indexPath.section];
        OSSVMyleHeopItemsModel *subModel = model.datas[indexPath.row];
        cell.titleLabel.text = subModel.title;
        
        cell.lineView.hidden = NO;
        if (model.datas.count == indexPath.row+1) {
            cell.lineView.hidden = YES;
        }
        
        if (self.sectionBgViews.count <= indexPath.section) {
            
            UICollectionViewLayoutAttributes *attributesHeader = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *attributesFotter = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];

            UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0, attributesHeader.frame.origin.y, SCREEN_WIDTH - 24, attributesFotter.frame.origin.y - attributesHeader.frame.origin.y)];
            temp.backgroundColor = [OSSVThemesColors stlWhiteColor];
            temp.layer.cornerRadius = 4;
            temp.layer.masksToBounds = YES;
            [self.sectionBgViews addObject:temp];
            [self.collectionView insertSubview:temp atIndex:0];
        }
        
        return cell;
    }
    
    if (indexPath.section == 1 && self.datas.count > indexPath.section) {
        
        OSSVHelpsCategorysCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHelpsCategorysCCell.class) forIndexPath:indexPath];
        
        OSSVMyleHeopItemsModel *model = self.datas[indexPath.section];
        OSSVMyleHeopItemsModel *subModel = model.datas[indexPath.row];
        cell.titleLabel.text = subModel.title;
        cell.imageView.image = [UIImage imageNamed:subModel.imageName];
        cell.tipLabel.text = STLToString(subModel.tip);
        
        cell.rightLineView.hidden = NO;
        if (indexPath.row % 3 == 2) {
            cell.rightLineView.hidden = YES;
        }
        
        NSInteger isLeftCount = model.datas.count % 3 > 0 ? 1 : 0;
        NSInteger allRow = model.datas.count / 3 + isLeftCount;
        cell.bottomLineView.hidden = NO;
        if (indexPath.row / 3 == allRow - 1) {
            cell.bottomLineView.hidden = YES;
        }
        
        if (self.sectionBgViews.count <= indexPath.section) {
            
            UICollectionViewLayoutAttributes *attributesHeader = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *attributesFotter = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
            
            UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0, attributesHeader.frame.origin.y, SCREEN_WIDTH - 24, attributesFotter.frame.origin.y - attributesHeader.frame.origin.y)];
            temp.backgroundColor = [OSSVThemesColors stlWhiteColor];
            temp.layer.cornerRadius = 4;
            temp.layer.masksToBounds = YES;
            [self.sectionBgViews addObject:temp];
            [self.collectionView insertSubview:temp atIndex:0];
            STLLog(@"平铺模式添加背景色====%@", self.sectionBgViews);
            
            for (UIView *bgColorView in self.sectionBgViews) {
                if ([bgColorView isKindOfClass:[UIView class]]) {
                    [self.collectionView insertSubview:bgColorView atIndex:0];
                }
            }
        }
        return cell;
    }
    
    OSSVHelpsServicCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHelpsServicCCell.class) forIndexPath:indexPath];
    
    if (self.datas.count > indexPath.section) {
        OSSVMyleHeopItemsModel *model = self.datas[indexPath.section];
        OSSVMyleHeopItemsModel *subModel = model.datas[indexPath.row];
        subModel.index = indexPath.row;
        cell.model = subModel;
        cell.titleLabel.text = subModel.title;
        cell.imageView.image = [UIImage imageNamed:subModel.imageName];
        cell.tipLabel.text = STLToString(subModel.tip);
        if (indexPath.row == 0) {
            cell.bgView.backgroundColor = [OSSVThemesColors col_3FE35C];
            cell.button.sensor_element_id = @"Help_WhatsApp_button";
            cell.sensor_element_id = @"Help_WhatsApp_button";
            cell.bgView.sensor_element_id = @"Help_WhatsApp_button";
            cell.titleLabel.sensor_element_id = @"Help_WhatsApp_button";
            cell.tipLabel.sensor_element_id = @"Help_WhatsApp_button";
            cell.imageView.sensor_element_id = @"Help_WhatsApp_button";
        } else {
            cell.bgView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.8];
            cell.button.sensor_element_id = @"Help_Email_button";
            cell.sensor_element_id = @"Help_Email_button";
            cell.bgView.sensor_element_id = @"Help_Email_button";
            cell.titleLabel.sensor_element_id = @"Help_Email_button";
            cell.tipLabel.sensor_element_id = @"Help_Email_button";
            cell.imageView.sensor_element_id = @"Help_Email_button";
        }
    }
    
    @weakify(self)
    cell.tapBlock = ^(OSSVMyleHeopItemsModel * _Nonnull model) {
        @strongify(self)
        if (model.index == 0) {
            [self shareWhatsApp];
            

        } else {
            [self sendEmail];
        }
    };
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    OSSVMyleHeopItemsModel *model;
    
    if (kind == UICollectionElementKindSectionHeader) {
        OSSVHelpsHeadView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVHelpsHeadView.class) forIndexPath:indexPath];
        
        if (self.datas.count > indexPath.section) {
            model = self.datas[indexPath.section];
            headerView.headViewTitleLabel.text = model.title;
        }
        return headerView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    headerView.hidden = YES;
    
    return headerView;
    
}
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(SCREEN_WIDTH - 24, 44);
    } else if(indexPath.section == 1) {
        return CGSizeMake((SCREEN_WIDTH - 24) / 3.0-0.01, (SCREEN_WIDTH - 24) / 3.0-0.01);
    }
    return CGSizeMake((SCREEN_WIDTH - 24 - 8) / 2.0, 48);

}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 44;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return CGSizeMake(SCREEN_WIDTH - 24, 44);
    }
    return CGSizeMake(SCREEN_WIDTH - 24, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH - 24, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.datas.count > indexPath.section) {
        OSSVMyleHeopItemsModel *model = self.datas[indexPath.section];
        
        if (model.datas.count > indexPath.row) {
            
            OSSVMyleHeopItemsModel *subModel = model.datas[indexPath.row];
            
            
            if (indexPath.section == 0) {
                [OSSVAnalyticsTool analyticsGAEventWithName:@"help" parameters:@{
                    @"screen_group":@"Help",
                    @"action":[NSString stringWithFormat:@"FrequentQ_%@",subModel.title]}];
            } else if(indexPath.section == 1) {
                [OSSVAnalyticsTool analyticsGAEventWithName:@"help" parameters:@{
                    @"screen_group":@"Help",
                    @"action":[NSString stringWithFormat:@"questionType_%@",subModel.title]}];
            } else if(indexPath.section == 2) {
                [OSSVAnalyticsTool analyticsGAEventWithName:@"help" parameters:@{
                    @"screen_group":@"Help",
                    @"action":[NSString stringWithFormat:@"Contact_by_%@",subModel.title]}];
            }
            if (indexPath.section == 2) {
//                if (indexPath.row == 1) {
//                    [self sendEmail];
//                } else if(indexPath.row == 0) {
//                    [self shareWhatsApp];
//                }
            } else {
                
                //根据item.tag判断h5界面跳转
                STLWKWebCtrl *webVc = [[STLWKWebCtrl alloc]init];
                webVc.title = subModel.title;
                webVc.isNoNeedsWebTitile = YES;
                webVc.url = subModel.url;
                [self.navigationController pushViewController:webVc animated:YES];
            }
        }
    }
}

- (void)actionReplay:(UIButton *)sender {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"help" parameters:@{
           @"screen_group":@"Help",
           @"action":@"Reply"}];
    
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            OSSVFeedbackReplayVC *feedbackVC = [[OSSVFeedbackReplayVC alloc] init];
            [self.navigationController pushViewController:feedbackVC animated:YES];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        OSSVFeedbackReplayVC *feedbackVC = [[OSSVFeedbackReplayVC alloc] init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
    
}

- (void)actionFeedback:(UIButton *)sender {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"help" parameters:@{
           @"screen_group":@"Help",
           @"action":@"Feedback"}];
    
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            OSSVFeedbackVC *feedbackVC = [[OSSVFeedbackVC alloc] init];
            [self.navigationController pushViewController:feedbackVC animated:YES];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        OSSVFeedbackVC *feedbackVC = [[OSSVFeedbackVC alloc] init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
}

- (void)changeBadgeValue {
    self.badgeView.badgeText = nil;
    if (USERID) {
        AccountModel *accountModel = [OSSVAccountsManager sharedManager].account;
        
        if (accountModel.feedbackMessageCount > 0) {
            
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)accountModel.feedbackMessageCount];
            if (accountModel.feedbackMessageCount > 99) {
                self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)99];
            }
        }
        
    }
}

#pragma mark - LazyLoad

- (NSMutableArray *)sectionBgViews {
    if (!_sectionBgViews) {
        _sectionBgViews = [[NSMutableArray alloc] init];
    }
    return _sectionBgViews;
}

- (NSArray *)datas {
    if (!_datas) {
        NSMutableArray *categs = [[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++) {
            OSSVMyleHeopItemsModel *cateItemModel = [[OSSVMyleHeopItemsModel alloc] init];

            NSMutableArray *subCates = [[NSMutableArray alloc] init];
            if (i == 0) {
                cateItemModel.title = STLLocalizedString_(@"help_FrequentlyQuestion", nil);
                for (int j=0; j<2; j++) {
                    OSSVMyleHeopItemsModel *model = [[OSSVMyleHeopItemsModel alloc] init];
                    model.title = STLLocalizedString_(@"help_ReturnPolicy", nil);
                    model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeReturnPolicy];
                    if (j == 1) {
                        model.title = STLLocalizedString_(@"help_HowLongReceiveOrder", nil);
                        model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeLongReceiveOrider];
                    }
                    [subCates addObject:model];
                }
            } else if(i == 1) {
                cateItemModel.title = STLLocalizedString_(@"help_QuestionCategories", nil);
                for (int j=0; j<6; j++) {
                    OSSVMyleHeopItemsModel *model = [self createModel:j];
                    [subCates addObject:model];
                }
            } else {
                
                for (int j=0; j<2; j++) {
                    OSSVMyleHeopItemsModel *model = [[OSSVMyleHeopItemsModel alloc] init];
                    model.title = STLLocalizedString_(@"Whats_App", nil);
                    model.url = STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_url);
                    model.imageName = @"help_whatApp";
                    model.tip = STLLocalizedString_(@"whatapp_Click_chat_us", nil);
                    if (j == 1) {
                        model.title = STLLocalizedString_(@"Email", nil);
                        model.url = @"";
                        model.imageName = @"help_email";
                        model.tip = STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_email);
                    }
                    [subCates addObject:model];
                }
            }
            cateItemModel.datas = [subCates copy];
            [categs addObject:cateItemModel];
        }
        _datas = [[NSArray alloc] initWithArray:categs];
    }
    return _datas;
}

- (OSSVMyleHeopItemsModel *)createModel:(NSInteger)index {
    OSSVMyleHeopItemsModel *model = [[OSSVMyleHeopItemsModel alloc] init];
    switch (index) {
        case 0:
            model.title = STLLocalizedString_(@"help_Shipping", nil);
            model.imageName = @"help_shipping";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeShipping];
            break;
        case 1:
            model.title = STLLocalizedString_(@"help_Orders", nil);
            model.imageName = @"help_order";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeOrders];
            break;
        case 2:
            model.title = STLLocalizedString_(@"help_AfterSale", nil);
            model.imageName = @"help_after_sale";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeAfterSale];;
            break;
        case 3:
            model.title = STLLocalizedString_(@"help_Promotion", nil);
            model.imageName = @"help_promotion";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypePromotion];;
            break;
        case 4:
            model.title = STLLocalizedString_(@"help_Products", nil);
            model.imageName = @"help_products";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeProducts];
            break;
        case 5:
            model.title = STLLocalizedString_(@"help_ContactUs", nil);
//            model.title = STLLocalizedString_(@"AboutUs", nil);
            model.imageName = @"help_contact_us";
            //model.tip = @"service@adorawe.net";
            model.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeContractUs];;
            break;
            
        default:
            break;
    }
    return model;
}
    
- (OSSVHelpsdViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVHelpsdViewModel alloc]init];
        _viewModel.controller = self;
    }
    return _viewModel;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout = layout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _collectionView.contentInset = UIEdgeInsetsMake(12, 12, 0, 12);
        
        [_collectionView registerClass:[OSSVHelpsQuestiCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVHelpsQuestiCCell.class)];
        [_collectionView registerClass:[OSSVHelpsCategorysCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVHelpsCategorysCCell.class)];
        [_collectionView registerClass:[OSSVHelpsServicCCell class] forCellWithReuseIdentifier:NSStringFromClass([OSSVHelpsServicCCell class])];
        [_collectionView registerClass:[OSSVHelpsHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVHelpsHeadView.class)];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass(UICollectionReusableView.class)];

    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [OSSVThemesColors col_999999];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.text = STLLocalizedString_(@"help_CanNotFindAnswer", nil);
    }
    return _tipLabel;
}

- (UIButton *)replyButton {
    if (!_replyButton) {
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replyButton setImage:[UIImage imageNamed:@"feedback_replay"] forState:UIControlStateNormal];
        [_replyButton setImage:[UIImage imageNamed:@"feedback_replay"] forState:UIControlStateHighlighted];
        [_replyButton addTarget:self action:@selector(actionReplay:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _replyButton;
}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.replyButton alignment:JSBadgeViewAlignmentTopRight];
        _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(-18), 0);
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;
        _badgeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionReplay:)];
        [_badgeView addGestureRecognizer:tapGesture];
    }
    return _badgeView;
}


- (UIButton *)feedbackButton {
    if (!_feedbackButton) {
        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _feedbackButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        [_feedbackButton setTitle:STLLocalizedString_(@"help_feedback", nil) forState:UIControlStateNormal];
        [_feedbackButton setImage:[UIImage imageNamed:@"help_feedback"] forState:UIControlStateNormal];
        [_feedbackButton addTarget:self action:@selector(actionFeedback:) forControlEvents:UIControlEventTouchUpInside];
        _feedbackButton.layer.cornerRadius = 2;
        _feedbackButton.layer.masksToBounds = YES;
    }
    return _feedbackButton;
}


#pragma mark - 发送邮件
- (void)sendEmail {
    
    NSString *email = STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_email);
    MFMailComposeViewController *mailVC = [MFMailComposeViewController new];
    if (!mailVC) {
        NSLog(@"暂未设置系统邮件，请到系统-> \"设置\"->\"邮件\" 添加邮箱");
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:STLLocalizedString_(@"help_emial_setting_tip", nil) buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            
        }];
        return;
    }
    
    //代理 MFMailComposeViewControllerDelegate
    mailVC.mailComposeDelegate = self;
    //邮件主题
    [mailVC setSubject:STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_email_title)];
    //收件人
    [mailVC setToRecipients:@[STLToString(email)]];
    
    [self presentViewController:mailVC animated:YES completion:nil];
}

// 实现代理方法
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // MFMailComposeResultCancelled
    // MFMailComposeResultSaved
    // MFMailComposeResultSent
    // MFMailComposeResultFailed
  
    if (result == MFMailComposeResultSent) {
        NSLog(@"发送成功");
    } else if (result == MFMailComposeResultFailed) {
        NSLog(@"发送失败");
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareWhatsApp {
    //v1.4.6
    NSString *phone = STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_phone);
    NSString *appUrl = [NSString stringWithFormat:@"whatsapp://send?phone=%@",phone];
    NSURL *whatsappURL = [NSURL URLWithString:URLENCODING(appUrl)];

    NSString *url = STLToString([OSSVAccountsManager sharedManager].sysIniModel.customer_service_url);
    url =  URLENCODING(url);
    NSURL *replayWhatsappURL = [NSURL URLWithString:url];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {//判断是否安装APP
        if ([[UIApplication sharedApplication] canOpenURL: replayWhatsappURL]) {
            [[UIApplication sharedApplication] openURL:whatsappURL options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
        }
        
    } else {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = phone;
        
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id310633997"];
        [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
            if (success) {
                STLLog(@"10以后可以跳转url");
            }else{
                STLLog(@"10以后不可以跳转url");
            }
        }];
    }
    
    
}
@end
