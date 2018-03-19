#ifndef TriangulationAlgorithm_h
#define TriangulationAlgorithm_h


@interface TriangulationCalculator:NSObject
{
    //NSMutableArray *beaconPositionX;
    //NSMutableArray *beaconPositionY;
    CGPoint beaconPosition [3];
    //double beaconPositionY[3];
    
}
- (CGPoint) calculatePosition:(int)beaconId1 beaconId2:(int)beaconId2 beaconId3:(int)beaconId3 beaconDis1:(float)beaconDis1 beaconDis2:(float)beaconDis2 beaconDis3:(float)beaconDis3;
- (CGPoint)applyCorrectionForPoint:(CGPoint)calculatedCoordinate
                  forBeaconDiscances:(float *)beaconDistances;

@end

#endif /* TriangulationAlgorithm_h */
