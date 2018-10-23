//
//  RZFMDBTestModel.h
//  RZFMDB
//
//  Created by 若醉 on 2018/10/18.
//  Copyright © 2018 rztime. All rights reserved.
//

#import "NSObject+RZFMDBHelper.h" 
#import <UIKit/UIKit.h>

@interface RZFMDBTestModel : NSObject

@property (nonatomic, assign) int rzint;
@property (nonatomic, assign) NSInteger rzNSInt;
@property (nonatomic, assign) CGFloat rzfloat;
@property (nonatomic, assign) double rzdouble;
@property (nonatomic, strong) NSNumber *rzNo;
@property (nonatomic, assign) BOOL rzBool;
@property (nonatomic, copy) NSString *rzName;
@property (nonatomic, copy) NSString *rzName1;
@property (nonatomic, copy) NSString *rzName2;
@property (nonatomic, copy) NSString *rzName3;
@property (nonatomic, copy) NSString *rzName4;
@property (nonatomic, copy) NSString *rzName5;
@property (nonatomic, copy) NSString *rzName6;

@property (nonatomic, copy) NSArray *rzArray;
@property (nonatomic, strong) NSMutableArray *rzNSMutableArray;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) void(^rzBlock)(NSInteger text);
@property (nonatomic, strong) RZFMDBTestModel *rzObjc;
@property (nonatomic, strong) NSMutableArray <RZFMDBTestModel *> *rzObjcs;

- (NSInteger) text;

@end
