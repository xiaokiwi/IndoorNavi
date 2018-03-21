//
//  ViewController.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import "TriangulationAlgorithm.h"
#include <math.h>
#import "fingerprinting.h"
#import "rssi_data.h"


@interface ViewController () {
    NSMutableArray * peripheralDataArray;
    BabyBluetooth * baby;
    TriangulationCalculator * triangulationCalculator;
    int PowerLevel;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Database Setup
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"Rssi2DB"];

    // Insert Data (examples)
    RssiEntity * entity1 = [[RssiEntity alloc] init];
    entity1.number = 1;
    entity1.x = 2;
    entity1.y = 0;
    entity1.beacon = 1;
    entity1.value = -60;
    
    RssiEntity * entity2 = [[RssiEntity alloc] init];
    entity2.number = 2;
    entity2.x = 2;
    entity2.y = 0;
    entity2.beacon = 2;
    entity2.value = -77;
    
    RssiEntity * entity3 = [[RssiEntity alloc] init];
    entity3.number = 3 ;
    entity3.x = 2;
    entity3.y = 0;
    entity3.beacon = 3;
    entity3.value = -74;
    
    RssiEntity * entity4 = [[RssiEntity alloc] init];
    entity4.number = 4 ;
    entity4.x = 3.8;
    entity4.y = 0;
    entity4.beacon = 1;
    entity4.value = -63;
    
    RssiEntity * entity5 = [[RssiEntity alloc] init];
    entity5.number = 5;
    entity5.x = 3.8;
    entity5.y = 0;
    entity5.beacon = 2;
    entity5.value = -79;
    
    RssiEntity * entity6 = [[RssiEntity alloc] init];
    entity6.number = 6 ;
    entity6.x = 3.8;
    entity6.y = 0;
    entity6.beacon = 3;
    entity6.value = -73;
    
    RssiEntity * entity7 = [[RssiEntity alloc] init];
    entity7.number = 7;
    entity7.x = 2;
    entity7.y = 1.9;
    entity7.beacon = 1;
    entity7.value = -56;
    
    RssiEntity * entity8 = [[RssiEntity alloc] init];
    entity8.number = 8 ;
    entity8.x = 2;
    entity8.y = 1.9;
    entity8.beacon = 2;
    entity8.value = -77;
    
    RssiEntity * entity9 = [[RssiEntity alloc] init];
    entity9.number = 9 ;
    entity9.x = 2;
    entity9.y = 1.9;
    entity9.beacon = 3;
    entity9.value = -74;
    
    RssiEntity * entity10 = [[RssiEntity alloc] init];
    entity10.number = 10 ;
    entity10.x = 3.8;
    entity10.y = 1.9;
    entity10.beacon = 1;
    entity10.value = -57;
    
    RssiEntity * entity11 = [[RssiEntity alloc] init];
    entity11.number = 11;
    entity11.x = 3.8;
    entity11.y = 1.9;
    entity11.beacon = 2;
    entity11.value = -78;
    
    RssiEntity * entity12 = [[RssiEntity alloc] init];
    entity12.number = 12 ;
    entity12.x = 3.8;
    entity12.y = 1.9;
    entity12.beacon = 3;
    entity12.value = -72;
    
    RssiEntity * entity13 = [[RssiEntity alloc] init];
    entity13.number = 13 ;
    entity13.x = 2;
    entity13.y = 3.7;
    entity13.beacon = 1;
    entity13.value = -63;
    
    RssiEntity * entity14 = [[RssiEntity alloc] init];
    entity14.number = 14;
    entity14.x = 2;
    entity14.y = 3.7;
    entity14.beacon = 2;
    entity14.value = -72;
    
    RssiEntity * entity15 = [[RssiEntity alloc] init];
    entity15.number = 15 ;
    entity15.x = 2;
    entity15.y = 3.7;
    entity15.beacon = 3;
    entity15.value = -67;
    
    RssiEntity * entity16 = [[RssiEntity alloc] init];
    entity16.number = 16 ;
    entity16.x = 3.8;
    entity16.y = 3.7;
    entity16.beacon = 1;
    entity16.value = -61;
    
    RssiEntity * entity17 = [[RssiEntity alloc] init];
    entity17.number = 17;
    entity17.x = 3.8;
    entity17.y = 3.7;
    entity17.beacon = 2;
    entity17.value = -75;
    
    RssiEntity * entity18 = [[RssiEntity alloc] init];
    entity18.number = 18 ;
    entity18.x = 3.8;
    entity18.y = 3.7;
    entity18.beacon = 3;
    entity18.value = -70;
    
    
    RssiEntity * entity19 = [[RssiEntity alloc] init];
    entity19.number = 19 ;
    entity19.x = 2;
    entity19.y = 5.5;
    entity19.beacon = 1;
    entity19.value = -66;
    
    RssiEntity * entity20 = [[RssiEntity alloc] init];
    entity20.number = 20;
    entity20.x = 2;
    entity20.y = 5.5;
    entity20.beacon = 2;
    entity20.value = -77;
    
    RssiEntity * entity21 = [[RssiEntity alloc] init];
    entity21.number = 21;
    entity21.x = 2;
    entity21.y = 5.5;
    entity21.beacon = 3;
    entity21.value = -67;
    
    RssiEntity * entity22 = [[RssiEntity alloc] init];
    entity22.number = 22 ;
    entity22.x = 3.8;
    entity22.y = 5.5;
    entity22.beacon = 1;
    entity22.value = -63;
    
    RssiEntity * entity23 = [[RssiEntity alloc] init];
    entity23.number = 23;
    entity23.x = 3.8;
    entity23.y = 5.5;
    entity23.beacon = 2;
    entity23.value = -75;
    
    RssiEntity * entity24 = [[RssiEntity alloc] init];
    entity24.number = 24;
    entity24.x = 3.8;
    entity24.y = 5.5;
    entity24.beacon = 3;
    entity24.value = -60;
    
    RssiEntity * entity25 = [[RssiEntity alloc] init];
    entity25.number = 25 ;
    entity25.x = 2;
    entity25.y = 7.3;
    entity25.beacon = 1;
    entity25.value = -70;
    
    RssiEntity * entity26 = [[RssiEntity alloc] init];
    entity26.number = 26;
    entity26.x = 2;
    entity26.y = 7.3;
    entity26.beacon = 2;
    entity26.value = -73;
    
    RssiEntity * entity27 = [[RssiEntity alloc] init];
    entity27.number = 27;
    entity27.x = 2;
    entity27.y = 7.3;
    entity27.beacon = 3;
    entity27.value = -62;
    
    RssiEntity * entity28 = [[RssiEntity alloc] init];
    entity28.number = 28 ;
    entity28.x = 3.8;
    entity28.y = 7.3;
    entity28.beacon = 1;
    entity28.value = -69;
    
    RssiEntity * entity29 = [[RssiEntity alloc] init];
    entity29.number = 29;
    entity29.x = 3.8;
    entity29.y = 7.3;
    entity29.beacon = 2;
    entity29.value = -72;
    
    RssiEntity * entity30 = [[RssiEntity alloc] init];
    entity30.number = 30;
    entity30.x = 3.8;
    entity30.y = 7.3;
    entity30.beacon = 3;
    entity30.value = -58;
    
    RssiEntity * entity31 = [[RssiEntity alloc] init];
    entity31.number = 31 ;
    entity31.x = 2;
    entity31.y = 9.1;
    entity31.beacon = 1;
    entity31.value = -70;
    
    RssiEntity * entity32 = [[RssiEntity alloc] init];
    entity32.number = 32;
    entity32.x = 2;
    entity32.y = 9.1;
    entity32.beacon = 2;
    entity32.value = -70;
    
    RssiEntity * entity33 = [[RssiEntity alloc] init];
    entity33.number = 33;
    entity33.x = 2;
    entity33.y = 9.1;
    entity33.beacon = 3;
    entity33.value = -63;
    RssiEntity * entity34 = [[RssiEntity alloc] init];
    entity34.number = 34 ;
    entity34.x = 3.8;
    entity34.y = 9.1;
    entity34.beacon = 1;
    entity34.value = -71;
    
    RssiEntity * entity35 = [[RssiEntity alloc] init];
    entity35.number = 35;
    entity35.x = 3.8;
    entity35.y = 9.1;
    entity35.beacon = 2;
    entity35.value = -71;
    
    RssiEntity * entity36 = [[RssiEntity alloc] init];
    entity36.number = 36;
    entity36.x = 3.8;
    entity36.y = 9.1;
    entity36.beacon = 3;
    entity36.value = -53;
    
    RssiEntity * entity37 = [[RssiEntity alloc] init];
    entity37.number = 37 ;
    entity37.x = 2;
    entity37.y = 10.9;
    entity37.beacon = 1;
    entity37.value = -68;
    
    RssiEntity * entity38 = [[RssiEntity alloc] init];
    entity38.number = 38;
    entity38.x = 2;
    entity38.y = 10.9;
    entity38.beacon = 2;
    entity38.value = -63;
    
    RssiEntity * entity39 = [[RssiEntity alloc] init];
    entity39.number = 39;
    entity39.x = 2;
    entity39.y = 10.9;
    entity39.beacon = 3;
    entity39.value = -66;
    RssiEntity * entity40= [[RssiEntity alloc] init];
    entity40.number = 40 ;
    entity40.x = 3.8;
    entity40.y = 10.9;
    entity40.beacon = 1;
    entity40.value = -69;
    
    RssiEntity * entity41 = [[RssiEntity alloc] init];
    entity41.number = 41;
    entity41.x = 3.8;
    entity41.y = 10.9;
    entity41.beacon = 2;
    entity41.value = -66;
    
    RssiEntity * entity42 = [[RssiEntity alloc] init];
    entity42.number = 42;
    entity42.x = 3.8;
    entity42.y = 10.9;
    entity42.beacon = 3;
    entity42.value = -68;
    
    RssiEntity * entity43= [[RssiEntity alloc] init];
    entity43.number = 43 ;
    entity43.x = 2;
    entity43.y = 12.7;
    entity43.beacon = 1;
    entity43.value = -69;
    
    RssiEntity * entity44 = [[RssiEntity alloc] init];
    entity44.number = 44;
    entity44.x = 2;
    entity44.y = 12.7;
    entity44.beacon = 2;
    entity44.value = -65;
    
    RssiEntity * entity45 = [[RssiEntity alloc] init];
    entity45.number = 45;
    entity45.x = 2;
    entity45.y = 12.7;
    entity45.beacon = 3;
    entity45.value = -68;
    
    RssiEntity * entity46 = [[RssiEntity alloc] init];
    entity46.number = 46 ;
    entity46.x = 3.8;
    entity46.y = 12.7;
    entity46.beacon = 1;
    entity46.value = -68;
    
    RssiEntity * entity47 = [[RssiEntity alloc] init];
    entity47.number = 47;
    entity47.x = 3.8;
    entity47.y = 12.7;
    entity47.beacon = 2;
    entity47.value = -70;
    
    RssiEntity * entity48 = [[RssiEntity alloc] init];
    entity48.number = 48;
    entity48.x = 3.8;
    entity48.y = 12.7;
    entity48.beacon = 3;
    entity48.value = -70;
    
    RssiEntity * entity49 = [[RssiEntity alloc] init];
    entity49.number = 49 ;
    entity49.x = 2;
    entity49.y = 14.5;
    entity49.beacon = 1;
    entity49.value = -75;
    
    RssiEntity * entity50 = [[RssiEntity alloc] init];
    entity50.number = 50;
    entity50.x = 2;
    entity50.y = 14.5;
    entity50.beacon = 2;
    entity50.value = -61;
    
    RssiEntity * entity51 = [[RssiEntity alloc] init];
    entity51.number = 51;
    entity51.x = 2;
    entity51.y = 14.5;
    entity51.beacon = 3;
    entity51.value = -69;
    
    RssiEntity * entity52 = [[RssiEntity alloc] init];
    entity52.number = 52 ;
    entity52.x = 3.8;
    entity52.y = 14.5;
    entity52.beacon = 1;
    entity52.value = -70;
    
    RssiEntity * entity53 = [[RssiEntity alloc] init];
    entity53.number = 53;
    entity53.x = 3.8;
    entity53.y = 14.5;
    entity53.beacon = 2;
    entity53.value = -62;
    
    RssiEntity * entity54 = [[RssiEntity alloc] init];
    entity54.number = 54;
    entity54.x = 3.8;
    entity54.y = 14.5;
    entity54.beacon = 3;
    entity54.value = -68;
    
    RssiEntity * entity55 = [[RssiEntity alloc] init];
    entity55.number = 55 ;
    entity55.x = 2;
    entity55.y = 16.3;
    entity55.beacon = 1;
    entity55.value = -76;
    
    RssiEntity * entity56 = [[RssiEntity alloc] init];
    entity56.number = 56;
    entity56.x = 2;
    entity56.y = 16.3;
    entity56.beacon = 2;
    entity56.value = -57;
    
    RssiEntity * entity57 = [[RssiEntity alloc] init];
    entity57.number = 57;
    entity57.x = 2;
    entity57.y = 16.3;
    entity57.beacon = 3;
    entity57.value = -72;
    
    RssiEntity * entity58 = [[RssiEntity alloc] init];
    entity58.number = 58 ;
    entity58.x = 3.8;
    entity58.y = 16.3;
    entity58.beacon = 1;
    entity58.value = -73;
    
    RssiEntity * entity59 = [[RssiEntity alloc] init];
    entity59.number = 59;
    entity59.x = 3.8;
    entity59.y = 16.3;
    entity59.beacon = 2;
    entity59.value = -64;
    
    RssiEntity * entity60 = [[RssiEntity alloc] init];
    entity60.number = 60;
    entity60.x = 3.8;
    entity60.y = 16.3;
    entity60.beacon = 3;
    entity60.value = -68;
    
    RssiEntity * entity61 = [[RssiEntity alloc] init];
    entity61.number = 61 ;
    entity61.x = 2;
    entity61.y = 17.6;
    entity61.beacon = 1;
    entity61.value = -77;
    
    RssiEntity * entity62 = [[RssiEntity alloc] init];
    entity62.number = 62;
    entity62.x = 2;
    entity62.y = 17.6;
    entity62.beacon = 2;
    entity62.value = -59;
    
    RssiEntity * entity63 = [[RssiEntity alloc] init];
    entity63.number = 63;
    entity63.x = 2;
    entity63.y = 17.6;
    entity63.beacon = 3;
    entity63.value = -75;
    
    RssiEntity * entity64 = [[RssiEntity alloc] init];
    entity64.number = 64 ;
    entity64.x = 3.8;
    entity64.y = 17.6;
    entity64.beacon = 1;
    entity64.value = -74;
    
    RssiEntity * entity65 = [[RssiEntity alloc] init];
    entity65.number = 65;
    entity65.x = 3.8;
    entity65.y = 17.6;
    entity65.beacon = 2;
    entity65.value = -65;
    
    RssiEntity * entity66 = [[RssiEntity alloc] init];
    entity66.number = 66;
    entity66.x = 3.8;
    entity66.y = 17.6;
    entity66.beacon = 3;
    entity66.value = -72;

    [dataBaseHandle insertDataWithKeyValues:entity1];
    [dataBaseHandle insertDataWithKeyValues:entity2];
    [dataBaseHandle insertDataWithKeyValues:entity3];
    [dataBaseHandle insertDataWithKeyValues:entity4];
    [dataBaseHandle insertDataWithKeyValues:entity5];
    [dataBaseHandle insertDataWithKeyValues:entity6];
    [dataBaseHandle insertDataWithKeyValues:entity7];
    [dataBaseHandle insertDataWithKeyValues:entity8];
    [dataBaseHandle insertDataWithKeyValues:entity9];
    [dataBaseHandle insertDataWithKeyValues:entity10];
    [dataBaseHandle insertDataWithKeyValues:entity11];
    [dataBaseHandle insertDataWithKeyValues:entity12];
    [dataBaseHandle insertDataWithKeyValues:entity13];
    [dataBaseHandle insertDataWithKeyValues:entity14];
    [dataBaseHandle insertDataWithKeyValues:entity15];
    [dataBaseHandle insertDataWithKeyValues:entity16];
    [dataBaseHandle insertDataWithKeyValues:entity17];
    [dataBaseHandle insertDataWithKeyValues:entity18];
    [dataBaseHandle insertDataWithKeyValues:entity19];
    [dataBaseHandle insertDataWithKeyValues:entity20];
    [dataBaseHandle insertDataWithKeyValues:entity21];
    [dataBaseHandle insertDataWithKeyValues:entity22];
    [dataBaseHandle insertDataWithKeyValues:entity23];
    [dataBaseHandle insertDataWithKeyValues:entity24];
    [dataBaseHandle insertDataWithKeyValues:entity25];
    [dataBaseHandle insertDataWithKeyValues:entity26];
    [dataBaseHandle insertDataWithKeyValues:entity27];
    [dataBaseHandle insertDataWithKeyValues:entity28];
    [dataBaseHandle insertDataWithKeyValues:entity29];
    [dataBaseHandle insertDataWithKeyValues:entity30];
    [dataBaseHandle insertDataWithKeyValues:entity31];
    [dataBaseHandle insertDataWithKeyValues:entity32];
    [dataBaseHandle insertDataWithKeyValues:entity33];
    [dataBaseHandle insertDataWithKeyValues:entity34];
    [dataBaseHandle insertDataWithKeyValues:entity35];
    [dataBaseHandle insertDataWithKeyValues:entity36];
    [dataBaseHandle insertDataWithKeyValues:entity37];
    [dataBaseHandle insertDataWithKeyValues:entity38];
    [dataBaseHandle insertDataWithKeyValues:entity39];
    [dataBaseHandle insertDataWithKeyValues:entity40];
    [dataBaseHandle insertDataWithKeyValues:entity41];
    [dataBaseHandle insertDataWithKeyValues:entity42];
    [dataBaseHandle insertDataWithKeyValues:entity43];
    [dataBaseHandle insertDataWithKeyValues:entity44];
    [dataBaseHandle insertDataWithKeyValues:entity45];
    [dataBaseHandle insertDataWithKeyValues:entity46];
    [dataBaseHandle insertDataWithKeyValues:entity47];
    [dataBaseHandle insertDataWithKeyValues:entity48];
    [dataBaseHandle insertDataWithKeyValues:entity49];
    [dataBaseHandle insertDataWithKeyValues:entity50];
    [dataBaseHandle insertDataWithKeyValues:entity51];
    [dataBaseHandle insertDataWithKeyValues:entity52];
    [dataBaseHandle insertDataWithKeyValues:entity53];
    [dataBaseHandle insertDataWithKeyValues:entity54];
    [dataBaseHandle insertDataWithKeyValues:entity55];
    [dataBaseHandle insertDataWithKeyValues:entity56];
    [dataBaseHandle insertDataWithKeyValues:entity57];
    [dataBaseHandle insertDataWithKeyValues:entity58];
    [dataBaseHandle insertDataWithKeyValues:entity59];
    [dataBaseHandle insertDataWithKeyValues:entity60];
    [dataBaseHandle insertDataWithKeyValues:entity61];
    [dataBaseHandle insertDataWithKeyValues:entity62];
    [dataBaseHandle insertDataWithKeyValues:entity63];
    [dataBaseHandle insertDataWithKeyValues:entity64];
    [dataBaseHandle insertDataWithKeyValues:entity65];
    [dataBaseHandle insertDataWithKeyValues:entity66];
    
    //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-69];
    //NSLog(@"%@", result);
    //[dataBaseHandle selectAllKeyValues];
    
    // Update Data
    //[dataBaseHandle updateRssi:-80 x_value:100 y_value:321];
    //[dataBaseHandle updateRssi:-90 x_value:200 y_value:421 ];

    // Delete one of data
    //[dataBaseHandle deleteOneRssi:100 y_value:321];
    
    // Delete the table
    //[dataBaseHandle dropTable];

    // Do any additional setup after loading the view, typically from a nib.
