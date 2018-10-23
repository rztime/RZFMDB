//
//  RZFMDBTestModel.m
//  RZFMDB
//
//  Created by 若醉 on 2018/10/18.
//  Copyright © 2018 rztime. All rights reserved.
//

#import "RZFMDBTestModel.h"
#import <MJExtension/MJExtension.h>

@implementation RZFMDBTestModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"rzObjcs": [RZFMDBTestModel class]};
}

+ (void)load {
    [self rz_createdDBTable];
}

- (void)rz_willInsertOrUpdaate {
    self.rzNSInt += 1;
    self.date = [NSDate new];
}

+ (NSMutableArray<NSString *> *)rz_tableInsertIgnoreColumns {
    return @[@"rzName3", @"rzName4"].mutableCopy;
}

- (NSInteger)text {
    return 1111111111;
}

- (void)dealloc {
//    NSLog(@"__%s__", __FUNCTION__);
}

@end
