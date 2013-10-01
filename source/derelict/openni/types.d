module derelict.ni.types;
//NI
//XnStatus

alias uint XnStatus;

//XnOS

enum XnOSSeekType
{
    XN_OS_SEEK_SET = 0,
    XN_OS_SEEK_CUR,
    XN_OS_SEEK_END
}
//XnTypes
const int XN_MIN_INT32 = -2147483648;

alias long XnUInt64;
alias uint XnUInt32;
alias ushort XnUInt16;
alias ubyte XnUInt8;
alias int XnInt32;
alias byte XnChar;
alias float XnFloat;
alias bool XnBool;
alias double XnDouble;

const int XN_MAX_NAME_LENGTH               = 80;
const int XN_MAX_CREATION_INFO_LENGTH	   = 255;
const int XN_MAX_LICENSE_LENGTH			   = 255;
const int XN_NODE_WAIT_FOR_DATA_TIMEOUT	   = 2000;
const string XN_VENDOR_OPEN_NI	           = "OpenNI";
const string XN_FORMAT_NAME_ONI	           = "oni";
const string XN_SCRIPT_FORMAT_XML	       = "xml";
const double XN_PLAYBACK_SPEED_FASTEST	       = 0.0;
const int XN_AUTO_CONTROL				   = XN_MIN_INT32;
alias XnUInt32 XnLockHandle;
alias XnInt32 XnProductionNodeType;
enum XnPredefinedProductionNodeType
{
	XN_NODE_TYPE_INVALID = -1,
	XN_NODE_TYPE_DEVICE = 1,
	XN_NODE_TYPE_DEPTH = 2,
	XN_NODE_TYPE_IMAGE = 3,
	XN_NODE_TYPE_AUDIO = 4,
	XN_NODE_TYPE_IR = 5,
	XN_NODE_TYPE_USER = 6,
	XN_NODE_TYPE_RECORDER = 7,
	XN_NODE_TYPE_PLAYER = 8,
	XN_NODE_TYPE_GESTURE = 9,
	XN_NODE_TYPE_SCENE = 10,
	XN_NODE_TYPE_HANDS = 11,
	XN_NODE_TYPE_CODEC = 12,
	XN_NODE_TYPE_PRODUCTION_NODE = 13,
	XN_NODE_TYPE_GENERATOR = 14,
	XN_NODE_TYPE_MAP_GENERATOR = 15,
	XN_NODE_TYPE_SCRIPT = 16,
	XN_NODE_TYPE_FIRST_EXTENSION,
}

struct XnVersion
{
	XnUInt8 nMajor;
	XnUInt8 nMinor;
	XnUInt16 nMaintenance;
	XnUInt32 nBuild;
}

struct XnProductionNodeDescription
{
	XnProductionNodeType Type;
	XnChar[XN_MAX_NAME_LENGTH] strVendor;
	XnChar[XN_MAX_NAME_LENGTH] strName;
	XnVersion Version;
}

struct XnNodeInfoListNode;

struct XnNodeInfoListIterator
{
	XnNodeInfoListNode* pCurrent;
}

struct XnLicense
{
	XnChar[XN_MAX_NAME_LENGTH] strVendor;
	XnChar[XN_MAX_LICENSE_LENGTH] strKey;
}

struct XnInternalNodeData;

alias XnInternalNodeData* XnNodeHandle;

alias void* XnModuleNodeHandle;

struct XnContext;

alias void* function( XnNodeHandle, void* ) XnStateChanger;

alias void* function( XnStatus, void* ) XnErrorStateChangedHandler;

alias void* function( const void* ) XnFreeHandler;

alias void* function( XnContext*, void* ) XnContextShuttingDownHandler;

alias void* XnCallbackHandle;

alias XnUInt16 XnDepthPixel;

const XnUInt16 XN_DEPTH_NO_SAMPLE_VALUE = cast(XnDepthPixel)(0);

struct XnRGB24Pixel
{
	XnUInt8 nRed;
	XnUInt8 nGreen;
	XnUInt8 nBlue;
}

struct XnYUV422DoublePixel
{
	XnUInt8 nU;
	XnUInt8 nY1;
	XnUInt8 nV;
	XnUInt8 nY2;
}

alias XnUInt8 XnGrayscale8Pixel;

alias XnUInt16 XnGrayscale16Pixel;

alias XnGrayscale16Pixel XnIRPixel;

alias XnUInt16 XnLabel;

