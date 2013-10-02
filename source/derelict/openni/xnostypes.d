module derelict.ni.xnostypes;

//---------------------------------------------------------------------------
// Includes
//---------------------------------------------------------------------------
import derelict.ni.xnplatform;
// "XnOSStrings.h"
// "XnOSMemory.h"

//enum XnOSSeekType
//{
//    XN_OS_SEEK_SET = 0,
//    XN_OS_SEEK_CUR,
//    XN_OS_SEEK_END
//}

immutable XN_MASK_OS = "xnOS";

// uncomment next line to activate memory profiling
//#define XN_MEM_PROFILING

//---------------------------------------------------------------------------
// OS Identifier 
//---------------------------------------------------------------------------
//#if (XN_PLATFORM == XN_PLATFORM_WIN32)
//	#include "Win32/XnOSWin32.h"
//#elif (XN_PLATFORM == XN_PLATFORM_LINUX_X86 || XN_PLATFORM == XN_PLATFORM_LINUX_ARM || XN_PLATFORM == XN_PLATFORM_MACOSX || XN_PLATFORM == XN_PLATFORM_ANDROID_ARM)
//	#include "Linux-x86/XnOSLinux-x86.h"
//#elif defined(_ARC)
//  #include "ARC/XnOSARC.h" 
//#else
//  #if defined __INTEL_COMPILER
//    #include "Linux-x86/XnOSLinux-x86.h" 
//  #else
//     #error OpenNI OS Abstraction Layer - Unsupported Platform!
//  #endif
//#endif

//---------------------------------------------------------------------------
// Types
//---------------------------------------------------------------------------
immutable XN_MAX_OS_NAME_LENGTH = 255;

struct xnOSInfo
{
	XnChar[XN_MAX_OS_NAME_LENGTH] csOSName;
	XnChar[XN_MAX_OS_NAME_LENGTH] csCPUName;
	XnUInt32 nProcessorsCount;
	XnUInt64 nTotalMemory;
}

alias XnBool function(void* pConditionData) XnConditionFunc;

extern(System) XnOSTimer g_xnOSHighResGlobalTimer;

immutable XN_OS_FILE_READ =				0x01;
immutable XN_OS_FILE_WRITE =			0x02;
immutable XN_OS_FILE_CREATE_NEW_ONLY =	0x04;
immutable XN_OS_FILE_TRUNCATE =			0x08;
immutable XN_OS_FILE_APPEND =			0x10;
immutable XN_OS_FILE_AUTO_FLUSH =		0x20;

enum XnOSSeekType {
	XN_OS_SEEK_SET = 0,
	XN_OS_SEEK_CUR,
	XN_OS_SEEK_END
}

enum XnOSSocketType {
	XN_OS_UDP_SOCKET = 0,
	XN_OS_TCP_SOCKET
}

immutable XN_OS_NETWORK_LOCAL_HOST =	"127.0.0.1";

alias nothrow XnStatus function() xnOSInit;
alias nothrow XnStatus function() xnOSShutdown;
alias nothrow XnStatus function(xnOSInfo*) xnOSGetInfo;

enum XnAllocationType
{
	XN_ALLOCATION_MALLOC,
	XN_ALLOCATION_MALLOC_ALIGNED,
	XN_ALLOCATION_CALLOC,
	XN_ALLOCATION_CALLOC_ALIGNED,
	XN_ALLOCATION_NEW,
	XN_ALLOCATION_NEW_ARRAY
} 
alias nothrow void* function(void*, XnAllocationType, XnUInt32, const XnChar*, const XnChar*, XnUInt32, const XnChar*) xnOSLogMemAlloc;
alias nothrow void function(const void*) xnOSLogMemFree;
alias nothrow void function(const XnChar*) xnOSWriteMemoryReport;

