//
//  OSSVAddresseRelatedeSearchView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//  -------地址关联搜索，用于填写详细地址的关联
 
#import "OSSVAddresseRelatedeSearchView.h"
#import "OSSVRelatedeSearcheCell.h"
#import <GooglePlaces/GooglePlaces.h>

@interface OSSVAddresseRelatedeSearchView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)  UITableView        *tableView;
@property (nonatomic, strong)  NSMutableArray     *addressArray;
@property (nonatomic, strong)  GMSPlacesClient    *placesClient;//可以获取某个地方的信息

@property (nonatomic, copy)  NSString *selectCountryCode; //当前位置所属的国家简码
@property (nonatomic, copy)  NSString *selectProvince;    //选择的省份
@property (nonatomic, copy)  NSString *selectCity; //选择的城市
@property (nonatomic, copy)  NSString *selectCountry; //选择的国家
@property (nonatomic, copy)  NSString *selectArea; //选择的区域
@property (nonatomic, copy)  NSString *selectAddress; //选中的详细地址
@property (nonatomic, copy)  NSString *latitudeString; //选中地址的纬度
@property (nonatomic, copy)  NSString *longitudeString; //选中地址的经度

@end

@implementation OSSVAddresseRelatedeSearchView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
        _placesClient = [GMSPlacesClient sharedClient];
        
        _selectCountryCode      = @"";
        _selectProvince         = @"";
        _selectCity             = @"";
        _selectCountry          = @"";
        _selectArea             = @"";
        _selectAddress          = @"";
        _latitudeString         = @"";
        _longitudeString        = @"";

    }
    return self;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[OSSVRelatedeSearcheCell class] forCellReuseIdentifier:@"OSSVRelatedeSearcheCell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
    }
    return _tableView;
}

- (NSMutableArray *)addressArray {
    if (!_addressArray) {
        _addressArray = [NSMutableArray array];
    }
    return _addressArray;
}
#pragma mark --UITableViewDataSource And UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVRelatedeSearcheCell *cell = (OSSVRelatedeSearcheCell *)[tableView dequeueReusableCellWithIdentifier:@"OSSVRelatedeSearcheCell" forIndexPath:indexPath];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [OSSVThemesColors col_FAFAFA];
    cell.selectedBackgroundView = view;
    NSDictionary *dataDic = self.addressArray[indexPath.row];
    cell.addressLabel.attributedText = [self stringWithHighLightSubstring:STLToString(dataDic[@"description"]) substring:self.keyWord];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDic = self.addressArray[indexPath.row];
    //获取到点击每一条地址的 placeID 以及地址
    NSString *placeId = STLToString(dataDic[@"place_id"]);
    NSString *address = STLToString(dataDic[@"description"]);
    [self getLatitudeAndLongitudeWithPlaceid:placeId];
    
    if (self.selectAddressDetail) {
        self.selectAddressDetail(address);
    }
    
    
    self.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.addressArray removeAllObjects];
    [self.addressArray addObjectsFromArray:dataArray];
    [self.tableView reloadData];
    
}

- (void)setKeyWord:(NSString *)keyWord {
    _keyWord = keyWord;
    NSLog(@"输入 内容： %@", keyWord);
}

- (NSMutableAttributedString *)stringWithHighLightSubstring:(NSString *)totalString substring:(NSString *)substring{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:totalString];
    NSString * copyTotalString = totalString;
    NSMutableString * replaceString = [NSMutableString stringWithString:@" "];
    for (int i = 0; i < substring.length; i ++) {
        [replaceString appendString:@" "];
    }
    while ([copyTotalString rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound) {
         NSRange range = [copyTotalString rangeOfString:substring options:NSCaseInsensitiveSearch];
         [attributedString addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_0D0D0D range:range];
         [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:range];
         copyTotalString = [copyTotalString stringByReplacingCharactersInRange:range withString:replaceString];
     }
    return attributedString;
}

