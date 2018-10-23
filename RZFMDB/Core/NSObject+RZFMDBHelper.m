//
//  NSObject+RZFMDBHelper.m
//  RZFMDB
//
//  Created by 若醉 on 2018/10/22.
//  Copyright © 2018 rztime. All rights reserved.
//

#import "NSObject+RZFMDBHelper.h"
#import <objc/runtime.h>
#import "RZFMDBSqlHelper.h"
#import <FMDB/FMDB.h>
#import <MJExtension/MJExtension.h>

#define RZDBDirectionry @"/tmp/RZFMDB/"
#define RZDBName @"RZFMDB.db"

@implementation NSObject (RZFMDBHelper)

/**
 创建数据库 可以在Model的 +(void)load 中调用
 
 @return YES:创建成果
 */
+ (BOOL)rz_createdDBTable {
    RZFMDBSqlHelper *helper = [RZFMDBSqlHelper rz_factoryByCreateDBTable:[self class]];
    if (!helper) {
        return NO;
    }
    NSFileManager *manage = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:RZDBDirectionry];
    if(![manage isExecutableFileAtPath:filePath]) {
        [manage createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *dbName = [NSString stringWithFormat:RZDBName];
    NSString *dbPath = [filePath stringByAppendingString:dbName];
    NSLog(@"**********RZFMDBPath:************\n%@\n\n", dbPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        BOOL result = [db executeUpdate:helper.sql];
        if (result) {
            NSLog(@"create table success");
            [helper.columns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![db columnExists:obj inTableWithName:helper.tableName]) {
                    NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER", helper.tableName, obj];
                    if([db executeUpdate:alertStr]) {
                        NSLog(@"%@ 表新增字段:%@ 成功", helper.tableName, obj);
                    } else {
                        NSLog(@"%@ 表新增字段:%@ 失败", helper.tableName, obj);
                    }
                }
            }];
        }
        [db close];
        return YES;
    } else {
        NSLog(@"文件数据库打开失败");
        return NO;
    }
}

+ (NSMutableArray <NSString *> *)rz_allProperties {
    u_int count;
    // 传递count的地址过去 &count
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    //arrayWithCapacity的效率稍微高那么一丢丢
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++) {
        const char* propertyNameat = property_getAttributes(properties[i]);
        [propertiesArray addObject:[NSString stringWithUTF8String:propertyNameat]];
    }
    free(properties);
    return propertiesArray.mutableCopy;
}

+ (NSMutableArray <NSString *> *)rz_tableAllColumns {
    NSMutableArray *proTypeNames = [self rz_allProperties].mutableCopy;
    if (proTypeNames.count == 0) {
        return nil;
    }
    NSMutableArray *columnNames = [NSMutableArray new]; // 列名
#if DEBUG   // debug模式下，会检查属性列表第一位是否为int或者NSInteger 主键
    NSString *praKey = proTypeNames[0];
    if ([praKey hasPrefix:@"Tq,"] || [praKey hasPrefix:@"Ti,"]) {  // 以Model属性第一位为 NSInteger 或 int 作为主键，如果不是主键，则不建表
        [columnNames addObject:[[praKey componentsSeparatedByString:@"_"] lastObject]];
    } else {
        NSString *warn = [NSString stringWithFormat:@"请设置%@属性列表第一位为 NSInteger 或 int， 将作为数据表的主键 PRIMARY KEY", NSStringFromClass([self class])];

        NSAssert(praKey == nil, warn);

        NSLog(@"********************重要 ****************************\n\n\n");
        NSLog(@"%@", warn);
        NSLog(@"\n\n\n********************重要 ****************************");
        return nil;
    }
    for (NSInteger i = 1; i < proTypeNames.count; i++) {
        NSString *string = proTypeNames[i];
        if ([string hasPrefix:@"T@?,"]) {  // 未知类型的数据将不加入到数据库中
            continue;
        }
        NSString *column = [[string componentsSeparatedByString:@"_"] lastObject];
        [columnNames addObject:column];
    }
#else
    for (NSInteger i = 0; i < proTypeNames.count; i++) {
        NSString *string = proTypeNames[i];
        if ([string hasPrefix:@"T@?,"]) {  // 未知类型的数据将不加入到数据库中
            continue;
        }
        NSString *column = [[string componentsSeparatedByString:@"_"] lastObject];
        [columnNames addObject:column];
    }
#endif
    NSArray *ignoreColumns = [self rz_tableInsertIgnoreColumns];
    if (ignoreColumns.count > 0) {
        [columnNames removeObjectsInArray:ignoreColumns];
    }
    return columnNames.mutableCopy;
}
/**
 需要插入的列
 
 @return 需要插入的列，默认是没有主键的
 */
+ (NSMutableArray <NSString *> *)rz_tableInsertColumns {
    NSMutableArray *allColumns = [self rz_tableAllColumns];
    if (allColumns.count > 0) {
        [allColumns removeObjectAtIndex:0]; // 将主键移除
    }
    return allColumns.mutableCopy;
}

/**
 插入时，需要忽略的列
 
 @return ..
 */
+ (NSMutableArray <NSString *> *)rz_tableInsertIgnoreColumns {
    return nil;
}

/**
 需要更新的列 (没有主键)
 
 @return 需要插入的列，默认是没有主键的
 */
