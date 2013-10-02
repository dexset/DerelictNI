
alias nothrow XnStatus function(const XnChar*, XnChar*, const XnUInt32) da_xnOSStrPrefix;
alias nothrow XnStatus function(XnChar*, const XnChar*, const XnUInt32) da_xnOSStrAppend;
alias nothrow XnStatus function(XnChar*, const XnChar*, const XnUInt32) da_xnOSStrCopy;
alias nothrow XnUInt32 function(const XnChar*) da_xnOSStrLen;
alias nothrow XnStatus function(XnChar*, const XnChar*, const XnUInt32, const XnUInt32) da_xnOSStrNCopy;
alias nothrow XnStatus function(const XnChar*, XnUInt32*) da_xnOSStrCRC32;
alias nothrow XnStatus function(XnUChar*, XnUInt32, XnUInt32* nCRC32) da_xnOSStrNCRC32;
//alias nothrow XnStatus function(XnChar*, const XnUInt32, XnUInt32*, const XnChar*, ...) da_xnOSStrFormat;
//alias nothrow XnStatus function(XnChar*, const XnUInt32, XnUInt32*, const XnChar*, va_list args) da_xnOSStrFormatV;
alias nothrow XnInt32  function(const XnChar*, const XnChar*) da_xnOSStrCmp;
alias nothrow XnInt32  function(const XnChar*, const XnChar*) da_xnOSStrCaseCmp;
alias nothrow void     function(XnInt32, XnChar*, XnInt32) da_xnOSItoA;
alias nothrow XnChar*  function(const XnChar*) da_xnOSStrDup;
alias nothrow XnStatus function(const XnChar*, XnChar*, XnUInt32) da_xnOSGetEnvironmentVariable;
alias nothrow XnStatus function(const XnChar*, XnChar*, XnUInt32) da_xnOSExpandEnvironmentStrings;
