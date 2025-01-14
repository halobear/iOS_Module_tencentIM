#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>

@class HFGLTextureWrapper;

@interface GPUImageOpenGLESContext : NSObject
{
    EAGLContext *_context;
}

@property(readonly, retain) EAGLContext *context;
@property (assign) BOOL ignoreNextFrame;

+ (GPUImageOpenGLESContext *)sharedImageProcessingOpenGLESContext;
+ (void)useImageProcessingContext;
+ (GLint)maximumTextureSizeForThisDevice;
+ (GLint)maximumTextureUnitsForThisDevice;

- (void)presentBufferForDisplay;

// Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;

@end

@protocol GPUImageInput
- (void)newFrameReadyAtTime:(CMTime)frameTime;
- (void)newImageReady;
- (void)setInputTexture:(HFGLTextureWrapper *)newInputTexture atIndex:(NSInteger)textureIndex;
- (NSInteger)nextAvailableTextureIndex;
- (void)setInputSize:(CGSize)newSize;
- (CGSize)maximumOutputSize;
- (void)endProcessing;
- (BOOL)shouldIgnoreUpdatesToThisTarget;
@end