//
//  BatteryManager.m
//  RCTBattery
//
//  Created by Olajide Ogundipe Jr on 9/15/15.
//

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

#import "BatteryManager.h"

@implementation BatteryManager

@synthesize bridge = _bridge;
@synthesize isPlugged;

RCT_EXPORT_MODULE();

- (instancetype)init
{
    if ((self = [super init])) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object: nil];
    }
    return self;
}

RCT_EXPORT_METHOD(updateBatteryLevel:(RCTResponseSenderBlock)callback)
{
#if TARGET_OS_SIMULATOR

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30); //dispatch after 60 second
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        // do work in the UI thread here
        [self.bridge.eventDispatcher sendAppEventWithName:@"BatteryStatus" body:@{@"isPlugged":@YES,@"level":@5}];
    });
    //
    dispatch_time_t delay2 = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45); //dispatch after 60 second
    dispatch_after(delay2, dispatch_get_main_queue(), ^(void){
        // do work in the UI thread here
        [self.bridge.eventDispatcher sendAppEventWithName:@"BatteryStatus" body:@{@"isPlugged":@YES,@"level":@75}];
    });
#endif

    callback(@[[self getBatteryStatus]]);



}

-(NSDictionary*)getBatteryStatus
{
#if TARGET_OS_SIMULATOR

    NSMutableDictionary* batteryData = [NSMutableDictionary dictionaryWithCapacity:2];
    [batteryData setObject:[NSNumber numberWithBool:0] forKey:@"isPlugged"];
    [batteryData setObject:@1 forKey:@"level"];
    return batteryData;

#else
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;

    isPlugged = FALSE;

    NSObject* currentLevel = nil;

    if (batteryState == UIDeviceBatteryStateCharging) {
        currentLevel = [NSNumber numberWithFloat:(batteryLevel * 100)];
        isPlugged = TRUE;
    }

    if(batteryState == UIDeviceBatteryStateFull){
        currentLevel = [NSNumber numberWithFloat:(batteryLevel * 100)];
        isPlugged = TRUE;
    }

    if(batteryState == UIDeviceBatteryStateUnplugged){
        currentLevel = [NSNumber numberWithFloat:(batteryLevel * 100)];
    }

    if(batteryState == UIDeviceBatteryStateUnknown || batteryState == -1.0){
        currentLevel = [NSNull null];
    } else {
        currentLevel = [NSNumber numberWithFloat:(batteryLevel * 100)];
    }

    NSMutableDictionary* batteryData = [NSMutableDictionary dictionaryWithCapacity:2];
    [batteryData setObject:[NSNumber numberWithBool:isPlugged] forKey:@"isPlugged"];
    [batteryData setObject:currentLevel forKey:@"level"];
    return batteryData;
#endif
}

-(void)batteryLevelChanged:(NSNotification*)notification {
    
    NSDictionary* batteryData = [self getBatteryStatus];
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"BatteryStatus" body:batteryData];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