// Files
alias nothrow XnStatus function(const XnChar*, const XnChar*, XnChar[XN_FILE_MAX_PATH][], const XnUInt32, XnUInt32*) xnOSGetFileList;
alias nothrow XnStatus function(const XnChar*, const XnUInt32, XN_FILE_HANDLE*) xnOSOpenFile;
alias nothrow XnStatus function(XN_FILE_HANDLE*) xnOSCloseFile;
alias nothrow XnStatus function(const XN_FILE_HANDLE, void* pBuffer, XnUInt32*) xnOSReadFile;
alias nothrow XnStatus function(const XN_FILE_HANDLE, const void*, const XnUInt32) xnOSWriteFile;
alias nothrow XnStatus function(const XN_FILE_HANDLE, const XnOSSeekType, const XnInt32) xnOSSeekFile;
alias nothrow XnStatus function(const XN_FILE_HANDLE, XnUInt32*) xnOSTellFile;
alias nothrow XnStatus function(const XN_FILE_HANDLE) xnOSFlushFile;
alias nothrow XnStatus function(const XnChar*, XnBool*) xnOSDoesFileExist;
alias nothrow XnStatus function(const XnChar*, XnBool*) xnOSDoesDirecotyExist;
alias nothrow XnStatus function(const XnChar*, void*, const XnUInt32) xnOSLoadFile;
alias nothrow XnStatus function(const XnChar*, const void*, const XnUInt32) xnOSSaveFile;
alias nothrow XnStatus function(const XnChar*, const void*, const XnUInt32) xnOSAppendFile;
alias nothrow XnStatus function(const XnChar*, XnUInt32*) xnOSGetFileSize;
alias nothrow XnStatus function(const XnChar*) xnOSCreateDirectory;
alias nothrow XnStatus function(const XnChar*, XnChar*, const XnUInt32) xnOSGetDirName;
alias nothrow XnStatus function(const XnChar*, XnChar*, const XnUInt32) xnOSGetFileName;
alias nothrow XnStatus function(const XnChar*, XnChar*, XnUInt32) xnOSGetFullPathName;
alias nothrow XnStatus function(XnChar*, const XnUInt32) xnOSGetCurrentDir;
alias nothrow XnStatus function(const XnChar*) xnOSSetCurrentDir;
alias nothrow XnStatus function(const XnChar*) xnOSDeleteFile;

// INI
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, XnChar* cpDest, const XnUInt32 nDestLength) xnOSReadStringFromINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, XnFloat* fDest) xnOSReadFloatFromINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, XnDouble* fDest) xnOSReadDoubleFromINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, XnUInt32* nDest) xnOSReadIntFromINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, const XnChar* cpSrc) xnOSWriteStringToINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, const XnFloat fSrc) xnOSWriteFloatToINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, const XnDouble fSrc) xnOSWriteDoubleToINI;
alias nothrow XnStatus function(const XnChar* cpINIFile, const XnChar* cpSection, const XnChar* cpKey, const XnUInt32 nSrc) xnOSWriteIntToINI;

// Shared libraries
alias nothrow XnStatus function(const XnChar* cpFileName, XN_LIB_HANDLE* pLibHandle) xnOSLoadLibrary;
alias nothrow XnStatus function(const XN_LIB_HANDLE LibHandle) xnOSFreeLibrary;
alias nothrow XnStatus function(const XN_LIB_HANDLE LibHandle, const XnChar* cpProcName, XnFarProc* pProcAddr) xnOSGetProcAddress;

struct timespec;
	
// Time
XN_C_API XnStatus XN_C_DECL xnOSGetEpochTime(XnUInt32* nEpochTime);
XN_C_API XnStatus XN_C_DECL xnOSGetTimeStamp(XnUInt64* nTimeStamp);
XN_C_API XnStatus XN_C_DECL xnOSGetHighResTimeStamp(XnUInt64* nTimeStamp);
XN_C_API XnStatus XN_C_DECL xnOSSleep(XnUInt32 nMilliseconds);
XN_C_API XnStatus XN_C_DECL xnOSStartTimer(XnOSTimer* pTimer);
XN_C_API XnStatus XN_C_DECL xnOSStartHighResTimer(XnOSTimer* pTimer);
XN_C_API XnStatus XN_C_DECL xnOSQueryTimer(XnOSTimer Timer, XnUInt64* pnTimeSinceStart);
XN_C_API XnStatus XN_C_DECL xnOSStopTimer(XnOSTimer* pTimer);
XN_C_API XnStatus XN_C_DECL xnOSGetMonoTime(struct timespec* pTime);
XN_C_API XnStatus XN_C_DECL xnOSGetTimeout(struct timespec* pTime, XnUInt32 nMilliseconds);
XN_C_API XnStatus XN_C_DECL xnOSGetAbsTimeout(struct timespec* pTime, XnUInt32 nMilliseconds);

