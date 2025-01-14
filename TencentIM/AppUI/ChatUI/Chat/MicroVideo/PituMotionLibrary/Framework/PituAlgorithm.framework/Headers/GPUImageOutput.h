#import <UIKit/UIKit.h>

#import "GPUImageOpenGLESContext.h"
#import "GLProgram.h"
#import "HFGLTextureWrapper.h"

void runOnMainQueueWithoutDeadlocking(void (^block)(void));

struct _Image;
@class GPUImageMovieWriter;

@interface GPUImageOutput : NSObject
{
    NSMutableArray *targets, *targetTextureIndices;
    
    HFGLTextureWrapper *outputTexture;
    CGSize inputTextureSize, cachedMaximumOutputSize;
    id<GPUImageInput> targetToIgnoreForUpdates;
    
    BOOL overrideInputSize;
    
    
    int textureWidth;
    int textureHeight;
}

@property(readwrite, nonatomic) BOOL shouldSmoothlyScaleOutput;
@property(readwrite, nonatomic) BOOL shouldIgnoreUpdatesToThisTarget;
@property(readwrite, nonatomic, retain) GPUImageMovieWriter *audioEncodingTarget;

// Managing targets
- (void)setInputTextureForTarget:(id<GPUImageInput>)target atIndex:(NSInteger)inputTextureIndex;
- (void)addTarget:(id<GPUImageInput>)newTarget;
- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
- (void)removeTarget:(id<GPUImageInput>)targetToRemove;
- (void)removeAllTargets;
- (void)newImageReady;

// Manage the output texture
- (void)initializeOutputTexture;
- (void)deleteOutputTexture;
- (void)forceProcessingAtSize:(CGSize)frameSize;
- (CGSize)getOutputSize;
- (HFGLTextureWrapper *)getOutputTexture;

// Still image processing
- (UIImage *)imageFromCurrentlyProcessedOutput;
- (UIImage *)imageFromCurrentlyProcessedOutputWithOrientation:(UIImageOrientation)imageOrientation;
- (UIImage *)imageByFilteringImage:(UIImage *)imageToFilter;
+ (void)finishGPUOperations;
- (unsigned char*)pixelFromCurrentlyProcessedOutput;
- (struct _Image *)internImageFromCurrentlyProcessedOutput;

@end