//    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(182, 30, 10, 10)];
//    view2.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view2];
//    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(49, 770, 10, 10)];
//    view3.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view3];
//    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
//    view4.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view4];
    
    UIButton * button1 = [[UIButton alloc]initWithFrame:CGRectMake(150, 100, 90, 90)];
    button1.backgroundColor = [UIColor greenColor];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton * button2 = [[UIButton alloc]initWithFrame:CGRectMake(150, 300, 90, 90)];
    button2.backgroundColor = [UIColor greenColor];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton * button3 = [[UIButton alloc]initWithFrame:CGRectMake(150, 500, 90, 90)];
    button3.backgroundColor = [UIColor greenColor];
    [button3 addTarget:self action:@selector(click3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];

    //bluetooth init
    NSLog(@"viewDidLoad");
    peripheralDataArray = [[NSMutableArray alloc] init];
    //Initialize BabyBluetooth library
    baby = [BabyBluetooth shareBabyBluetooth];
    
    //initialize triangulation calculator
    triangulationCalculator = [[TriangulationCalculator alloc]init];
    
    //directly use without waiting for CBCentralManagerStatePoweredOn
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

- (void)click1 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);

    PowerLevel = 20;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(182, 300, 10, 10)];
    view1.backgroundColor = [UIColor greenColor];
    //UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    //[view1 addSubview:imageView];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

