#ifndef _TC_FACEALIGNMENT_H_
#define _TC_FACEALIGNMENT_H_
#include <opencv2/core/core.hpp>
#include <vector>
#include <string>

/** The face profile landmarks ordering
*
*     0                            20
*     1                            19
*      2                          18
*      3                          17
*       4                        16
*        5                     15
*         6                   14
*          7                 13
*            8              12
*              9         11
*                   10
*/

typedef struct _TC_FaceProfile
{
  std::vector<cv::Point2f> points;
}TC_FaceProfile;

/** The left eye and eyebrow landmarks ordering
*
*         7   6   5
*    0                 4
*         1   2   3
*/

typedef struct _TC_LeftEye
{
  std::vector<cv::Point2f> points;
}TC_LeftEye;

typedef struct _TC_LeftEyebrow
{
  std::vector<cv::Point2f> points;
}TC_LeftEyebrow;


/** The right eye and eyebrow landmarks ordering
*
*         5   6   7
*    4                 0
*         3   2   1
*/

typedef struct _TC_RightEye
{
  std::vector<cv::Point2f> points;
}TC_RightEye;

typedef struct _TC_RightEyebrow
{
  std::vector<cv::Point2f> points;
}TC_RightEyebrow;

/** The nose landmarks ordering
*
*           1
*        2    12
*      3        11
*     4     0    10
*    5  6  7  8   9
*/


typedef struct _TC_Nose
{
  std::vector<cv::Point2f> points;
}TC_Nose;

/** The mouth landmarks ordering
*
*                 10   9   8
*          11                      7
*            21  20  19 18 17
*    0                                    6
*            12  13  14 15 16
*           1                      5
*                  2   3   4
*/


typedef struct _TC_Mouth
{
  std::vector<cv::Point2f> points;
}TC_Mouth;

/** The pupils ordering
*
*       0                          1
*/
typedef struct _TC_Pupil
{
  std::vector<cv::Point2f> points;

}TC_Pupil;

typedef struct _TC_FaceShape
{
  TC_FaceProfile faceProfile;
  TC_LeftEyebrow leftEyebrow;
  TC_RightEyebrow rightEyebrow;
  TC_LeftEye leftEye;
  TC_RightEye rightEye;
  TC_Nose nose;
  TC_Mouth mouth;
  TC_Pupil pupil;
}TC_FaceShape;

class UFA;
class PtsPostProc;
class TC_FaceAlignmentRunner
{
public:
  int static iOS_setupEnivroment(const std::string& bundlePath, const unsigned char * udata);
  TC_FaceAlignmentRunner();
  ~TC_FaceAlignmentRunner();
  static void Release();
  static const char* Version();
    
    /***************************************
     *input image MUST be a Gray image
     ****************************************/
    int  doFaceAlignmentWithCls(const cv::Mat& image, const cv::Rect& faceRect, TC_FaceShape& faceShape, std::vector<float>& cls);
    int  doFaceAlignmentTrackWithCls(const cv::Mat& image,const TC_FaceShape& lastShape, TC_FaceShape& newShape, std::vector<float>& cls);

private:
  TC_FaceAlignmentRunner(TC_FaceAlignmentRunner const &){};
  UFA* m_ufa;
  PtsPostProc *pp;
};
#endif // _TC_FACEALIGNMENT_H_