const string XN_CAPABILITY_EXTENDED_SERIALIZATION = "ExtendedSerialization";
const string XN_CAPABILITY_MIRROR				    = "Mirror";
const string XN_CAPABILITY_ALTERNATIVE_VIEW_POINT = "AlternativeViewPoint";
const string XN_CAPABILITY_CROPPING			    = "Cropping";
const string XN_CAPABILITY_USER_POSITION		    = "UserPosition";
const string XN_CAPABILITY_SKELETON			    = "User::Skeleton";
const string XN_CAPABILITY_POSE_DETECTION		    = "User::PoseDetection";
const string XN_CAPABILITY_LOCK_AWARE			    = "LockAware";
const string XN_CAPABILITY_ERROR_STATE		    = "ErrorState";
const string XN_CAPABILITY_FRAME_SYNC			    = "FrameSync";
const string XN_CAPABILITY_DEVICE_IDENTIFICATION  = "DeviceIdentification";
const string XN_CAPABILITY_BRIGHTNESS			    = "Brightness";
const string XN_CAPABILITY_CONTRAST			    = "Contrast";
const string XN_CAPABILITY_HUE				    = "Hue";
const string XN_CAPABILITY_SATURATION			    = "Saturation";
const string XN_CAPABILITY_SHARPNESS			    = "Sharpness";
const string XN_CAPABILITY_GAMMA				    = "Gamma";
const string XN_CAPABILITY_COLOR_TEMPERATURE	    = "ColorTemperature";
const string XN_CAPABILITY_BACKLIGHT_COMPENSATION = "BacklightCompensation";
const string XN_CAPABILITY_GAIN				    = "Gain";
const string XN_CAPABILITY_PAN				    = "Pan";
const string XN_CAPABILITY_TILT				    = "Tilt";
const string XN_CAPABILITY_ROLL				    = "Roll";
const string XN_CAPABILITY_ZOOM				    = "Zoom";
const string XN_CAPABILITY_EXPOSURE			    = "Exposure";
const string XN_CAPABILITY_IRIS				    = "Iris";
const string XN_CAPABILITY_FOCUS				    = "Focus";
const string XN_CAPABILITY_LOW_LIGHT_COMPENSATION = "LowLightCompensation";
const string XN_CAPABILITY_ANTI_FLICKER		    = "AntiFlicker";
const string XN_CAPABILITY_HAND_TOUCHING_FOV_EDGE = "Hands::HandTouchingFOVEdge";

const string XN_CAPABILITY_ANTI_FILCKER			=	XN_CAPABILITY_ANTI_FLICKER;

const int XN_QQVGA_X_RES =	160;
const int XN_QQVGA_Y_RES =	120;
const int XN_CGA_X_RES	 =  320;
const int XN_CGA_Y_RES	 =  200;
const int XN_QVGA_X_RES  =  320;
const int XN_QVGA_Y_RES  =  240;
const int XN_VGA_X_RES	 =  640;
const int XN_VGA_Y_RES	 =  480;
const int XN_SVGA_X_RES  =  800;
const int XN_SVGA_Y_RES  =  600;
const int XN_XGA_X_RES	 = 1024;
const int XN_XGA_Y_RES	 =  768;
const int XN_720P_X_RES  = 1280;
const int XN_720P_Y_RES  =  720;
const int XN_SXGA_X_RES  = 1280;
const int XN_SXGA_Y_RES  = 1024;
const int XN_UXGA_X_RES  = 1600;
const int XN_UXGA_Y_RES  = 1200;
const int XN_1080P_X_RES = 1920;
const int XN_1080P_Y_RES = 1080;
const int XN_QCIF_X_RES  =  176;
const int XN_QCIF_Y_RES  =  144;
const int XN_240P_X_RES  =  423;
const int XN_240P_Y_RES  =  240;
const int XN_CIF_X_RES	 =  352;
const int XN_CIF_Y_RES	 =  288;
const int XN_WVGA_X_RES  =  640;
const int XN_WVGA_Y_RES  =  360;
const int XN_480P_X_RES  =  864;
const int XN_480P_Y_RES  =  480;
const int XN_576P_X_RES  = 1024;
const int XN_576P_Y_RES  =  576;
const int XN_DV_X_RES	 =  960;
const int XN_DV_Y_RES	 =  720;

