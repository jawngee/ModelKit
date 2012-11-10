//
//  MKitC0003GeoPointTestCases.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/10/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0003GeoPointTestCases.h"
#import "JSONKit.h"
#import "TestVenueModel.h"
#import "MKitModelQuery.h"
#import "MKitModelContext.h"

@implementation MKitTC0003GeoPointTestCases

-(void)setUp
{
    // load up results from foursquare
    NSString *jsonFile=[[NSBundle bundleForClass:[self class]] pathForResource:@"venues" ofType:@"json"];
    NSDictionary *v=[[NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];
    NSMutableArray *venues=v[@"response"][@"venues"];
    for(NSDictionary *d in venues)
    {
        TestVenueModel *m=[TestVenueModel instanceWithObjectId:d[@"id"]];
        m.location=[MKitGeoPoint geoPointWithLatitude:[d[@"location"][@"lat"] doubleValue] andLongitude:[d[@"location"][@"lng"] doubleValue]];
        m.name=d[@"name"];
        
        // foursquare distances are stored in meters
        m.distance=[d[@"location"][@"distance"] doubleValue]/1000.0;
    }
}

-(void)tearDown
{
    [MKitModelContext clearAllContexts];
}

-(void)testDistanceQuery
{
    MKitModelQuery *q=[TestVenueModel query];
    [q key:@"location" withinDistance:150/1000.0 ofPoint:[MKitGeoPoint geoPointWithLatitude:10.76529079 andLongitude:106.69060779]];
    NSDictionary *result=[q execute:nil];
    
    q=[TestVenueModel query];
    [q key:@"distance" condition:KeyLessThanEqual value:@(150.0/1000.0)];
    NSDictionary *result2=[q execute:nil];
    
    STAssertTrue([[result objectForKey:MKitQueryItemCountKey] integerValue]>0, @"No results found");
    STAssertTrue([[result objectForKey:MKitQueryItemCountKey] integerValue]==[[result2 objectForKey:MKitQueryItemCountKey] integerValue], @"Result count does not match");

    q=[TestVenueModel query];
    [q key:@"location" withinDistance:250/1000.0 ofPoint:[MKitGeoPoint geoPointWithLatitude:10.76529079 andLongitude:106.69060779]];
    result=[q execute:nil];
    
    q=[TestVenueModel query];
    [q key:@"distance" condition:KeyLessThanEqual value:@(250.0/1000.0)];
    result2=[q execute:nil];
    
    STAssertTrue([[result objectForKey:MKitQueryItemCountKey] integerValue]>0, @"No results found");
    STAssertTrue([[result objectForKey:MKitQueryItemCountKey] integerValue]==[[result2 objectForKey:MKitQueryItemCountKey] integerValue], @"Result count does not match");
}

@end
