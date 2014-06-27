//
//  Location+helper.h
//  mage-ios-sdk
//
//  Created by Billy Newman on 6/19/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import "Location.h"
#import "Geometry.h"

@interface Location (helper)

+ (Location *) locationForJson: (NSDictionary *) json inManagedObjectContext: (NSManagedObjectContext *) context;

- (void) updateLocationsForUserId:(NSString *) userId locations: (NSArray *) locations;

@property (nonatomic, retain) Geometry* geometry;

@end
