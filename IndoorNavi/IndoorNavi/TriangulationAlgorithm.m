#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TriangulationAlgorithm.h"

@implementation TriangulationCalculator


- (instancetype)init
{
    self = [super init];
    if (self) {
        //initialize the positions of the 5 beacons
        //beaconPosition[0].h=0;
        //beaconPosition[0].v=0;
        beaconPosition[0].x=0;
        beaconPosition[0].y=0;
        beaconPosition[1].x=0;
        beaconPosition[1].y=17.6;
        beaconPosition[2].x=5;
        beaconPosition[2].y=8.7;
    }
    return self;
}

- (CGPoint) calculatePosition: (int)beaconId1 beaconId2:(int)beaconId2 beaconId3:(int)beaconId3 beaconDis1:(float)beaconDis1 beaconDis2:(float)beaconDis2 beaconDis3:(float)beaconDis3
{
    CGPoint positionCoordinate = CGPointMake(0,0);
    
    float BeaconDistanceOne   = beaconDis1;
    float BeaconDistanceTwo   = beaconDis2;
    float BeaconDistanceThree = beaconDis3;
    
    
    
    float beaconOneCoordinateX      = beaconPosition[0].x;
    float beaconOneCoordinateY      = beaconPosition[0].y;
    

    float beaconTwoCoordinateX      = beaconPosition[1].x;
    float beaconTwoCoordinateY      = beaconPosition[1].y;
    
    float beaconThreeCoordinateX    = beaconPosition[2].x;
    float beaconThreeCoordinateY    = beaconPosition[2].y;
    
    
    //Calculating Distances with Factor (cm to Pixel)   *1 = Factor cm to Pixel
    //BeaconDistanceOne   = (BeaconDistanceOne * 100)     *1;
    //BeaconDistanceTwo   = (BeaconDistanceTwo * 100)     *1;
    //BeaconDistanceThree = (BeaconDistanceThree * 100)   *1;
    
//    if ((BeaconDistanceOne + BeaconDistanceTwo) <= 330 || (BeaconDistanceTwo + BeaconDistanceThree) <= 300 || (BeaconDistanceOne+ BeaconDistanceThree) <= 300)
//    {
//        positionCoordinate.x = 0;
//        positionCoordinate.y = 0;
//        return positionCoordinate;
//    }
    
    //Calculating Delta Alpha Beta
    float Delta   = 4 * ((beaconOneCoordinateX - beaconTwoCoordinateX) * (beaconOneCoordinateY - beaconThreeCoordinateY) - (beaconOneCoordinateX - beaconThreeCoordinateX) * (beaconOneCoordinateY - beaconTwoCoordinateY));
    float Alpha   = (BeaconDistanceTwo * BeaconDistanceTwo) - (BeaconDistanceOne * BeaconDistanceOne) - (beaconTwoCoordinateX * beaconTwoCoordinateX) + (beaconOneCoordinateX * beaconOneCoordinateX) - (beaconTwoCoordinateY * beaconTwoCoordinateY) + (beaconOneCoordinateY * beaconOneCoordinateY);
    float Beta    = (BeaconDistanceThree * BeaconDistanceThree) - (BeaconDistanceOne * BeaconDistanceOne) - (beaconThreeCoordinateX * beaconThreeCoordinateX) + (beaconOneCoordinateX * beaconOneCoordinateX) - (beaconThreeCoordinateY * beaconThreeCoordinateY) + (beaconOneCoordinateY * beaconOneCoordinateY);
    
    
    
    //Real Calculating the Position Triletaration
    float PositionX = (1/Delta) * (2 * Alpha * (beaconOneCoordinateY - beaconThreeCoordinateY) - 2 * Beta * (beaconOneCoordinateY - beaconTwoCoordinateY));
    float PositionY = (1/Delta) * (2 * Beta * (beaconOneCoordinateX - beaconTwoCoordinateX) - 2 * Alpha * (beaconOneCoordinateX - beaconThreeCoordinateX));
    
//    NSLog(@"Method1 output is: ");
//    NSLog(@"PositionX = %f", PositionX);
//    NSLog(@"PositionY = %f", PositionY);
    
    positionCoordinate.x = PositionX;
    positionCoordinate.y = PositionY;
    
    
    float  distanceArray[] = {beaconDis1,beaconDis2,beaconDis3};
    
    CGPoint correctedCoordinate = [self applyCorrectionForPoint:positionCoordinate
                                      forBeaconDiscances:distanceArray];
    
    
//   NSLog(@"Corrected output is: ");
//   NSLog(@"PositionX = %f", correctedCoordinate.x);
//   NSLog(@"PositionY = %f", correctedCoordinate.y);
    return correctedCoordinate;
}

- (CGPoint)applyCorrectionForPoint:(CGPoint)calculatedCoordinate
forBeaconDiscances:(float *)beaconDistances
{
    // Take in consideration that the signal is the most precise when closest to a beacon.
    // find the vector for each beacon:
    CGPoint totalVector = CGPointZero;
    CGFloat weight = 0;
    for (int i = 0; i < 3; i++) {
        CGFloat
        dX = beaconPosition[i].x - calculatedCoordinate.x,
        dY = beaconPosition[i].y - calculatedCoordinate.y;
        
        CGFloat c1 = sqrt(dX*dX + dY*dY);
        CGFloat d1 = c1 - beaconDistances[i];
        CGFloat ratio = d1 / c1;
        CGFloat multiplier = 1/beaconDistances[i];
        
        totalVector.x += dX * ratio * multiplier;
        totalVector.y += dY * ratio * multiplier;
        weight += multiplier;
    }
    CGPoint coordinateWithCorrection = calculatedCoordinate;
    coordinateWithCorrection.x += totalVector.x / weight;
    coordinateWithCorrection.y += totalVector.y / weight;
    
    return coordinateWithCorrection;
}

@end
