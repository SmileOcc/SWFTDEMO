//
//  YWLoginSelectCountryView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "YWLoginSelectCountryView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "ZFPopCustomerView.h"
#import "YWLoginNewCountryModel.h"
#import "LoginViewModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

@interface YWLoginSelectCountryView ()
<
    ZFPopCustomerViewDelegate
>
@property (nonatomic, strong) UIImageView *countryIconImage;
@property (nonatomic, strong) UILabel *countryNameLabel;
@property (nonatomic, strong) UIImageView *selectImage;
@property (nonatomic, strong) UILabel *countryPhoneCodeLabel;
@property (nonatomic, strong) ZFPopCustomerView *popCustomerView;
@property (nonatomic, strong) NSMutableArray <id<CustomerViewProtocol>> *customerDataSource;

@end

@implementation YWLoginSelectCountryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.countryIconImage];
        [self addSubview:self.countryNameLabel];
        [self addSubview:self.selectImage];
        [self addSubview:self.countryPhoneCodeLabel];
        
        [self.countryIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.size.mas_offset(CGSizeMake(40, 24));
        }];
        
        [self.countryNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.countryIconImage.mas_trailing).mas_offset(10);
            make.centerY.mas_equalTo(self.countryIconImage);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
        }];
        
        [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.countryNameLabel.mas_trailing);
            make.centerY.mas_equalTo(self.countryIconImage);
            make.size.mas_offset(CGSizeMake(20, 20));
        }];
        
        [self.countryPhoneCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.selectImage.mas_trailing);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.centerY.mas_equalTo(self.countryIconImage);
        }];
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = ZFC0xDDDDDD();
        [self addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(1);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCountry)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - target

- (void)tapCountry
{
    if (![self.customerDataSource count]) {
        [self gainNewCountryList];
    } else {
        [self.popCustomerView showCustomer:self.customerDataSource];
    }
}

#pragma mark - popCustomerView delegate

-(void)popCustomerViewDidSelect:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    if (self.selectCountryHandler) {
        YWLoginNewCountryModel *model = self.countryList[indexPath.row - 1];
        [self.countryIconImage yy_setImageWithURL:[NSURL URLWithString:model.icon] options:YYWebImageOptionProgressive];
        self.countryPhoneCodeLabel.text = [NSString stringWithFormat:@"+ %@", model.code];
        self.countryNameLabel.text = model.region_name;
        self.selectCountryHandler(model);
    }
    [self.popCustomerView hiddenCustomer];
    
    [self.customerDataSource enumerateObjectsUsingBlock:^(id<CustomerViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CustomerSelectMarkModel class]]) {
            CustomerSelectMarkModel *model = (CustomerSelectMarkModel *)obj;
            model.isSelect = NO;
            if (idx == indexPath.row) {
                model.isSelect = YES;
            }
        }
    }];
}

#pragma mark - private method

- (void)gainNewCountryList
{
    LoginViewModel *viewModel = [[LoginViewModel alloc] init];
    ShowLoadingToView(self.superview);
    @weakify(self)
    [viewModel requestNewCountryList:^(NSArray<YWLoginNewCountryModel *> *list, NSError *error) {
        HideLoadingFromView(self.superview);
        @strongify(self)
        if (!error) {
            self.countryList = list;
            [self.popCustomerView showCustomer:self.customerDataSource];
        } else {
            ShowToastToViewWithText(nil, ZFLocalizedString(@"BlankPage_NetworkError_tipTitle", nil));
        }
    }];
}

#pragma mark - Property Method

-(void)setCountryList:(NSArray<YWLoginNewCountryModel *> *)countryList
{
    _countryList = countryList;
    
    if ([self.customerDataSource count]) {
        return;
    }

    CustomerTitleModel *titleModel = [[CustomerTitleModel alloc] init];
    titleModel.content = ZFLocalizedString(@"Login_SelectCountry", nil);
    titleModel.contentFont = [UIFont systemFontOfSize:18];
    titleModel.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.customerDataSource addObject:titleModel];
    
    [_countryList enumerateObjectsUsingBlock:^(YWLoginNewCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CustomerSelectMarkModel *model = [[CustomerSelectMarkModel alloc] init];
        model.content = obj.region_name;
        model.imagePath = obj.icon;
        if ([self.defaultCountryModel.region_id isEqualToString:obj.region_id]) {
            model.isSelect = YES;
        }
        [self.customerDataSource addObject:model];
    }];
}

-(void)setDefaultCountryModel:(YWLoginNewCountryModel *)defaultCountryModel
{
    _defaultCountryModel = defaultCountryModel;
    
    [self.countryIconImage yy_setImageWithURL:[NSURL URLWithString:_defaultCountryModel.icon] options:YYWebImageOptionProgressive];
    self.countryPhoneCodeLabel.text = [NSString stringWithFormat:@"+ %@", ZFToString(_defaultCountryModel.code)];
    self.countryNameLabel.text = ZFToString(_defaultCountryModel.region_name);
}

- (UIImageView *)countryIconImage
{
    if (!_countryIconImage) {
        _countryIconImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _countryIconImage;
}

-(UILabel *)countryNameLabel
{
    if (!_countryNameLabel) {
        _countryNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _countryNameLabel;
}

- (UIImageView *)selectImage
{
    if (!_selectImage) {
        _selectImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"reviews_arrow"];
            img;
        });
    }
    return _selectImage;
}

-(UILabel *)countryPhoneCodeLabel
{
    if (!_countryPhoneCodeLabel) {
        _countryPhoneCodeLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16];
            label.textAlignment = NSTextAlignmentRight;
            
            label;
        });
    }
    return _countryPhoneCodeLabel;
}

-(ZFPopCustomerView *)popCustomerView
{
    if (!_popCustomerView) {
        _popCustomerView = [[ZFPopCustomerView alloc] init];
        _popCustomerView.edgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        _popCustomerView.delegate = self;
        _popCustomerView.contentViewBackgroundColor = ZFC0xF2F2F2();
    }
    return _popCustomerView;
}

- (NSMutableArray <id<CustomerViewProtocol>> *)customerDataSource
{
    if (!_customerDataSource) {
        _customerDataSource = [[NSMutableArray alloc] init];
    }
    return _customerDataSource;
}

@end