enum XnResolution
{
	XN_RES_CUSTOM = 0,
	XN_RES_QQVGA = 1,
	XN_RES_CGA = 2,
	XN_RES_QVGA = 3,
	XN_RES_VGA = 4,
	XN_RES_SVGA = 5,
	XN_RES_XGA = 6,
	XN_RES_720P = 7,
	XN_RES_SXGA = 8,
	XN_RES_UXGA = 9,
	XN_RES_1080P = 10,
	XN_RES_QCIF = 11,
	XN_RES_240P = 12,
	XN_RES_CIF = 13,
	XN_RES_WVGA = 14,
	XN_RES_480P = 15,
	XN_RES_576P = 16,
	XN_RES_DV = 17,
}

struct XnMapOutputMode
{
	XnUInt32 nXRes;
	XnUInt32 nYRes;
	XnUInt32 nFPS;
}

enum XnSampleRate
{
	XN_SAMPLE_RATE_8K = 8000,
	XN_SAMPLE_RATE_11K = 11025,
	XN_SAMPLE_RATE_12K = 12000,
	XN_SAMPLE_RATE_16K = 16000,
	XN_SAMPLE_RATE_22K = 22050,
	XN_SAMPLE_RATE_24K = 24000,
	XN_SAMPLE_RATE_32K = 32000,
	XN_SAMPLE_RATE_44K = 44100,
	XN_SAMPLE_RATE_48K = 48000,
}
struct XnWaveOutputMode
{
	XnUInt32 nSampleRate;
	XnUInt16 nBitsPerSample;
	XnUInt8 nChannels;
}

struct XnVector3D
{
	XnFloat X;
	XnFloat Y;
	XnFloat Z;
}

alias XnVector3D XnPoint3D;

struct XnBoundingBox3D
{
	XnPoint3D LeftBottomNear;
	XnPoint3D RightTopFar;
}

struct XnCropping
{
	XnBool bEnabled;
	XnUInt16 nXOffset;
	XnUInt16 nYOffset;
	XnUInt16 nXSize;
	XnUInt16 nYSize;
}

struct XnFieldOfView
{
	XnDouble fHFOV;
	XnDouble fVFOV;
}

enum XnPixelFormat
{
	XN_PIXEL_FORMAT_RGB24 = 1,
	XN_PIXEL_FORMAT_YUV422 = 2,
	XN_PIXEL_FORMAT_GRAYSCALE_8_BIT = 3,
	XN_PIXEL_FORMAT_GRAYSCALE_16_BIT = 4,
	XN_PIXEL_FORMAT_MJPEG = 5,
}

struct XnSupportedPixelFormats
{
	XnBool m_bRGB24 = 1;
	XnBool m_bYUV422 = 1;
	XnBool m_bGrayscale8Bit = 1;
	XnBool m_bGrayscale16Bit = 1;
	XnBool m_bMJPEG = 1;
	XnUInt32 m_nPadding = 3;
	XnUInt32 m_nReserved = 24;
}

enum XnPlayerSeekOrigin
{
	XN_PLAYER_SEEK_SET = 0,
	XN_PLAYER_SEEK_CUR = 1,
	XN_PLAYER_SEEK_END = 2,
}

enum XnPowerLineFrequency
{
	XN_POWER_LINE_FREQUENCY_OFF = 0,
	XN_POWER_LINE_FREQUENCY_50_HZ = 50,
	XN_POWER_LINE_FREQUENCY_60_HZ = 60,
}

alias XnUInt32 XnUserID;
alias XnFloat  XnConfidence;

struct XnMatrix3X3
{
	XnFloat elements[9];
}

struct XnPlane3D
{
	XnVector3D vNormal;
	XnPoint3D ptPoint;
}

struct XnSkeletonJointPosition
{
	XnVector3D		position;
	XnConfidence	fConfidence;
}

struct XnSkeletonJointOrientation
{
	XnMatrix3X3		orientation;
	XnConfidence	fConfidence;
}

struct XnSkeletonJointTransformation
{
	XnSkeletonJointPosition		position;
	XnSkeletonJointOrientation	orientation;
}

enum XnSkeletonJoint
{
	XN_SKEL_HEAD			= 1,
	XN_SKEL_NECK			= 2,
	XN_SKEL_TORSO			= 3,
	XN_SKEL_WAIST			= 4,

	XN_SKEL_LEFT_COLLAR		= 5,
	XN_SKEL_LEFT_SHOULDER	= 6,
	XN_SKEL_LEFT_ELBOW		= 7,
	XN_SKEL_LEFT_WRIST		= 8,
	XN_SKEL_LEFT_HAND		= 9,
	XN_SKEL_LEFT_FINGERTIP	=10,

