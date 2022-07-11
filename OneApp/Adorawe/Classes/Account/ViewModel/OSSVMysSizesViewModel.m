//
//  OSSVMysSizesViewModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMysSizesViewModel.h"
#import "OSSVSizesModel.h"

#import "OSSVMysSizesAip.h"
#import "OSSVSavesMysSizesAip.h"

@interface OSSVMysSizesViewModel ()

@property (nonatomic, strong)OSSVSizesModel *sizeModel;

@end

@implementation OSSVMysSizesViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (NSString *)reuseIdentifier{
    return NSStringFromClass(self.class);
}

#pragma mark -- request

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    /// 获取尺码信息
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVMysSizesAip *mySizeApi = [[OSSVMysSizesAip alloc] init];
        [mySizeApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];

            self.sizeModel = [self dataAnalysisFromJson: requestJSON request:mySizeApi];
            if (completion) {
                completion(self.sizeModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                self.sizeModel = [self getDefaultSizeModel];
                failure(self.sizeModel);
            }
        }];
    } exception:^{
        if (failure) {
            self.sizeModel = [self getDefaultSizeModel];
            failure(self.sizeModel);
        }
    }];
    
}

/// 保存尺码信息
- (void)saveRequestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVSavesMysSizesAip *mySizeApi = [[OSSVSavesMysSizesAip alloc] initWithSizeType:self.sizeModel.size_type gender:self.sizeModel.gender height:self.sizeModel.height weight:self.sizeModel.weight];
        [mySizeApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            [self dataAnalysisFromJson: requestJSON request:mySizeApi];
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVMysSizesAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVSizesModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    } else {
        [self alertMessage:json[@"message"]];
    }
    return nil;
}

#pragma mark -- table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSSVMysSizesCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    cell.sizeModel = self.sizeModel;
    cell.cellType = indexPath.row;
    
    @weakify(self);
    cell.sizeDidSelectedblock = ^(sizeCellType cellType, NSInteger row) {
        @strongify(self);
        if (cellType == sizeCellTypeSize) {
            self.sizeModel.size_type = row;
            
            CGFloat height = [self.sizeModel.height floatValue];
            CGFloat weight = [self.sizeModel.weight floatValue];
            if (self.sizeModel.size_type == 1) {
                // inch转化成cm
                height = height / 0.3937;
                weight = weight / 2.2046;
            }else {
                // cm转化成inch
                height = height * 0.3937;
                weight = weight * 2.2046;
            }
            NSString *objA = nil;
            if (self.sizeModel.size_type == 1) {
                objA = [NSString stringWithFormat:@"%.0f", (double)height];
            }else{
                objA = [NSString stringWithFormat:@"%.1f", (double)height];
            }
            NSString *objB = [NSString stringWithFormat:@"%.1f", (double)weight];
            
            self.sizeModel.height = objA;
            self.sizeModel.weight = objB;
            [tableView reloadData];
            
        }else if (cellType == sizeCellTypeGender){
            self.sizeModel.gender = row;
        }
    };
    
    cell.changeSizeDsceblock = ^(NSString * _Nonnull desc) {
        @strongify(self);
        if (self.changeDescblock) {
            self.changeDescblock(desc);
        }
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [OSSVMysSizesCell getHeightWithType:indexPath.row];
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellDidClick) {
        self.cellDidClick(indexPath.row, self.sizeModel);
    }
}

// 网络失败的默认值
- (OSSVSizesModel *)getDefaultSizeModel{
    OSSVSizesModel *sizeModel = [[OSSVSizesModel alloc] init];
    sizeModel.gender = 2;
    sizeModel.size_type = 1;
    sizeModel.height = @"0";
    sizeModel.weight = @"0";
    
    return sizeModel;
}
@end
