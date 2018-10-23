//
//  RZFMDBSqlHelper.m
//  RZFMDB
//
//  Created by 若醉 on 2018/10/22.
//  Copyright © 2018 rztime. All rights reserved.
//

#import "RZFMDBSqlHelper.h"
#import <objc/runtime.h>
#import "NSObject+RZFMDBHelper.h"
#import <MJExtension/MJExtension.h>

#define RZ_DATA_OBJ @"rz_data_obj:"
#define RZ_DATA_DATE @"rz_data_date:"

@interface RZFMDBSqlHelper ()

@property (nonatomic, assign) Class modelClass;

@end

@implementation RZFMDBSqlHelper

- (NSString *)tableName {
    return NSStringFromClass(_modelClass);
}

- (NSString *)praKey {
    if (!_praKey) {
        u_int count;
        // 传递count的地址过去 &count
        objc_property_t *properties  =class_copyPropertyList(_modelClass, &count);
        NSString *ptype = [NSString stringWithUTF8String:property_getAttributes(properties[0])];
        free(properties);
#if DEBUG
        if (![ptype hasPrefix:@"Tq,"] && ![ptype hasPrefix:@"Ti,"]) {
            NSString *warn = [NSString stringWithFormat:@"请设置 %@ 属性列表第一位为 NSInteger 或 int， 将作为数据表的主键 PRIMARY KEY", NSStringFromClass(_modelClass)];
            NSAssert(ptype == nil, warn);
            NSLog(@"********************重要 ****************************\n\n\n");
            NSLog(@"%@", warn);
            NSLog(@"\n\n\n********************重要 ****************************");
            return nil;
        }
#endif
        _praKey = [[ptype componentsSeparatedByString:@"_"] lastObject];
    }
    return _praKey;
}

+ (RZFMDBSqlHelper *)rz_factoryByCreateDBTable:(Class)modelClass {
    RZFMDBSqlHelper *helper = [[RZFMDBSqlHelper alloc] init];
    helper.modelClass = modelClass;
    helper.columns = [modelClass rz_tableAllColumns];

    NSString *tableName = NSStringFromClass(modelClass); // 表名
    NSMutableArray *otherColumns = helper.columns.mutableCopy;
    [otherColumns removeObject:helper.praKey];
    helper.sql = [NSString stringWithFormat:@"create table if not exists %@ ('%@' INTEGER PRIMARY KEY AUTOINCREMENT , %@)", tableName, helper.praKey, [otherColumns componentsJoinedByString:@","]]; 
    return helper;
}

#pragma mark - 增删改查的操作
/**
 将model的数据编码
 
 @param model <#model description#>
 @return 对应的值，和 columns列一一对应
 */
- (NSArray *)rz_codingParamsArraysFromModel:(id)model {
    NSMutableArray *params = [NSMutableArray new];
    NSMutableDictionary *modelToDicts = [model mj_JSONObject];
    [self.columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = modelToDicts[obj];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *temp = [RZFMDBSqlHelper rz_codingDicts:value];
            NSString *valueString = [NSString stringWithFormat:@"%@%@", RZ_DATA_OBJ, [temp mj_JSONString]];
            [params addObject:valueString];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *temp = [RZFMDBSqlHelper rz_codingArrays:value];
            NSString *valueString = [NSString stringWithFormat:@"%@%@", RZ_DATA_OBJ, [temp mj_JSONString]];
            [params addObject:valueString];
        } else if ([value isKindOfClass:[NSDate class]]) {
            NSString *valueString = [NSString stringWithFormat:@"%@%@", RZ_DATA_DATE, [RZFMDBSqlHelper dateToString:value]];
            [params addObject:valueString];
        } else if (!value){
            [params addObject:@""];
        } else {
            [params addObject:value];
        }
    }];
    return params.copy;
}

+ (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
}
+ (NSDate *)stringToDate:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:dateString];
}
#pragma mark - 数组、字典编码
+ (NSArray *)rz_codingArrays:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDate class]]) {
            [tempArray addObject:[RZFMDBSqlHelper dateToString:obj]];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *temp = [RZFMDBSqlHelper rz_codingDicts:obj];
            [tempArray addObject:temp];
        }  else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *temp = [RZFMDBSqlHelper rz_codingArrays:obj];
            [tempArray addObject:temp];
        } else {
            [tempArray addObject:obj];
        }
    }];
    return tempArray;
}

