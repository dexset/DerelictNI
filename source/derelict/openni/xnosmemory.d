
// Memory
alias nothrow void* function(const XnSizeT nAllocSize) xnOSMalloc;
alias nothrow void* function(const XnSizeT nAllocSize, const XnSizeT nAlignment) xnOSMallocAligned;
alias nothrow void* function(const XnSizeT nAllocNum, const XnSizeT nAllocSize) xnOSCalloc;
alias nothrow void* function(const XnSizeT nAllocNum, const XnSizeT nAllocSize, const XnSizeT nAlignment) xnOSCallocAligned;
alias nothrow void* function(void* pMemory, const XnSizeT nAllocSize) xnOSRealloc;
alias nothrow void* function(void* pMemory, const XnSizeT nAllocSize, const XnSizeT nAlignment) xnOSReallocAligned;
alias nothrow void* function(void* pMemory, const XnSizeT nAllocNum, const XnSizeT nAllocSize) xnOSRecalloc;
alias nothrow void  function(const void* pMemBlock) xnOSFree;
alias nothrow void  function(const void* pMemBlock) xnOSFreeAligned;
alias nothrow void  function(void* pDest, const void* pSource, XnSizeT nCount) xnOSMemCopy;
alias nothrow XnInt32 (const void *pBuf1, const void *pBuf2, XnSizeT nCount) xnOSMemCmp;
alias nothrow void function(void* pDest, XnUInt8 nValue, XnSizeT nCount) xnOSMemSet;
alias nothrow void function(void* pDest, const void* pSource, XnSizeT nCount) xnOSMemMove;
alias nothrow XnUInt64 function(XnUInt64 nValue) xnOSEndianSwapUINT64;
alias nothrow XnUInt32 function(XnUInt32 nValue) xnOSEndianSwapUINT32;
alias nothrow XnUInt16 function(XnUInt16 nValue) xnOSEndianSwapUINT16;
alias nothrow XnFloat  function(XnFloat fValue) xnOSEndianSwapFLOAT;

