//
//  RZFMDBSqlHelper.h
//  RZFMDB
//
//  Created by 若醉 on 2018/10/22.
//  Copyright © 2018 rztime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFMDBSqlHelper : NSObject

@property (nonatomic, strong) NSError *error; // 是否有错，如果error存在，则不能进行，增删改查和创建表的数据

@property (nonatomic, copy) NSString *sql;
@property (nonatomic, copy) NSArray <NSString *> *columns; //  列
@property (nonatomic, copy) NSArray *paramArrays;         // 列对应的参数， 和columns 一一对应
@property (nonatomic, copy) NSString *praKey;

- (NSString *)tableName;

/**
 将model的数据编码

 @param model <#model description#>
 @return 对应的值，和 columns列一一对应
 */
- (NSArray *)rz_codingParamsArraysFromModel:(id)model;

/**
 将字段解码， 
 */
+ (NSDictionary *)rz_decodingParams:(NSDictionary *)params;
/**
 创建表，用于生成创建表的sql，和主键

 @param modelClass <#modelClass description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByCreateDBTable:(Class)modelClass;

/**
 插入数据时，用于生成sql，列，值对应的数据

 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByInsertDBTable:(id)model;

/**
 修改

 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByUpdateDBTable:(id)model;

/**
 删除

 @param model <#model description#>
 @return <#return value description#>
 */
+ (RZFMDBSqlHelper *)rz_factoryByDeleteDBTable:(id)model;

@end
