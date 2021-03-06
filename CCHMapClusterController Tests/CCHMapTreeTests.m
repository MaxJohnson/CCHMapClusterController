//
//  CCHMapTreeTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapTree.h"
#import "CCHMapClusterControllerUtils.h"

@interface Annotation : MKPointAnnotation
@property (nonatomic, copy) NSString *id;
@end

@implementation Annotation
- (BOOL)isEqual:(id)other
{
    BOOL isEqual;
    
    if (other == self) {
        isEqual = YES;
    } else if (!other || ![other isKindOfClass:self.class]) {
        isEqual = NO;
    } else {
        isEqual = [self isEqualToStolperstein:other];
    }
    
    return isEqual;
}

- (BOOL)isEqualToStolperstein:(Annotation *)annotation
{
    return [self.id isEqualToString:annotation.id];
}

- (NSUInteger)hash
{
    return self.id.hash;
}
@end

@interface CCHMapTreeTests : XCTestCase

@property (nonatomic, strong) CCHMapTree *mapTree;

@end

@implementation CCHMapTreeTests

- (void)setUp
{
    [super setUp];
    
    self.mapTree = [[CCHMapTree alloc] initWithNodeCapacity:1 minLatitude:-85.0 maxLatitude:85.0 minLongitude:-180.0 maxLongitude:180.0];
}

- (void)testDealloc
{
    CCHMapTree *mapTree = [[CCHMapTree alloc] init];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [mapTree addAnnotations:@[annotation]];
}

- (void)testAddAnnotationsDuplicate
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    [self.mapTree addAnnotations:@[annotation0, annotation0]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
}

- (void)testAnnotationsInMapRectContainsRetain
{
    NSString *title = @"title";
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52, 13);
    @autoreleasepool {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title = title;
        
        [self.mapTree addAnnotations:@[annotation]];
    }
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)1);
    if (annotations.count > 0) {
        XCTAssertEqualObjects(title, [annotations.anyObject title]);
    }
}

- (void)testAnnotationsInMapRectEmpty
{
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)0);

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(52, 13), 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)0);
}

- (void)testAnnotationsInMapRectContains
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [self.mapTree addAnnotations:@[annotation]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)1);
    if (annotations.count > 0) {
        XCTAssertEqual(annotation, annotations.anyObject);
    }
}

- (void)testAnnotationsInMapRectContainsSamePosition
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;
    [self.mapTree addAnnotations:@[annotation0, annotation1]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)2);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation0.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)2);
    if (annotations.count > 0) {
        XCTAssertTrue([annotations containsObject:annotation0]);
        XCTAssertTrue([annotations containsObject:annotation1]);
    }
}

- (void)testAnnotationsInMapRectDoesNotContain
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [self.mapTree addAnnotations:@[annotation]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50, 10);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)0);
}

- (void)testAnnotationsInMapRectContainsSome
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(50, 10);
    [self.mapTree addAnnotations:@[annotation0, annotation1]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)2);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation1.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)1);
    if (annotations.count > 0) {
        XCTAssertEqual(annotation1, annotations.anyObject);
    }
}

- (void)testRemoveAnnotations
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(50, 10);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation1.coordinate;
    [self.mapTree addAnnotations:@[annotation0, annotation1, annotation2]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)3);

    [self.mapTree removeAnnotations:@[annotation0]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)2);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation0.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSSet *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)0);

    [self.mapTree removeAnnotations:@[annotation2]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    region = MKCoordinateRegionMakeWithDistance(annotation1.coordinate, 1000, 1000);
    mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)1);
    if (annotations.count > 0) {
        XCTAssertEqual(annotation1, annotations.anyObject);
    }

    [self.mapTree removeAnnotations:@[annotation1]];
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)0);
    region = MKCoordinateRegionMakeWithDistance(annotation1.coordinate, 1000, 1000);
    mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, (NSUInteger)0);
}

- (void)testAddRemoveAnnotationsUpdated
{
    // Add once
    Annotation *annotation0 = [[Annotation alloc] init];
    annotation0.id = @"123";
    BOOL updated = [self.mapTree addAnnotations:@[annotation0]];
    XCTAssertTrue(updated);
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    
    // Add again
    updated = [self.mapTree addAnnotations:@[annotation0]];
    XCTAssertFalse(updated);
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    
    // Add equal
    Annotation *annotation1 = [[Annotation alloc] init];
    annotation1.id = annotation0.id;
    updated = [self.mapTree addAnnotations:@[annotation1]];
    XCTAssertFalse(updated);
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)1);
    
    // Remove equal
    updated = [self.mapTree removeAnnotations:@[annotation1]];
    XCTAssertTrue(updated);
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)0);
    
    // Remove again
    updated = [self.mapTree removeAnnotations:@[annotation0]];
    XCTAssertFalse(updated);
    XCTAssertEqual(self.mapTree.annotations.count, (NSUInteger)0);
}

@end
