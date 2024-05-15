//
//  ARViewController.m
//  ARSticker
//
//  Created by Jinwoo Kim on 5/15/24.
//

#import "ARViewController.h"
#import <ARKit/ARKit.h>
#import "ARSticker-Swift.h"

__attribute__((objc_direct_members))
@interface ARViewController () <ARSessionDelegate>
@property (retain, readonly, nonatomic) ARSession *session;
@property (retain, readonly, nonatomic, nullable, direct) UIImage *anchorImage;
@property (retain, readonly, nonatomic ,nullable, direct) UIImage *stickerImage;
@end

@implementation ARViewController

@synthesize session = _session;

- (instancetype)initWithAnchorImage:(UIImage *)anchorImage stickerImage:(UIImage *)stickerImage {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _anchorImage = [anchorImage retain];
        _stickerImage = [stickerImage retain];
    }
    
    return self;
}

- (void)dealloc {
    [_session release];
    [_anchorImage release];
    [_stickerImage release];
    [super dealloc];
}

- (void)loadView {
    self.view = (__kindof UIView *)makeARViewWithSession(self.session);
}


- (ARSession *)session {
    if (auto session = _session) return session;
    
    ARSession *session = [ARSession new];
    session.delegate = self;
    
    ARReferenceImage *anchorReferenceImage = [[ARReferenceImage alloc] initWithCGImage:_anchorImage.CGImage orientation:kCGImagePropertyOrientationUp physicalWidth:0.5];
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.detectionImages = [NSSet setWithObject:anchorReferenceImage];
    [anchorReferenceImage release];
    
    [session runWithConfiguration:configuration];
    [configuration release];
    
    _session = [session retain];
    return [session autorelease];
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<__kindof ARAnchor *> *)anchors {
    for (ARAnchor *anchor in anchors) {
        setupAddedAnchor(anchor, _stickerImage, (ARView *)self.view);
    }
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<__kindof ARAnchor *> *)anchors {
    for (ARAnchor *anchor in anchors) {
        removeAnchor(anchor, (ARView *)self.view);
    }
}

@end
