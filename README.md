# RZFMDB

### 关于FMDB
对FMDB的封装，以Model的形式，一行代码进行增删改查，Model的属性可以为任意类型（字符串，整型，浮点型等，NSArray *, NSArray <NSOBject *> *，NSObject *，NSDictionary *，NSData, NSDate等等）。
当Model中嵌套多层次的数组、模型数组、字典数组等等，会加大消耗，所以尽量只包含字符串浮点型等等不包含嵌套和数组的属性，可以提高运行效率   


### 使用

##### 创建一个Model，将需要创建数据表的字段作为Model的属性，将自动建表，Model属性列表第一个为 NSInteger 或 int， 将作为数据表的主键 PRIMARY KEY

在Model中添加头文件
```objc
#import "NSObject+RZFMDBHelper.h"
```

* 1 创建表
```objc
/**
创建数据库 可以在Model的 +(void)load 中调用

@return YES:创建成果
*/
+ (BOOL)rz_createdDBTable;
```
* 2 表字段的处理
```objc
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

```
#### 备注：如果在Model中重写上述方法一个或多个，将按照配置取数据创建表、以及插入数据表，如果不重写，将默认以Model中所有的属性作为插入表的列依据

```objc
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
```
#### 备注：如果在Model中重写上述方法，将按照配置来取数据字段已更新数据库，如果不重写，则默认更新所有的数据

#### 在插入、更新时，都将调用
```objc
/**
将要增改时，调用此方法,如需使用，在Model中重写
*/
- (void)rz_willInsertOrUpdaate;
```

### 增删改查处理
* 请用Model或Model的实例，调用方法，因为会使用MJExtension将Model转换为字典，或将字典还原回Model
```objc
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
```


# 最后
### Model中可以层层嵌套多种数据（数组，字典、NSObject（NSObject中还可以嵌套）），最后查询完会通过MJExtension还原回对应的Model，如果有嵌套的数组，请配置[+ (NSDictionary *)mj_objectClassInArray]方法

### 提示，Model中嵌套数据过多时，批量插入如10000条，将会非常耗时，通过测试【模拟器上】,层层嵌套式【#if 1】批量插入耗时32秒，当只有常规数据【#if 0】插入时，只耗时1秒，差距非常大，所以请尽量不要嵌套

测试代码
```objc

- (RZFMDBTestModel *)lazayModel {
    RZFMDBTestModel *model = [[RZFMDBTestModel alloc] init];

    model.rzNSInt = 1;
    model.rzfloat = 1.1;
    model.rzdouble = 1.1111;
    model.rzNo = @(2);
    model.rzBool = YES;
    model.rzName = @"rztime";
    model.rzName1 = @"rztime1";
    model.rzName2 = @"rztime2";
    model.rzName3 = @"rztime3";
    model.rzName4 = @"rztime4";
    model.rzName5 = @"rztime5";
    model.rzName6 = @"rztime6";
#if 0
    model.rzArray = @[@"数组1"];
    model.rzNSMutableArray = @[@"数组2", @"数组2"].mutableCopy;
    model.date = [NSDate new];
    model.data = UIImagePNGRepresentation([UIImage imageNamed:@"test"]);
    model.rzBlock = ^(NSInteger text) {
        NSLog(@"block");
    };
    RZFMDBTestModel *temp = [[RZFMDBTestModel alloc] init];
    model.rzObjc = temp;
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 5; i++) {
        RZFMDBTestModel *temp = [[RZFMDBTestModel alloc] init];
        temp.date = [NSDate new];

        NSMutableArray *temarray = [NSMutableArray new];
        for (NSInteger i = 0; i < 5; i++) {
            RZFMDBTestModel *temp1 = [[RZFMDBTestModel alloc] init];
            temp1.date = [NSDate new];
            [temarray addObject:temp1];
        }
        temp.rzObjcs = temarray.mutableCopy;

        [array addObject:temp];
    }
    model.rzObjcs = array.mutableCopy;
#endif
    return model;
}
```