	XN_SKEL_RIGHT_COLLAR	=11,
	XN_SKEL_RIGHT_SHOULDER	=12,
	XN_SKEL_RIGHT_ELBOW		=13,
	XN_SKEL_RIGHT_WRIST		=14,
	XN_SKEL_RIGHT_HAND		=15,
	XN_SKEL_RIGHT_FINGERTIP	=16,

	XN_SKEL_LEFT_HIP		=17,
	XN_SKEL_LEFT_KNEE		=18,
	XN_SKEL_LEFT_ANKLE		=19,
	XN_SKEL_LEFT_FOOT		=20,

	XN_SKEL_RIGHT_HIP		=21,
	XN_SKEL_RIGHT_KNEE		=22,
	XN_SKEL_RIGHT_ANKLE		=23,
	XN_SKEL_RIGHT_FOOT		=24	
}

enum XnSkeletonProfile
{
	XN_SKEL_PROFILE_NONE		= 1,
	XN_SKEL_PROFILE_ALL			= 2,
	XN_SKEL_PROFILE_UPPER		= 3,
	XN_SKEL_PROFILE_LOWER		= 4,
	XN_SKEL_PROFILE_HEAD_HANDS	= 5,
}

enum XnPoseDetectionStatus
{
	XN_POSE_DETECTION_STATUS_OK			= 0,
	XN_POSE_DETECTION_STATUS_NO_USER	= 1,
	XN_POSE_DETECTION_STATUS_TOP_FOV	= 2,
	XN_POSE_DETECTION_STATUS_SIDE_FOV	= 3,
	XN_POSE_DETECTION_STATUS_ERROR		= 4,
}

enum XnCalibrationStatus
{
	XN_CALIBRATION_STATUS_OK		= 0,
	XN_CALIBRATION_STATUS_NO_USER	= 1,
	XN_CALIBRATION_STATUS_ARM		= 2,
	XN_CALIBRATION_STATUS_LEG		= 3,
	XN_CALIBRATION_STATUS_HEAD		= 4,
	XN_CALIBRATION_STATUS_TORSO		= 5,
	XN_CALIBRATION_STATUS_TOP_FOV	= 6,
	XN_CALIBRATION_STATUS_SIDE_FOV	= 7,
	XN_CALIBRATION_STATUS_POSE		= 8,
}

enum XnDirection
{
	XN_DIRECTION_ILLEGAL	= 0,
	XN_DIRECTION_LEFT		= 1,
	XN_DIRECTION_RIGHT		= 2,
	XN_DIRECTION_UP			= 3,
	XN_DIRECTION_DOWN		= 4,
	XN_DIRECTION_FORWARD	= 5,
	XN_DIRECTION_BACKWARD	= 6,
}

alias void* function( XnNodeHandle, XnUserID, void* ) XnUserHandler;
alias void* function( XnNodeHandle, XnUserID, const XnPoint3D*, XnFloat, void* ) XnHandCreate;
alias void* function( XnNodeHandle, XnUserID, const XnPoint3D*, XnFloat, void* ) XnHandUpdate;
alias void* function( XnNodeHandle, XnUserID, XnFloat, void* ) XnHandDestroy;
alias void* function( XnNodeHandle, XnUserID, const XnPoint3D*, XnFloat, XnDirection, void* ) XnHandTouchingFOVEdge;
alias void* function( XnNodeHandle, const XnChar*, const XnPoint3D*, const XnPoint3D*, void* ) XnGestureRecognized;
alias void* function( XnNodeHandle, const XnChar*, const XnPoint3D*, XnFloat, void* ) XnGestureProgress;
alias void* function( XnNodeHandle, const XnChar*, const XnPoint3D*, void* ) XnGestureIntermediateStageCompleted;
alias void* function( XnNodeHandle, const XnChar*, const XnPoint3D*, void* ) XnGestureReadyForNextIntermediateStage;
alias void* function( XnNodeHandle, XnUserID, void* ) XnCalibrationStart;
alias void* function( XnNodeHandle, XnUserID, XnBool, void* ) XnCalibrationEnd;
alias void* function( XnNodeHandle, XnUserID, XnCalibrationStatus, void* ) XnCalibrationInProgress;
alias void* function( XnNodeHandle, XnUserID, XnCalibrationStatus, void* ) XnCalibrationComplete;
alias void* function( XnNodeHandle, const XnChar*, XnUserID, void* ) XnPoseDetectionCallback;
alias void* function( XnNodeHandle, const XnChar*, XnUserID, XnPoseDetectionStatus, void* ) XnPoseDetectionInProgress;

