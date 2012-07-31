//
//  Listing.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef enum {
    ListingCategoryItem            = 1 << 0,
    ListingCategoryFavor           = 1 << 1,
    ListingCategoryRide            = 1 << 2,
    ListingCategoryAccommodation   = 1 << 3,
    ListingCategoryAny             = 0
} ListingCategory;

typedef enum {
    ListingTypeOffer               = 1 << 0,
    ListingTypeRequest             = 1 << 1,
    ListingTypeAny                 = 0
} ListingType;

typedef enum {
    ListingStatusOpen              = 1 << 0,
    ListingStatusClosed            = 1 << 1,
    ListingStatusAny               = 0
} ListingStatus;

@class Location;
@class User;

@interface Listing : NSObject <MKAnnotation>

@property (assign) NSInteger listingId;
@property (nonatomic, copy) NSString *title;
@property (strong) NSString *description;

@property (assign) ListingCategory category;
@property (assign) ListingType type;
@property (strong) NSString *shareType;
@property (strong) NSArray *tags;

@property (strong) NSURL *thumbnailURL;
@property (strong) NSArray *imageURLs;

@property (strong) UIImage *image;
@property (strong) NSData *imageData;

@property (strong) Location *location;
@property (strong) Location *destination;

@property (strong) User *author;
@property (strong) NSDate *createdAt;
@property (strong) NSDate *updatedAt;
@property (strong) NSDate *validUntil;
@property (assign) ListingStatus status;

@property (assign) NSInteger numberOfTimesViewed;
@property (assign) NSInteger numberOfComments;
@property (strong) NSString *visibility;

@property (strong) NSArray *comments;

- (CLLocationCoordinate2D)coordinate;

- (NSDictionary *)asJSON;

+ (NSString *)stringFromType:(ListingType)type;
+ (NSString *)stringFromCategory:(ListingCategory)category;
+ (UIImage *)iconForCategory:(ListingCategory)category;

+ (Listing *)listingFromDict:(NSDictionary *)dict;
+ (NSArray *)listingsFromArrayOfDicts:(NSArray *)dicts;

NSComparisonResult compareListingsByDate(id object1, id object2, void *context);

@end