// Threads
typedef enum XnThreadPriority
{
	XN_PRIORITY_LOW,
	XN_PRIORITY_NORMAL,
	XN_PRIORITY_HIGH,
	XN_PRIORITY_CRITICAL
} XnThreadPriority;

alias nothrow XnStatus function(XN_THREAD_PROC_PROTO, const XN_THREAD_PARAM, XN_THREAD_HANDLE*) xnOSCreateThread;
alias nothrow XnStatus function(XN_THREAD_HANDLE*) xnOSTerminateThread;
alias nothrow XnStatus function(XN_THREAD_HANDLE*) xnOSCloseThread;
alias nothrow XnStatus function(XN_THREAD_HANDLE, XnUInt32) xnOSWaitForThreadExit;
alias nothrow XnStatus function(XN_THREAD_HANDLE, XnThreadPriority) xnOSSetThreadPriority;
alias nothrow XnStatus function(XN_THREAD_ID*) xnOSGetCurrentThreadID;
alias nothrow XnStatus function(XN_THREAD_HANDLE*, XnUInt32) xnOSWaitAndTerminateThread;

// Processes
alias nothrow XnStatus function(XN_PROCESS_ID* pProcID) xnOSGetCurrentProcessID;
alias nothrow XnStatus function(const XnChar* strExecutable, XnUInt32 nArgs, const XnChar** pstrArgs, XN_PROCESS_ID* pProcID) xnOSCreateProcess;

// Mutex
alias nothrow XnStatus function(XN_MUTEX_HANDLE* pMutexHandle) xnOSCreateMutex;
alias nothrow XnStatus function(XN_MUTEX_HANDLE* pMutexHandle, const XnChar* cpMutexName) xnOSCreateNamedMutex;
alias nothrow XnStatus function(XN_MUTEX_HANDLE* pMutexHandle) xnOSCloseMutex;
alias nothrow XnStatus function(const XN_MUTEX_HANDLE MutexHandle, XnUInt32 nMilliseconds) xnOSLockMutex;
alias nothrow XnStatus function(const XN_MUTEX_HANDLE MutexHandle) xnOSUnLockMutex;

// Critical Sections
alias nothrow XnStatus function(XN_CRITICAL_SECTION_HANDLE*) xnOSCreateCriticalSection;
alias nothrow XnStatus function(XN_CRITICAL_SECTION_HANDLE*) xnOSCloseCriticalSection;
alias nothrow XnStatus function(XN_CRITICAL_SECTION_HANDLE*) xnOSEnterCriticalSection;
alias nothrow XnStatus function(XN_CRITICAL_SECTION_HANDLE*) xnOSLeaveCriticalSection;

// Events
alias nothrow XnStatus function(XN_EVENT_HANDLE*, XnBool) xnOSCreateEvent;
alias nothrow XnStatus function(XN_EVENT_HANDLE*, const XnChar*, XnBool) xnOSCreateNamedEvent;
alias nothrow XnStatus function(XN_EVENT_HANDLE*, const XnChar*) xnOSOpenNamedEvent;
alias nothrow XnStatus function(XN_EVENT_HANDLE*) xnOSCloseEvent;
alias nothrow XnStatus function(const XN_EVENT_HANDLE) xnOSSetEvent;
alias nothrow XnStatus function(const XN_EVENT_HANDLE) xnOSResetEvent;
alias nothrow XnStatus function(const XN_EVENT_HANDLE, XnUInt32 nMilliseconds) xnOSWaitEvent;
alias nothrow XnBool function(const XN_EVENT_HANDLE) xnOSIsEventSet;

// Semaphores
alias nothrow XnStatus function(XN_SEMAPHORE_HANDLE*, XnUInt32) xnOSCreateSemaphore;
alias nothrow XnStatus function(XN_SEMAPHORE_HANDLE, XnUInt32) xnOSLockSemaphore;
alias nothrow XnStatus function(XN_SEMAPHORE_HANDLE) xnOSUnlockSemaphore;
alias nothrow XnStatus function(XN_SEMAPHORE_HANDLE*) xnOSCloseSemaphore;