-(void)getLatitudeAndLongitudeWithPlaceid:(NSString *)placeId {
    GMSAutocompleteSessionToken *sessionToken = [[GMSAutocompleteSessionToken alloc] init];
    //改成调用下面的方法
      [self.placesClient fetchPlaceFromPlaceID:placeId placeFields:GMSPlaceFieldAll sessionToken:sessionToken callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        NSLog(@"选中的名称: %@", result.name);
        NSLog(@"选中的地址：%@", result.formattedAddress);
        NSLog(@"选中的经度：%f", result.coordinate.longitude);
        NSLog(@"选中的纬度：%f", result.coordinate.latitude);
        self.latitudeString = [NSString stringWithFormat:@"%lf", result.coordinate.latitude];
        self.longitudeString = [NSString stringWithFormat:@"%lf", result.coordinate.longitude];
        self.selectAddress = STLToString(result.formattedAddress);
        NSArray *array = (NSArray *)result.addressComponents;
        for (GMSAddressComponent *addComponent in array) {
            NSArray *typesArray = addComponent.types;
            if (typesArray.count) {
                if ([typesArray[0] isEqualToString:@"country"]) {
                    self.selectCountry = addComponent.name;
                    self.selectCountryCode = addComponent.shortName;
                    
                    NSLog(@"国家简码-----：%@", addComponent.shortName);
                    NSLog(@"国家-------：%@", addComponent.name);
                    NSLog(@"国家");
                } else if ([typesArray[0] isEqualToString:@"administrative_area_level_1"]) {
                    self.selectProvince = addComponent.name;
                    NSLog(@"省份------:%@", addComponent.name);
                    NSLog(@"省份");
                } else if ([typesArray[0] isEqualToString:@"locality"]) {
                    self.selectCity = addComponent.name;
                    NSLog(@"城市：%@", addComponent.name);
                    NSLog(@"城市");
                } else if ([typesArray[0] isEqualToString:@"sublocality_level_1"]) {
                    self.selectArea = addComponent.name;
                    NSLog(@"区域：%@", addComponent.name);

                }else {
                    NSLog(@"出错了！！！！！！1");
                }
            }
        }
        NSLog(@"hhhhhhh%@-%@-%@-%@--%@---%@--%@---%@", self.selectCountryCode,self.selectCountry, self.selectProvince,self.selectCity,self.latitudeString,self.longitudeString,self.selectAddress,self.selectArea);
        
        if (self.updateCountryAndCity) {
            self.updateCountryAndCity(self.selectCountryCode,
                                      self.selectCountry,
                                      self.selectProvince,
                                      self.selectCity,
                                      self.latitudeString,
                                      self.longitudeString,
                                      self.selectAddress,
                                      self.selectArea,
                                      YES);
        }
    }];

    
//    [self.placesClient lookUpPlaceID:placeId callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
//
//        NSLog(@"选中的名称: %@", result.name);
//        NSLog(@"选中的地址：%@", result.formattedAddress);
//        NSLog(@"选中的经度：%f", result.coordinate.longitude);
//        NSLog(@"选中的纬度：%f", result.coordinate.latitude);
//        self.latitudeString = [NSString stringWithFormat:@"%lf", result.coordinate.latitude];
//        self.longitudeString = [NSString stringWithFormat:@"%lf", result.coordinate.longitude];
//        self.selectAddress = STLToString(result.formattedAddress);
//        NSArray *array = (NSArray *)result.addressComponents;
//        for (GMSAddressComponent *addComponent in array) {
//            NSArray *typesArray = addComponent.types;
//            if (typesArray.count) {
//                if ([typesArray[0] isEqualToString:@"country"]) {
//                    self.selectCountry = addComponent.name;
//                    self.selectCountryCode = addComponent.shortName;
//
//                    NSLog(@"国家简码-----：%@", addComponent.shortName);
//                    NSLog(@"国家-------：%@", addComponent.name);
//                    NSLog(@"国家");
//                } else if ([typesArray[0] isEqualToString:@"administrative_area_level_1"]) {
//                    self.selectProvince = addComponent.name;
//                    NSLog(@"省份------:%@", addComponent.name);
//                    NSLog(@"省份");
//                } else if ([typesArray[0] isEqualToString:@"locality"]) {
//                    self.selectCity = addComponent.name;
//                    NSLog(@"城市：%@", addComponent.name);
//                    NSLog(@"城市");
//                } else if ([typesArray[0] isEqualToString:@"sublocality_level_1"]) {
//                    self.selectArea = addComponent.name;
//                    NSLog(@"区域：%@", addComponent.name);
//
//                }else {
//                    NSLog(@"出错了！！！！！！1");
//                }
//            }
//        }
//        NSLog(@"hhhhhhh%@-%@-%@-%@--%@---%@--%@---%@", self.selectCountryCode,self.selectCountry, self.selectProvince,self.selectCity,self.latitudeString,self.longitudeString,self.selectAddress,self.selectArea);
//
//        if (self.updateCountryAndCity) {
//            self.updateCountryAndCity(self.selectCountryCode,
//                                      self.selectCountry,
//                                      self.selectProvince,
//                                      self.selectCity,
//                                      self.latitudeString,
//                                      self.longitudeString,
//                                      self.selectAddress,
//                                      self.selectArea,
//                                      YES);
//        }
//    }];
 
}

@end


