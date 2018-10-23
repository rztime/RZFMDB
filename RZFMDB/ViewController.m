//
//  ViewController.m
//  RZFMDB
//
//  Created by 若醉 on 2018/10/18.
//  Copyright © 2018 rztime. All rights reserved.
//

#import "ViewController.h"
#import "RZFMDBTestModel.h"
#import "NSObject+RZFMDBHelper.h"
#import <MJExtension/MJExtension.h>
#import "RZFMDBSqlHelper.h"
@interface ViewController ()
{
    RZFMDBTestModel *_model;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    butn.frame = CGRectMake(10, 100, 200, 30);
    butn.backgroundColor = [UIColor redColor];
    [butn setTitle:@"插入数据" forState:UIControlStateNormal];
    [self.view addSubview:butn];
    
    UIButton *butn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    butn1.frame = CGRectMake(10, 150, 200, 30);
    butn1.backgroundColor = [UIColor orangeColor];
    [butn1 setTitle:@"更新数据" forState:UIControlStateNormal];
    [self.view addSubview:butn1];
    
    UIButton *butn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    butn2.frame = CGRectMake(10, 200, 200, 30);
    butn2.backgroundColor = [UIColor orangeColor];
    [butn2 setTitle:@"删除数据" forState:UIControlStateNormal];
    [self.view addSubview:butn2];
    
    UIButton *butn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    butn3.frame = CGRectMake(10, 250, 300, 30);
    butn3.backgroundColor = [UIColor orangeColor];
    [butn3 setTitle:@"批量插入数据数据" forState:UIControlStateNormal];
    [self.view addSubview:butn3];
    
    UIButton *butn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    butn4.frame = CGRectMake(10, 300, 300, 30);
    butn4.backgroundColor = [UIColor orangeColor];
    [butn4 setTitle:@"批量查询数据数据" forState:UIControlStateNormal];
    [self.view addSubview:butn4];
    
    UIButton *butn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    butn5.frame = CGRectMake(10, 350, 300, 30);
    butn5.backgroundColor = [UIColor orangeColor];
    [butn5 setTitle:@"查询数据" forState:UIControlStateNormal];
    [self.view addSubview:butn5];
    
    [butn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [butn1 addTarget:self action:@selector(buttonClicked1) forControlEvents:UIControlEventTouchUpInside];
    [butn2 addTarget:self action:@selector(buttonClicked2) forControlEvents:UIControlEventTouchUpInside];
    [butn3 addTarget:self action:@selector(buttonClicked3) forControlEvents:UIControlEventTouchUpInside];
    [butn4 addTarget:self action:@selector(buttonClicked4) forControlEvents:UIControlEventTouchUpInside];
    [butn5 addTarget:self action:@selector(buttonClicked5) forControlEvents:UIControlEventTouchUpInside];
    _model = self.lazayModel;
}

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

- (void)buttonClicked {
    NSDate *data1 = [NSDate new];
    [_model rz_insertDataToDBTable];
    NSLog(@"插入时长:%f", [data1 timeIntervalSinceNow]);
}
- (void)buttonClicked1 {
    NSDate *data1 = [NSDate new];
    [_model rz_updateDataToDBTable];
    NSLog(@"更新时长:%f", [data1 timeIntervalSinceNow]);
}
- (void)buttonClicked2 {
    [_model rz_deleteDataFromDBTable];
}

- (void)buttonClicked3 {
    NSLog(@"time1");
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 10000; i++) {
        [array addObject:self.lazayModel];
    }
    NSLog(@"time2");
    NSDate *data1 = [NSDate new];
    
    [RZFMDBTestModel rz_insertDataToDBTableByMultiData:array];
    NSLog(@"批量插入时长:%f", [data1 timeIntervalSinceNow]);
    NSLog(@"array.%ld", array.count);
}

- (void)buttonClicked4 {
    NSArray *array = [RZFMDBTestModel rz_queryDataFromDBTable];
    NSLog(@"array:%@", array);
}

- (void)buttonClicked5 {
    NSString *condition = [NSString stringWithFormat:@"rzint = %d and rzName = '%@'", 2, @"rztime"];
    NSArray *array = [RZFMDBTestModel rz_queryDataFromDBTableByCondition:condition];
    NSLog(@"array:%@", array);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
