//
//  NSObject+RZFMDBHelper.h
//  RZFMDB
//
//  Created by 若醉 on 2018/10/22.
//  Copyright © 2018 rztime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RZFMDBHelper)

/**
 创建数据库 可以在Model的 +(void)load 中调用
 
 @return YES:创建成果
 */
+ (BOOL)rz_createdDBTable;

/**
 所有的列  默认将把Model中所有的数据（除block，未知类型，和[rz_tableInsertIgnoreColumns]忽略的数据）作为表的列，数组第一个为主键
 
 @return <#return value description#>
 */
+ (NSMutableArray <NSString *> *)rz_tableAllColumns;

/**
 需要插入的列 （没有主键)
 
 @return 需要插入的列，默认是没有主键的
 */
+ (NSMutableArray <NSString *> *)rz_tableInsertColumns;

/**
 插入时，需要忽略的列
 
 @return ..
 */
+ (NSMutableArray <NSString *> *)rz_tableInsertIgnoreColumns;

/**
 需要更新的列 (没有主键)
 
 @return 需要插入的列，默认是没有主键的
 */
+ (NSMutableArray <NSString *> *)rz_tableUpdateColumns;

/**
 需要更新时，忽略的列  (没有主键)
 
 @return ..
 */
+ (NSMutableArray <NSString *> *)rz_tableUpdateIgnoreColumns;

#pragma mark - 增删改查

/**
 将要增改时，调用此方法,如需使用，在Model中重写
 */
- (void)rz_willInsertOrUpdaate;
/**
 插入数据 插入成功后，会将主键值赋值回来

 @return ..
 */
- (BOOL)rz_insertDataToDBTable;

/**
 批量插入数据 插入成功后，会将主键值赋值回来

 @param models 数据模型
 @return ..
 */
+ (BOOL)rz_insertDataToDBTableByMultiData:(NSArray *)models;

/**
 修改数据

 @return ...
 */
- (BOOL)rz_updateDataToDBTable;

/**
 删除数据

 @return <#return value description#>
 */
- (BOOL)rz_deleteDataFromDBTable;
/**
 通过条件删除  格式 (culumn1 = value1 and culumn2 = value2 and ...)  为nil时，删除全部全部
 
 @param condition <#condition description#>
 @return <#return value description#>
 */
+ (BOOL)rz_deleteDataFromDBTableByCondition:(NSString *)condition;
/**
 查询所有数据

 @return ..
 */
+ (NSMutableArray *)rz_queryDataFromDBTable;

/**
 通过条件查询  格式 (culumn1 = value1 and culumn2 = value2 and ...)  为nil时，查询全部

 @param condition <#condition description#>
 @return <#return value description#>
 */
+ (NSMutableArray *)rz_queryDataFromDBTableByCondition:(NSString *)condition;

@end