- (void)click2 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    PowerLevel = 30;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(182, 300, 10, 10)];
    view1.backgroundColor = [UIColor orangeColor];
    //UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    //[view1 addSubview:imageView];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

- (void)click3 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    PowerLevel = 50;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(182, 300, 10, 10)];
    view1.backgroundColor = [UIColor redColor];
    //UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    //[view1 addSubview:imageView];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

#pragma mark -Bluetooth config and control

//Bluetooth Delegate setting
-(void)babyDelegate{

    __weak typeof(self) weakSelf = self;
    // database opened
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"Rssi2DB"];

    //Store previous two rssi values
    static int prev_rssi1 = 0;
    static int prevprev_rssi1 = 0;
    static int prev_rssi2 = 0;
    static int prevprev_rssi2 = 0;
    static int prev_rssi3 = 0;
    static int prevprev_rssi3 = 0;
    
    //Store avarge rssi values
    static int avag_rssi_one = 0;
    static int avag_rssi_two = 0;
    static int avag_rssi_three = 0;
    static int ignore_count = 0;

    //Store distance values
    static float distance_one = 0;
    static float distance_two = 0;
    static float distance_three = 0;

    static NSMutableArray *rssi_array_one;
    rssi_array_one = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_two;
    rssi_array_two = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_three;
    rssi_array_three = [[NSMutableArray alloc] init];
    static int flag = 0;
    
    //Handle Delegate
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Searching for different BrtBeacon

        //NSLog(@"%@",peripheral.name);
        if ([peripheral.name isEqual:@"BrtBeacon01"]) {
            if (ignore_count > 50 && [RSSI intValue] != 127) {
                
                if ( [rssi_array_one count] < PowerLevel ) {
                    [rssi_array_one addObject:RSSI];
                    //NSLog(@"RSSI:%@", RSSI);
                }
                else {
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        container = container + [[rssi_array_one objectAtIndex:i] intValue];
                    }
                    float u = container/PowerLevel;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_one objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow(container2/(PowerLevel-1),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        if ([[rssi_array_one objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_one objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_one objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_one = rssi_sum / rssi_count;
                    
                    //Moving average Algorithm
                    if (prev_rssi1 == 0 || prevprev_rssi1 == 0) {
                        prev_rssi1 = avag_rssi_one;
                        prevprev_rssi1 = avag_rssi_one;
                    }
                    avag_rssi_one = (avag_rssi_one + prev_rssi1 + prevprev_rssi1)/3;
                    prevprev_rssi1 = prev_rssi1;
                    prev_rssi1 = avag_rssi_one;
                    
                    //Translate RSSI value into distance
                    double txPower = -50;
                    
//                    if (avag_rssi_one == 0) {
//                        distance_one = -1.0;
//                    }
//                    double ratio = avag_rssi_one*1.0/txPower;
//                    if (ratio < 1.0) {
//                        distance_one = pow(ratio,10);
//                    }
//                    else {
//                        distance_one = (0.89976)*pow(ratio,7.7095) + 0.111;
//                    }
                    distance_one = pow(10,((txPower - avag_rssi_one)/22));
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_one, distance_one);
                    [rssi_array_one removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon02"]) {
             if (ignore_count > 50 && [RSSI intValue] != 127) {

                 if ( [rssi_array_two count] < PowerLevel ) {
                     [rssi_array_two addObject:RSSI];
                     //NSLog(@"RSSI:%@", RSSI);
                 }
                 else {
                     NSUInteger count;
                     NSUInteger i;
                     float container = 0;
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         container = container + [[rssi_array_two objectAtIndex:i] intValue];
                     }
                     float u = container/PowerLevel;
                     float container2 = 0;
                     
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         double temp = 0.0;
                         temp = [[rssi_array_two objectAtIndex:i] doubleValue] - u;
                         //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                         container2 = container2 + pow(temp,2);
                     }
                     float v = pow((container2/(PowerLevel-1)),0.5);
                     //NSLog(@"u:%.lf  v:%.1f", u, v);
                     
                     float rssi_sum = 0;
                     float rssi_count = 0;
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         if ([[rssi_array_two objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_two objectAtIndex:i] doubleValue] > (u-v))
                         {
                             //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                             rssi_sum = rssi_sum + [[rssi_array_two objectAtIndex:i] doubleValue];
                             rssi_count = rssi_count + 1;
                         }
                     }
                     avag_rssi_two = rssi_sum / rssi_count;
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     //Moving average Algorithm
                     if (prev_rssi2 == 0 || prevprev_rssi2 == 0) {
                         prev_rssi2 = avag_rssi_two;
                         prevprev_rssi2 = avag_rssi_two;
                     }
                     avag_rssi_two = (avag_rssi_two + prev_rssi2 + prevprev_rssi2)/3;
                     prevprev_rssi2 = prev_rssi2;
                     prev_rssi2 = avag_rssi_two;
                     
                     //Translate RSSI value into distance
                     double txPower = -54;

                     distance_two = pow(10,((txPower - avag_rssi_two)/22));
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     [rssi_array_two removeAllObjects];
                     flag = 1;
                 }
             }
             else {
                 ignore_count = ignore_count + 1;
             }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon03"]) {

            if (ignore_count > 50 && [RSSI intValue] != 127) {
                if ( [rssi_array_three count] < PowerLevel ) {
                    [rssi_array_three addObject:RSSI];
                   // NSLog(@"RSSI:%@", RSSI);
                }
                else {
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        container = container + [[rssi_array_three objectAtIndex:i] intValue];
                    }
                    float u = container/PowerLevel;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_three objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/(PowerLevel-1)),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        if ([[rssi_array_three objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_three objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_three objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_three = rssi_sum / rssi_count;
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);
                    //Moving average Algorithm
                    if (prev_rssi3 == 0 || prevprev_rssi3 == 0) {
                        prev_rssi3 = avag_rssi_three;
                        prevprev_rssi3 = avag_rssi_three;
                    }
                    avag_rssi_three = (avag_rssi_three + prev_rssi3 + prevprev_rssi3)/3;
                    prevprev_rssi3 = prev_rssi3;
                    prev_rssi3 = avag_rssi_three;
                    
                    //Translate RSSI value into distance
                    double txPower = -55;

                    distance_three = pow(10,((txPower - avag_rssi_three)/22));
                    NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);

                    [rssi_array_three removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }

        //ignore the first several data (no coordinate)
        if (flag != 0 && avag_rssi_one !=0 && avag_rssi_two != 0 && avag_rssi_three != 0) {
            //Trilangulation Algorithm
            CGPoint position = [triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one beaconDis2:distance_two beaconDis3:distance_three];
            //NSLog(@" Beacon1: %d, Beacon2: %d, Beacon3: %d With Position = (%f, %f) ", avag_rssi_one, avag_rssi_two, avag_rssi_three, position.x, position.y);
            NSLog(@" Beacon1: %d and %.2f, Beacon2: %d and %.2f, Beacon3: %d and %.2f", avag_rssi_one, distance_one, avag_rssi_two, distance_two, avag_rssi_three, distance_three);
            
            float finger_x = 0;
            float finger_y = 0;
            
            //if the lowest Power Level is chose, Fingerprinting will not be implemented
            if (PowerLevel != 20) {
                //Fingerprinting Algorithm
                NSMutableArray * xy_one = [dataBaseHandle selectOneByrssi:1 value:avag_rssi_one];
                NSMutableArray * xy_two = [dataBaseHandle selectOneByrssi:2 value:avag_rssi_two];
                NSMutableArray * xy_three = [dataBaseHandle selectOneByrssi:3 value:avag_rssi_three];
                
                NSMutableDictionary * xy_dict = [NSMutableDictionary dictionary];
                
                for (NSString *string in xy_one) {
                    //if xy is already in the dictionary
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_one + 127) forKey:string];
                    }
                    //if xy is not in the dictionary
                    else {
                        [xy_dict setObject:@(avag_rssi_one) forKey:string];
                    }
                }
                for (NSString *string in xy_two) {
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_two + 127) forKey:string];
                    }
                    else {
                        [xy_dict setObject:@(avag_rssi_two) forKey:string];
                    }
                }
                for (NSString *string in xy_three) {
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_three + 127) forKey:string];
                    }
                    else {
                        [xy_dict setObject:@(avag_rssi_three) forKey:string];
                    }
                }
                //NSLog(@"%@", xy_dict);
                
                NSArray * Sorted_XY = [xy_dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    if ([obj1 integerValue] > [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    if ([obj1 integerValue] < [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                
                NSArray * Seperated_XY = [[Sorted_XY firstObject] componentsSeparatedByString:@" "];
                finger_x = [[Seperated_XY objectAtIndex:0] floatValue];
                finger_y = [[Seperated_XY objectAtIndex:1] floatValue];
                
                //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-65];
                NSLog(@"xyValue: %.1f and %.1f", finger_x, finger_y);
            }

            //Weighted fused results from both Algorithm
            float weighted_x;
            float weighted_y;
            if (finger_x != 0 && finger_y != 0){
                weighted_x = (70*finger_x/100) + (30*position.x/100);
                weighted_y = (70*finger_y/100) + (30*position.y/100);
            }
            else {
                weighted_x = position.x;
                weighted_y = position.y;
            }

            if (position.x != 0) {
                //convert to pixels
                NSLog(@"WEIGHTED xy: %.1f and %.1f", weighted_x, weighted_y);
                //for iphone_7plus
                float x = weighted_x*76.8;  //384/5
                float y = weighted_y*38.068 + 39; //670/17.6
                //NSLog(@"weighted pixel: %.1f and %.1f", x, y);
                //for iphone 7 plus
                //float x = weighted_x * 45.1765;
                //float y= weighted_y * 42.9487 + 39;
                for (UIView *i in weakSelf.view.subviews){
                    if([i isKindOfClass:[UIView class]]){
                        UILabel *newLbl = (UILabel *)i;
                        if(newLbl.tag == 1){
                            //change the position of view1
                            i.center = CGPointMake(x, y);
                        }//if
                    }//if
                }//for loop
            }//if
            //set flag back to zero
            flag = 0;
        }
    }];
    
    
    //Set searching filter
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Only search device with this prefix
        if ([peripheralName hasPrefix:@"BrtBeacon"] ) {
            return YES;
        }
        return NO;
    }];
    
    /*
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    */
    
    /*
    //Ignore same Peripherals found
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //connect device->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