+ (NSMutableArray <NSString *> *)rz_tableUpdateColumns {
    NSMutableArray *updates = [self rz_tableInsertColumns];
    NSArray *ignore = [self rz_tableUpdateIgnoreColumns];
    if (ignore.count > 0) {
        [updates removeObjectsInArray:ignore];
    }
    return updates.mutableCopy;
}

/**
 需要更新时，忽略的列  (没有主键)
 
 @return ..
 */
+ (NSMutableArray <NSString *> *)rz_tableUpdateIgnoreColumns {
    return nil;
}

#pragma mark - 增删改查

/**
 将要增改时，调用此方法
 */
- (void)rz_willInsertOrUpdaate {
    
}
/**
 插入数据
 
 @return ..
 */
- (BOOL)rz_insertDataToDBTable {
    [self rz_willInsertOrUpdaate];
    RZFMDBSqlHelper *helper = [RZFMDBSqlHelper rz_factoryByInsertDBTable:self];
    __block BOOL result = NO;
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if(![db executeUpdate:helper.sql withArgumentsInArray:helper.paramArrays]) {
            *rollback = YES;
            NSLog(@"插入失败");
        } else {
            NSLog(@"插入数据成功");
            result = YES;
            [self setValue:@([db lastInsertRowId]) forKeyPath:helper.praKey];
        }
    }];
    return result;
}
/**
 批量插入数据
 
 @param models 数据模型
 @return ..
 */
+ (BOOL)rz_insertDataToDBTableByMultiData:(NSArray *)models {
    if (models.count == 0) {
        return YES;
    }
#if DEBUG
    id Model = [models firstObject];
    if (![Model isMemberOfClass:[self class]]) {
        NSString *warn = [NSString stringWithFormat:@"批量插入时，类方法尽量使用Model的类去调用"];
        NSAssert(NO, warn);
        return NO;
    }
#endif
    RZFMDBSqlHelper *helper = [RZFMDBSqlHelper rz_factoryByInsertDBTable:[models firstObject]];
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj rz_willInsertOrUpdaate];
            NSArray *params = [helper rz_codingParamsArraysFromModel:obj];
            if(![db executeUpdate:helper.sql withArgumentsInArray:params]) {
                *rollback = YES;
                NSLog(@"批量插入失败");
                *stop  = YES;
            } else {
                [obj setValue:@([db lastInsertRowId]) forKeyPath:helper.praKey];
            }
        }];
    }];
    return YES;
}

/**
 修改数据
 
 @return ...
 */
- (BOOL)rz_updateDataToDBTable {
    [self rz_willInsertOrUpdaate];
    RZFMDBSqlHelper *helper = [RZFMDBSqlHelper rz_factoryByUpdateDBTable:self];
    __block BOOL result = NO;
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if(![db executeUpdate:helper.sql withArgumentsInArray:helper.paramArrays]) {
            *rollback = YES;
            NSLog(@"修改失败");
        } else {
            NSLog(@"修改数据成功");
            result = YES;
        }
    }];
    return result;
}

/**
 删除数据
 
 @return ..
 */
- (BOOL)rz_deleteDataFromDBTable {
    RZFMDBSqlHelper *helper = [RZFMDBSqlHelper rz_factoryByDeleteDBTable:self];
    __block BOOL result = NO;
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if(![db executeUpdate:helper.sql]) {
            *rollback = YES;
            NSLog(@"删除失败");
        } else {
            NSLog(@"删除数据成功");
            result = YES;
        }
    }];
    return result;
}
/**
 通过条件删除  格式 (culumn1 = value1 and culumn2 = value2 and ...)  为nil时，删除全部全部
 
 @param condition <#condition description#>
 @return <#return value description#>
 */
+ (BOOL)rz_deleteDataFromDBTableByCondition:(NSString *)condition {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", NSStringFromClass([self class])];
    if (condition.length > 0) {
        sql = [sql stringByAppendingFormat:@" %@", condition];
    }
    __block BOOL result = NO;
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if(![db executeUpdate:sql]) {
            *rollback = YES;
            NSLog(@"删除失败");
        } else {
            NSLog(@"删除数据成功");
            result = YES;
        }
    }];
    return result;
}
/**
 查询所有数据
 
 @return ..
 */
+ (NSMutableArray *)rz_queryDataFromDBTable {
    return [self rz_queryDataFromDBTableByCondition:nil];
}

/**
 通过条件查询  格式 (culumn1 = value1 and culumn2 = value2 and ...)  为nil时，查询全部
 
 @param condition <#condition description#>
 @return <#return value description#>
 */
+ (NSMutableArray *)rz_queryDataFromDBTableByCondition:(NSString *)condition {
    NSMutableArray *dataArray = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", NSStringFromClass([self class])];
    if (condition.length > 0) {
        sql = [sql stringByAppendingFormat:@" WHERE %@", condition];
    }
    NSString *path = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), RZDBDirectionry, RZDBName];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            NSDictionary *dict = [set resultDictionary];
            NSDictionary *decodingDict = [RZFMDBSqlHelper rz_decodingParams:dict];
            id model = [[self class] mj_objectWithKeyValues:decodingDict];
            [dataArray addObject:model];
        }
    }];
    return dataArray.mutableCopy;
}

@end