alias nothrow XnStatus function(const XN_EVENT_HANDLE, XnUInt32, XnConditionFunc, void*) xnOSWaitForCondition;

// Network
struct xnOSSocket;
alias xnOSSocket* XN_SOCKET_HANDLE;

alias nothrow XnStatus function() xnOSInitNetwork;
alias nothrow XnStatus function() xnOSShutdownNetwork;
alias nothrow XnStatus function(const XnOSSocketType, const XnChar*, const XnUInt16, XN_SOCKET_HANDLE*) xnOSCreateSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE) xnOSCloseSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE) xnOSBindSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE) xnOSListenSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, XN_SOCKET_HANDLE*, XnUInt32) xnOSAcceptSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, XnUInt32) xnOSConnectSocket;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, const XnUInt32) xnOSSetSocketBufferSize;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, const XnChar*, const XnUInt32) xnOSSendNetworkBuffer;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, const XnChar*, const XnUInt32, XN_SOCKET_HANDLE) xnOSSendToNetworkBuffer;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, XnChar*, XnUInt32*, XnUInt32) xnOSReceiveNetworkBuffer;
alias nothrow XnStatus function(XN_SOCKET_HANDLE, XnChar*, XnUInt32*, XN_SOCKET_HANDLE*) xnOSReceiveFromNetworkBuffer;

struct XnOSSharedMemory;
alias XnOSSharedMemory* XN_SHARED_MEMORY_HANDLE;

alias nothrow XnStatus function(const XnChar*, XnUInt32, XnUInt32, XN_SHARED_MEMORY_HANDLE*) xnOSCreateSharedMemory;
alias nothrow XnStatus function(const XnChar*, XnUInt32, XN_SHARED_MEMORY_HANDLE*) xnOSOpenSharedMemory;
alias nothrow XnStatus function(XN_SHARED_MEMORY_HANDLE) xnOSCloseSharedMemory;
alias nothrow XnStatus function(XN_SHARED_MEMORY_HANDLE, void**) xnOSSharedMemoryGetAddress;
alias nothrow XnBool function() xnOSWasKeyboardHit;
alias nothrow XnChar function() xnOSReadCharFromInput;
alias nothrow XnStatus function(XnUInt32 nFramesToSkip, XnChar** astrFrames, XnUInt32 nMaxNameLength, XnUInt32* pnFrames) xnOSGetCurrentCallStack;

