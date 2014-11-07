//
//  ObservationFetchService.m
//  mage-ios-sdk
//
//  Created by William Newman on 8/22/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import "ObservationFetchService.h"
#import "Observation+helper.h"
#import "Layer+helper.h"
#import "Form.h"
#import "HttpManager.h"

NSString * const kObservationFetchFrequencyKey = @"observationFetchFrequency";

@interface ObservationFetchService ()
    @property (nonatomic) NSTimeInterval interval;
    @property (nonatomic, strong) NSTimer* observationFetchTimer;
@end

@implementation ObservationFetchService

- (id) init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _interval = [[defaults valueForKey:kObservationFetchFrequencyKey] doubleValue];
        
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:kObservationFetchFrequencyKey
                                                   options:NSKeyValueObservingOptionNew
                                                   context:NULL];
    }
	
	return self;
}

- (void) start {
    [self stop];
    
    HttpManager *http = [HttpManager singleton];
    NSOperation *layerPullOperation = [Layer operationToPullLayers:^(BOOL success) {
        if (success) {
            NSOperation* formPullOp = [Form operationToPullForm:^(BOOL success) {
                if (success) {
                    // Layers and Form pulled, lets start the observation fetch
                    [self pullObservations];
                } else {
                    // TODO error
                }
            }];
            
            [http.manager.operationQueue addOperation:formPullOp];
        } else {
            // TODO error
        }
    }];
    
    [http.manager.operationQueue addOperation:layerPullOperation];
}

- (void) scheduleTimer {
    _observationFetchTimer = [NSTimer timerWithTimeInterval:_interval target:self selector:@selector(onTimerFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_observationFetchTimer forMode:NSRunLoopCommonModes];
}

- (void) onTimerFire {
    [self pullObservations];
}

- (void) pullObservations {
    NSOperation *observationFetchOperation = [Observation operationToPullObservations:^(BOOL success) {
        [self scheduleTimer];
    }];
    
    [[HttpManager singleton].manager.operationQueue addOperation:observationFetchOperation];
}

- (void) stop {
    if ([_observationFetchTimer isValid]) {
        [_observationFetchTimer invalidate];
        _observationFetchTimer = nil;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    _interval = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
    [self start];
}

@end
