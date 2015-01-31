//
//  ADJDeviceUtil.h
//  Adjust
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADJActivityHandler.h"

@interface ADJDeviceUtil : NSObject

+ (BOOL)adjTrackingEnabled;
+ (NSString *)adjIdForAdvertisers;
+ (NSString *)adjFbAttributionId;
+ (NSString *)adjMacAddress;
+ (NSString *)adjDeviceType;
+ (NSString *)adjDeviceName;
+ (NSString *)adjCreateUuid;
+ (NSString *)adjVendorId;
+ (void)adjSetIad:(ADJActivityHandler *)activityHandler;

@end