XN_STATUS_MESSAGE_MAP_START(XN_ERROR_GROUP_OS)
XN_STATUS_MESSAGE(XN_STATUS_ALLOC_FAILED, "Memory allocation failed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_ALREADY_INIT, "Xiron OS already initialized!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NOT_INIT, "Xiron OS was not initialized!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_NOT_FOUND, "File not found!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INI_FILE_NOT_FOUND, "INI file not found!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_ALREDY_EXISTS, "File already exists!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_OPEN_FAILED, "Failed to open the file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_CLOSE_FAILED, "Failed to close the file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_READ_FAILED, "Failed to read from the file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_WRITE_FAILED, "Failed to write to the file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_SEEK_FAILED, "File seek failed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_TELL_FAILED, "File Tell failed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_FLUSH_FAILED, "File Flush failed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FILE_GET_SIZE_FAILED, "Get File Size failed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INI_READ_FAILED, "Failed to read from INI file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INI_WRITE_FAILED, "Failed to write into INI file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_SEEK_TYPE, "Invalid seek type!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_CREATION_FAILED, "Xiron OS failed to create a thread!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_TERMINATION_FAILED, "Xiron OS failed to terminate a thread!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_CLOSE_FAILED, "Xiron OS failed to close a thread!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_TIMEOUT, "Xiron OS got a thread timeout while waiting for a thread to exit!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_WAIT_FAILED, "Xiron OS failed to wait for a thread to exit!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_SET_PRIORITY_FAILED, "Xiron OS failed to set priority of a thread!")
XN_STATUS_MESSAGE(XN_STATUS_OS_THREAD_UNSUPPORTED_PRIORITY, "Thread priority is unsupported by Xiron OS!")
XN_STATUS_MESSAGE(XN_STATUS_OS_MUTEX_CREATION_FAILED, "Xiron OS failed to create a mutex!")
XN_STATUS_MESSAGE(XN_STATUS_OS_MUTEX_CLOSE_FAILED, "Xiron OS failed to close a mutex!")
XN_STATUS_MESSAGE(XN_STATUS_OS_MUTEX_LOCK_FAILED, "Xiron OS failed to lock a mutex!")
XN_STATUS_MESSAGE(XN_STATUS_OS_MUTEX_TIMEOUT, "Xiron OS got a mutex timeout!")
XN_STATUS_MESSAGE(XN_STATUS_OS_MUTEX_UNLOCK_FAILED, "Xiron OS failed to unlock a mutex!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_CREATION_FAILED, "Xiron OS failed to create an event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_CLOSE_FAILED, "Xiron OS failed to close an event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_SET_FAILED, "Xiron OS failed to set an event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_RESET_FAILED, "Xiron OS failed to reset an event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_TIMEOUT, "Xiron OS got an event timeout!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_WAIT_FAILED, "Xiron OS failed to wait on event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_CANCELED, "This Xiron OS event was canceled!")
XN_STATUS_MESSAGE(XN_STATUS_OS_CANT_LOAD_LIB, "Xiron OS failed to load shared library!")
XN_STATUS_MESSAGE(XN_STATUS_OS_CANT_FREE_LIB, "Xiron OS failed to free shared library!")
XN_STATUS_MESSAGE(XN_STATUS_OS_PROC_NOT_FOUND, "Xiron OS failed to get procedure address from shared library!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_INIT_FAILED, "Xiron OS failed to initialize the network subsystem!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SHUTDOWN_FAILED, "Xiron OS failed to shutdown the network subsystem!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_CREATION_FAILED, "Xiron OS failed to create a network socket!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_INVALID_SOCKET_TYPE, "Invalid Xiron OS socket type!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_BUFFER_FAILED, "Failed to change the Xiron OS socket buffer size!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SEND_FAILED, "Xiron OS failed to send a network buffer!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_RECEIVE_FAILED, "Xiron OS failed to receive a network buffer!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_BIND_FAILED, "Xiron OS failed to bind a network socket!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_LISTEN_FAILED, "Xiron OS failed to listen on a network socket!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_ACCEPT_FAILED, "Xiron OS failed to accept a network socket!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_SOCKET_CONNECT_FAILED, "Xiron OS failed to connect to a network socket!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_BAD_HOST_NAME, "Failed to resolve the host name!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_TIMEOUT, "Got a timeout while waiting for a network command to complete!")
XN_STATUS_MESSAGE(XN_STATUS_OS_TIMER_CREATION_FAILED, "Xiron OS failed to create a timer!")
XN_STATUS_MESSAGE(XN_STATUS_OS_TIMER_QUERY_FAILED, "Xiron OS failed to query a timer!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_TIMER, "This Xiron OS timer is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_FILE, "This Xiron OS file is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_SOCKET, "This Xiron OS socket is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_MUTEX, "This Xiron OS mutex is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_THREAD, "This Xiron OS thread is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_EVENT, "This Xiron OS event is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_LIBRARY, "This Xiron OS shared library is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_CRITICAL_SECTION, "This Xiron OS critical section is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_FORMAT_STRING, "Xiron OS got an invalid format string!")
XN_STATUS_MESSAGE(XN_STATUS_OS_UNSUPPORTED_FUNCTION, "This Xiron OS function is not supported!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FAILED_TO_CREATE_DIR, "Failed to create a directory!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FAILED_TO_DELETE_FILE, "Failed to delete a file!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FAILED_TO_CREATE_SHARED_MEMORY, "Failed to create shared memory!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FAILED_TO_OPEN_SHARED_MEMORY, "Failed to open shared memory!")
XN_STATUS_MESSAGE(XN_STATUS_OS_FAILED_TO_CLOSE_SHARED_MEMORY, "Failed to close shared memory!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ALREADY_INIT, "The Xiron USB subsystem was already initialize!")
XN_STATUS_MESSAGE(XN_STATUS_USB_NOT_INIT, "The Xiron USB subsystem was not initialized!")
XN_STATUS_MESSAGE(XN_STATUS_USB_INIT_FAILED, "The Xiron USB subsystem failed to initialize!")
XN_STATUS_MESSAGE(XN_STATUS_USB_SHUTDOWN_FAILED, "The Xiron USB subsystem failed to shutdown!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENUMERATE_FAILED, "The Xiron USB subsystem failed to enumerate devices!")
XN_STATUS_MESSAGE(XN_STATUS_USB_LOAD_FAILED, "The Xiron USB subsystem failed to load!")
XN_STATUS_MESSAGE(XN_STATUS_USB_FREE_FAILED, "The Xiron USB subsystem failed to free!")
XN_STATUS_MESSAGE(XN_STATUS_USB_REGISTER_FAILED, "The Xiron USB subsystem failed to register the device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_UNREGISTER_FAILED, "The Xiron USB subsystem failed to unregister the device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DEVICE_NOT_VALID, "Invalid Xiron USB device handle!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENDPOINT_NOT_VALID, "Invalid Xiron USB endpoint handle!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DRIVER_NOT_FOUND, "USB driver not found!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DEVICE_NOT_FOUND, "USB device not found!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DEVICE_OPEN_FAILED, "Failed to open the USB device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DEVICE_CLOSE_FAILED, "Failed to close the USB device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_DEVICE_GETINFO_FAILED, "Failed to get information about the USB device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_CONFIG_QUERY_FAILED, "USB config query failed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_INTERFACE_QUERY_FAILED, "USB interface query failed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENDPOINT_QUERY_FAILED, "USB endpoint query failed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_SET_ENDPOINT_POLICY_FAILED, "Failed to set USB endpoint policy!")
XN_STATUS_MESSAGE(XN_STATUS_USB_UNKNOWN_ENDPOINT_TYPE, "Unknown USB endpoint type!")
XN_STATUS_MESSAGE(XN_STATUS_USB_UNKNOWN_ENDPOINT_DIRECTION, "Unknown USB endpoint direction!")
XN_STATUS_MESSAGE(XN_STATUS_USB_GET_SPEED_FAILED, "Failed to get the device speed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_GET_DRIVER_VERSION, "Failed to get the USB driver version!")
XN_STATUS_MESSAGE(XN_STATUS_USB_UNKNOWN_DEVICE_SPEED, "Unknown USB device speed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_CONTROL_SEND_FAILED, "Failed to send a USB control request!")
XN_STATUS_MESSAGE(XN_STATUS_USB_CONTROL_RECV_FAILED, "Failed to receive a USB control request!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENDPOINT_READ_FAILED, "Failed to read from a USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENDPOINT_WRITE_FAILED, "Failed to write into a USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TRANSFER_TIMEOUT, "USB transfer timeout!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TRANSFER_STALL, "USB transfer stall!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TRANSFER_MICRO_FRAME_ERROR, "USB transfer micro frame error!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TRANSFER_UNKNOWN_ERROR, "Unknown USB transfer error!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ENDPOINT_NOT_FOUND, "USB endpoint not found on device!")
XN_STATUS_MESSAGE(XN_STATUS_USB_WRONG_ENDPOINT_TYPE, "Wrong USB endpoint type requested!")
XN_STATUS_MESSAGE(XN_STATUS_USB_WRONG_ENDPOINT_DIRECTION, "Wrong USB endpoint direction requested!")
XN_STATUS_MESSAGE(XN_STATUS_USB_WRONG_CONTROL_TYPE, "Wrong USB control type requested!")
XN_STATUS_MESSAGE(XN_STATUS_USB_UNSUPPORTED_ENDPOINT_TYPE, "Unsupported USB endpoint type!")
XN_STATUS_MESSAGE(XN_STATUS_USB_GOT_UNEXPECTED_BYTES, "Got unexpected bytes in USB transfer!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TOO_MUCH_DATA, "Got too much data in USB transfer!")
XN_STATUS_MESSAGE(XN_STATUS_USB_NOT_ENOUGH_DATA, "Didn't get enough data in USB transfer!")
XN_STATUS_MESSAGE(XN_STATUS_USB_BUFFER_TOO_SMALL, "USB Buffer is too small!")
XN_STATUS_MESSAGE(XN_STATUS_USB_OVERLAPIO_FAILED, "USB Overlapped I/O operation failed!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ABORT_FAILED, "Failed to abort USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_FLUSH_FAILED, "Failed to flush USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_RESET_FAILED, "Failed to reset USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_SET_INTERFACE_FAILED, "Failed to set USB interface!")
XN_STATUS_MESSAGE(XN_STATUS_USB_GET_INTERFACE_FAILED, "Failed to get USB interface!")
XN_STATUS_MESSAGE(XN_STATUS_USB_READTHREAD_NOT_INIT, "Read thread is not initialized for this USB end point!")
XN_STATUS_MESSAGE(XN_STATUS_USB_READTHREAD_ALREADY_INIT, "Read thread is already initialized for this USB end point!")
XN_STATUS_MESSAGE(XN_STATUS_USB_READTHREAD_SHUTDOWN_FAILED, "Read thread failed to shutdown properly!")
XN_STATUS_MESSAGE(XN_STATUS_USB_IS_BUSY, "USB is busy!")
XN_STATUS_MESSAGE(XN_STATUS_USB_NOT_BUSY, "USB is not busy!")
XN_STATUS_MESSAGE(XN_STATUS_USB_SET_CONFIG_FAILED, "Failed to set USB config!")
XN_STATUS_MESSAGE(XN_STATUS_USB_GET_CONFIG_FAILED, "Failed to get USB config!")
XN_STATUS_MESSAGE(XN_STATUS_USB_OPEN_ENDPOINT_FAILED, "Failed to open an USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_CLOSE_ENDPOINT_FAILED, "Failed to close an USB endpoint!")
XN_STATUS_MESSAGE(XN_STATUS_USB_ALREADY_OPEN, "A device is already opened!")
XN_STATUS_MESSAGE(XN_STATUS_USB_TRANSFER_PENDING, "USB transfer is still pending!")
XN_STATUS_MESSAGE(XN_STATUS_USB_INTERFACE_NOT_SUPPORTED, "USB interface is not supported!")
XN_STATUS_MESSAGE(XN_STATUS_USB_FAILED_TO_REGISTER_CALLBACK, "Failed to register the USB device callback!")
XN_STATUS_MESSAGE(XN_STATUS_OS_NETWORK_CONNECTION_CLOSED, "The network connection has been closed!")
XN_STATUS_MESSAGE(XN_STATUS_OS_EVENT_OPEN_FAILED, "Xiron OS failed to open an event!")
XN_STATUS_MESSAGE(XN_STATUS_OS_PROCESS_CREATION_FAILED, "Xiron OS failed to create a process!")
XN_STATUS_MESSAGE(XN_STATUS_OS_SEMAPHORE_CREATION_FAILED, "Xiron OS Failed to create a semaphore!")
XN_STATUS_MESSAGE(XN_STATUS_OS_SEMAPHORE_CLOSE_FAILED, "Xiron OS failed to close a semaphore!")
XN_STATUS_MESSAGE(XN_STATUS_OS_SEMAPHORE_LOCK_FAILED, "Xiron OS failed to lock a semaphore!")
XN_STATUS_MESSAGE(XN_STATUS_OS_SEMAPHORE_UNLOCK_FAILED, "Xiron OS failed to unlock a semaphore!")
XN_STATUS_MESSAGE(XN_STATUS_OS_SEMAPHORE_TIMEOUT, "Xiron OS got a semaphore timeout!")
XN_STATUS_MESSAGE(XN_STATUS_OS_INVALID_SEMAPHORE, "This Xiron OS semaphore is invalid!")
XN_STATUS_MESSAGE(XN_STATUS_OS_ENV_VAR_NOT_FOUND, "The environment variable could not be found!")
XN_STATUS_MESSAGE(XN_STATUS_USB_NO_REQUEST_PENDING, "There is no request pending!")
XN_STATUS_MESSAGE_MAP_END(XN_ERROR_GROUP_OS)

#endif //__XN_OS_H__

