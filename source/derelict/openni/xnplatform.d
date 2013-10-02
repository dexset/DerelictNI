module derelict.ni.xnplatform;

immutable XN_PLATFORM_WIN32 = 1;
immutable XN_PLATFORM_XBOX360 = 2;
immutable XN_PLATFORM_PS3 = 3;
immutable XN_PLATFORM_WII = 4;
immutable XN_PLATFORM_LINUX_X86 = 5;
immutable XN_PLATFORM_FILES_ONLY = 6;
immutable XN_PLATFORM_ARC = 6;
immutable XN_PLATFORM_LINUX_ARM = 7;
immutable XN_PLATFORM_MACOSX = 8;
immutable XN_PLATFORM_ANDROID_ARM = 9;

immutable XN_PLATFORM_IS_LITTLE_ENDIAN = 1;
immutable XN_PLATFORM_IS_BIG_ENDIAN =    2;

immutable XN_PLATFORM_USE_NO_VAARGS = 1;
immutable XN_PLATFORM_USE_WIN32_VAARGS_STYLE = 2;
immutable XN_PLATFORM_USE_GCC_VAARGS_STYLE =   3;
immutable XN_PLATFORM_USE_ARC_VAARGS_STYLE =   4;
alias void function() XnFuncPtr;