+ (NSDictionary *)rz_codingDicts:(NSDictionary *)dict {
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDate class]]) {
            tempDict[key] = [NSString stringWithFormat:@"%@%@", RZ_DATA_DATE, [RZFMDBSqlHelper dateToString:obj]];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            tempDict[key] = [RZFMDBSqlHelper rz_codingArrays:obj];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            tempDict[key] = [RZFMDBSqlHelper rz_codingDicts:obj];
        } else {
            tempDict[key] = obj;
        }
    }];
    return tempDict.copy;
}
#pragma mark - 数组、字典解码
+ (NSArray *)rz_decodingArrays:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([obj hasPrefix:RZ_DATA_DATE]) {
                NSString *string = [obj stringByReplacingOccurrencesOfString:RZ_DATA_DATE withString:@""];
                NSDate *date = [RZFMDBSqlHelper stringToDate:string];
                [tempArray addObject:date];
            } else {
                [tempArray addObject:obj];
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *temp = [RZFMDBSqlHelper rz_decodingDicts:obj];
            [tempArray addObject:temp];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *temp = [RZFMDBSqlHelper rz_decodingArrays:obj];
            [tempArray addObject:temp];
        } else {
            [tempArray addObject:obj];
        }
    }];
    return tempArray;
}

+ (NSDictionary *)rz_decodingDicts:(NSDictionary *)dict {
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([obj hasPrefix:RZ_DATA_DATE]) {
                NSString *string = [obj stringByReplacingOccurrencesOfString:RZ_DATA_DATE withString:@""];
                NSDate *date = [RZFMDBSqlHelper stringToDate:string];
                tempDict[key] = date;
            } else {
                tempDict[key] = obj;
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *temp = [RZFMDBSqlHelper rz_decodingDicts:obj];
            tempDict[key] = temp;
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *temp = [RZFMDBSqlHelper rz_decodingArrays:obj];
            tempDict[key] = temp;
        } else {
            tempDict[key] = obj;
        }
    }];
    return tempDict.copy;
}
/**
 将字段解码，
 */
+ (NSDictionary *)rz_decodingParams:(NSDictionary *)params {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([obj hasPrefix:RZ_DATA_OBJ]) {
                id tempObj = [[obj stringByReplacingOccurrencesOfString:RZ_DATA_OBJ withString:@""] mj_JSONObject];
                if ([tempObj isKindOfClass:[NSArray class]]) {
                    NSArray *temp = [RZFMDBSqlHelper rz_decodingArrays:tempObj];
                    dict[key] = temp;
                } else if ([tempObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *temp = [RZFMDBSqlHelper rz_decodingDicts:tempObj];
                    dict[key] = temp;
                } else {
                    dict[key] = tempObj;
                }
            } else if ([obj hasPrefix:RZ_DATA_DATE]) {
                NSString *dateString = [obj stringByReplacingOccurrencesOfString:RZ_DATA_DATE withString:@""];
                NSDate *date = [RZFMDBSqlHelper stringToDate:dateString];
                dict[key] = date;
            } else {
                dict[key] = obj;
            }
        } else {
            dict[key] = obj;
        }
    }];
    return dict;
}

/**
 插入数据时，用于生成sql，列，值对应的数据
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByInsertDBTable:(id)model {
    RZFMDBSqlHelper *helper = [[RZFMDBSqlHelper alloc] init];
    helper.modelClass = [model class];
    helper.columns = [helper.modelClass rz_tableInsertColumns];
    NSMutableArray *values = [NSMutableArray new];
    for (NSInteger i = 0; i < helper.columns.count; i++) {
        [values addObject:@"?"];
    }
    
    helper.sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", helper.tableName, [helper.columns componentsJoinedByString:@", "],  [values componentsJoinedByString:@","]];
    helper.paramArrays = [helper rz_codingParamsArraysFromModel:model];
    return helper;
}

/**
 修改
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByUpdateDBTable:(id)model {
    RZFMDBSqlHelper *helper = [[RZFMDBSqlHelper alloc] init];
    helper.modelClass = [model class];
    helper.columns = [helper.modelClass rz_tableUpdateColumns];
    helper.paramArrays = [helper rz_codingParamsArraysFromModel:model];
    NSMutableArray *array = [NSMutableArray new];
    [helper.columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[NSString stringWithFormat:@"%@ = ?", obj]];
    }];
    helper.sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = %ld", helper.tableName, [array componentsJoinedByString:@","],helper.praKey, [[model valueForKey:helper.praKey] integerValue]]; 
    return helper;
}

/**
 删除
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByDeleteDBTable:(id)model {
    RZFMDBSqlHelper *helper = [[RZFMDBSqlHelper alloc] init];
    helper.modelClass = [model class];
    helper.sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %ld", helper.tableName, helper.praKey, [[model valueForKeyPath:helper.praKey] integerValue]];
    return helper;
}

@end
