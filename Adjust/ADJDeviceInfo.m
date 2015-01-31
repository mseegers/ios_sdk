//
//  ADJDeviceInfo.m
//  adjust
//
//  Created by Pedro Filipe on 17/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJDeviceInfo.h"
#import "ADJDeviceUtil.h"
#import "ADJStringUtil.h"
#import "ADJUtil.h"

static NSString * const kWiFi   = @"WIFI";
static NSString * const kWWAN   = @"WWAN";

@implementation ADJDeviceInfo

+ (ADJDeviceInfo *) deviceInfoWithSdkPrefix:(NSString *)sdkPrefix {
    return [[ADJDeviceInfo alloc] initWithSdkPrefix:sdkPrefix];
}

- (id) initWithSdkPrefix:(NSString *)sdkPrefix {
    self = [super init];
    if (self == nil) return nil;

    NSString *macAddress = [ADJDeviceUtil adjMacAddress];
    NSString *macShort = [ADJStringUtil adjRemoveColons:macAddress];
    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;

    self.macSha1          = [ADJStringUtil adjSha1:macAddress];
    self.macShortMd5      = [ADJStringUtil adjMd5:macShort];
    self.trackingEnabled  = [ADJDeviceUtil adjTrackingEnabled];
    self.idForAdvertisers = [ADJDeviceUtil adjIdForAdvertisers];
    self.fbAttributionId  = [ADJDeviceUtil adjFbAttributionId];
    self.vendorId         = [ADJDeviceUtil adjVendorId];
    self.bundeIdentifier  = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    self.bundleVersion    = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    self.languageCode     = [locale objectForKey:NSLocaleLanguageCode];
    self.countryCode      = [locale objectForKey:NSLocaleCountryCode];
    self.osName           = @"ios";
    self.deviceType       = [ADJDeviceUtil adjDeviceType];
    self.deviceName       = [ADJDeviceUtil adjDeviceName];
    self.systemVersion    = device.systemVersion;

    if (sdkPrefix == nil) {
        self.clientSdk        = ADJUtil.clientSdk;
    } else {
        self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, ADJUtil.clientSdk];
    }

    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    ADJDeviceInfo* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.macSha1 = [self.macSha1 copyWithZone:zone];
        copy.macShortMd5 = [self.macShortMd5 copyWithZone:zone];
        copy.idForAdvertisers = [self.idForAdvertisers copyWithZone:zone];
        copy.fbAttributionId = [self.fbAttributionId copyWithZone:zone];
        copy.trackingEnabled = self.trackingEnabled;
        copy.vendorId = [self.vendorId copyWithZone:zone];
        copy.pushToken = [self.pushToken copyWithZone:zone];
        copy.clientSdk = [self.clientSdk copyWithZone:zone];
        copy.bundeIdentifier = [self.bundeIdentifier copyWithZone:zone];
        copy.bundleVersion = [self.bundleVersion copyWithZone:zone];
        copy.deviceType = [self.deviceType copyWithZone:zone];
        copy.deviceName = [self.deviceName copyWithZone:zone];
        copy.osName = [self.osName copyWithZone:zone];
        copy.systemVersion = [self.systemVersion copyWithZone:zone];
        copy.languageCode = [self.languageCode copyWithZone:zone];
        copy.countryCode = [self.countryCode copyWithZone:zone];
        copy.networkType = [self.networkType copyWithZone:zone];
        copy.mobileCountryCode = [self.mobileCountryCode copyWithZone:zone];
        copy.mobileNetworkCode = [self.mobileNetworkCode copyWithZone:zone];
    }
    
    return copy;
}

@end