enum XnRecordMedium
{
	/** Recording medium is a file **/
	XN_RECORD_MEDIUM_FILE = 0,
}

alias XnUInt32 XnCodecID;

@system pure nothrow uint XN_CODEC_ID( uint c1, uint c2, uint c3, uint c4 ){ return ( c4 << 24 ) | ( c3 << 16 ) | ( c2 << 8 ) | c1; }

struct XnRecorderOutputStreamInterface
{
    alias void function( void* ) fOpen;
    fOpen* Open;
	alias XnStatus function( void* , const XnChar*, const void*, XnUInt32 ) fWrite;
    fWrite* Write;
	alias XnStatus function(void*, XnOSSeekType, const XnUInt32 ) fSeek;
    fSeek* Seek;
	alias XnUInt32 function( void* ) fTell;
    fTell* Tell;
	alias void function( void* ) fClose;
    fClose* Close;
}

struct XnPlayerInputStreamInterface
{
    alias void function( void* ) fOpen;
    fOpen* Open;
	alias XnStatus function( void* , void*, XnUInt32, XnUInt32* ) fWrite;
    fWrite* Write;
	alias XnStatus function(void*, XnOSSeekType, const XnUInt32 ) fSeek;
    fSeek* Seek;
	alias XnUInt32 function( void* ) fTell;
    fTell* Tell;
	alias void function( void* ) fClose;
    fClose* Close;
}

struct XnNodeNotifications
{
    alias XnStatus function( void*, const XnChar, XnProductionNodeType, XnCodecID ) fOnNodeAdded;
    fOnNodeAdded* OnNodeAdded;

	alias XnStatus function( void*, const XnChar*) fOnNodeRemoved;
    fOnNodeRemoved* OnNodeRemoved;

	alias XnStatus function( void*, const XnChar*, const XnChar*, XnUInt64 ) fOnNodeIntPropChanged;
    fOnNodeIntPropChanged* OnNodeIntPropChanged;
	alias XnStatus function( void*, const XnChar*, const XnChar*, XnDouble ) fOnNodeRealPropChanged;
    fOnNodeRealPropChanged* OnNodeRealPropChanged;
	alias XnStatus function(void*, const XnChar*, const XnChar*, const XnChar* ) fOnNodeStringPropChanged;
    fOnNodeStringPropChanged* OnNodeStringPropChanged;
	alias XnStatus function(void*, const XnChar*, const XnChar*, XnUInt32, const void* ) fOnNodeGeneralPropChanged;
    fOnNodeGeneralPropChanged* OnNodeGeneralPropChanged;
	alias XnStatus function(void*, const XnChar* ) fOnNodeStateReady;
    fOnNodeStateReady* OnNodeStateReady;
	alias XnStatus function(void*, const XnChar*, XnUInt64, XnUInt32, const void*, XnUInt32 ) fOnNodeNewData;
    fOnNodeNewData* OnNodeNewData;
}

struct XnUInt32XYPair
{
	XnUInt32 X;
	XnUInt32 Y;
}

struct XnOutputMetaData
{
	XnUInt64 nTimestamp;
	XnUInt32 nFrameID;
	XnUInt32 nDataSize;
	XnBool bIsNew;

}

struct XnMapMetaData
{
	XnOutputMetaData* pOutput;
	XnUInt32XYPair Res;
	XnUInt32XYPair Offset;
	XnUInt32XYPair FullRes;
	XnPixelFormat PixelFormat;
	XnUInt32 nFPS;
}

struct XnDepthMetaData
{
	XnMapMetaData* pMap;
	const XnDepthPixel* pData;
	XnDepthPixel nZRes;
}

struct XnImageMetaData
{
	XnMapMetaData* pMap;
	const XnUInt8* pData;
}

struct XnIRMetaData
{
	XnMapMetaData* pMap;
	const XnIRPixel* pData;
}

struct XnAudioMetaData
{
	XnOutputMetaData* pOutput;
	XnWaveOutputMode Wave;
	const XnUInt8* pData;
}

struct XnSceneMetaData
{
	XnMapMetaData* pMap;
	const XnLabel* pData;
}
