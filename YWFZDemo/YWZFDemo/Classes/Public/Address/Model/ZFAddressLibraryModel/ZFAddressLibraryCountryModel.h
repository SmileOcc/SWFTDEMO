//
//  ZFAddressLibraryCountryModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressBaseModel.h"
#import "ZFAddressLibraryStateModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZFAddressLibraryCountryModel : ZFAddressBaseModel

/** 国家ID region_id*/
//@property (nonatomic, copy) NSString *idx;
/** 区域id region_code*/
@property (nonatomic, copy) NSString *rc;
/** 国家名字 region_name*/
//@property (nonatomic, copy) NSString *n;
/** 国家区号 code*/
@property (nonatomic, copy) NSString *c;
/** 支持邮编 support_zip_code*/
@property (nonatomic, copy) NSString *zc;
/** 支持 is_cod*/
@property (nonatomic, copy) NSString *cod;
/** 运营商列表 supplier_number_list*/
@property (nonatomic, strong) NSArray *n_sup;
/** 可支持的剩余号码最大长度, 多个长度 scut_number_list*/
@property (nonatomic, strong) NSArray *n_scut;
/** 1 是后台设置的 判断就直接 =  0未设置的就是 <= configured_number*/
@property (nonatomic, assign) BOOL   n_con;
///** 分组key*/
//@property (nonatomic, copy) NSString *k;

//自定义
@property (nonatomic, copy) NSArray<ZFAddressLibraryStateModel *>      *provinceList;
@property (nonatomic, strong) NSMutableArray<NSString *>               *sectionKeys;
@property (nonatomic, strong) NSMutableDictionary                      *sectionProvinceDic;


- (void)handleSelfKey;
- (void)handleSectionData;
- (NSArray *)sectionDatasForKey:(NSString *)sectionKey;

@end

NS_ASSUME_NONNULL_END
