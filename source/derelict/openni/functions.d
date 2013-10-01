module derelict.openni.functions;

private
{
    import derelict.openni.types;
}

extern( System )
{
    //XnContext
    alias nothrow XnStatus function( XnContext** ) da_XnInit;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnEnumerationErrors*, XnNodeHandle* ) da_xnContextRunXmlScriptFromFileEx;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnEnumerationErrors* ) da_xnContextRunXmlScriptFromFile;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnEnumerationErrors*, XnNodeHandle* ) da_xnContextRunXmlScriptEx;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnEnumerationErrors* ) da_xnContextRunXmlScript;
    alias nothrow XnStatus function( const XnChar*, XnContext**, XnEnumerationErrors*, XnNodeHandle* ) da_xnInitFromXmlFileEx;
    alias nothrow XnStatus function( const XnChar*, XnContext**, XnEnumerationErrors* ) da_xnInitFromXmlFile;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnNodeHandle* ) da_xnContextOpenFileRecordingEx;
    alias nothrow XnStatus function( XnContext*, const XnChar* ) da_xnContextOpenFileRecording;
    alias nothrow XnStatus function( XnContext* ) da_xnContextAddRef;
    alias nothrow XnStatus function( XnContext*, XnContextShuttingDownHandler, void*, XnCallbackHandle* ) da_xnContextRegisterForShutdown;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, const XnNodeQuery*, XnNodeInfoList**, XnEnumerationErrors* ) da_xnEnumerateProductionTrees;
    alias nothrow XnStatus function( XnContext*, XnNodeInfo* , XnNodeHandle* ) da_xnCreateProductionTree;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, XnNodeQuery*, XnNodeHandle*, XnEnumerationErrors* ) da_xnCreateAnyProductionTree;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, const XnChar*, XnNodeHandle* ) da_xnCreateMockNode;
    alias nothrow XnStatus function( XnContext*, XnNodeHandle, const XnChar*, XnNodeHandle* ) da_xnCreateMockNodeBasedOn;
    alias nothrow XnStatus function( XnNodeHandle ) da_xnProductionNodeAddRef;
    alias nothrow XnStatus function( XnNodeHandle ) da_xnRefProductionNode;
    alias nothrow XnStatus function( XnContext*, XnNodeInfoList** ) da_xnEnumerateExistingNodes;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, XnNodeInfoList** ) da_xnEnumerateExistingNodesByType;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, XnNodeHandle* ) da_xnFindExistingRefNodeByType;
    alias nothrow XnStatus function( XnContext*, XnProductionNodeType, XnNodeHandle* ) da_xnFindExistingNodeByType;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnNodeHandle* ) da_xnGetRefNodeHandleByName;
    alias nothrow XnStatus function( XnContext*, const XnChar*, XnNodeHandle* ) da_xnGetNodeHandleByName;
    alias nothrow XnStatus function( XnContext* ) da_xnWaitAndUpdateAll;
    alias nothrow XnStatus function( XnContext*, XnNodeHandle ) da_xnWaitOneUpdateAll;
    alias nothrow XnStatus function( XnContext* ) da_xnWaitAnyUpdateAll;
    alias nothrow XnStatus function( XnContext* ) da_xnWaitNoneUpdateAll;
    alias nothrow XnStatus function( XnContext* ) da_xnStartGeneratingAll;
    alias nothrow XnStatus function( XnContext* ) da_xnStopGeneratingAll;
    alias nothrow XnStatus function( XnContext*, XnBool ) da_xnSetGlobalMirror;
    alias nothrow XnStatus function( XnContext* ) da_xnGetGlobalErrorState;
    alias nothrow XnStatus function( XnContext*, XnErrorStateChangedHandler, void*, XnCallbackHandle* ) da_xnRegisterToGlobalErrorStateChange;
    alias nothrow XnBool   function( XnContext* ) da_xnGetGlobalMirror;
    alias nothrow void     function( XnContext*, XnCallbackHandle ) da_xnUnregisterFromGlobalErrorStateChange;
    alias nothrow void     function( XnContext* ) da_xnContextRelease;
    alias nothrow void     function( XnContext* ) da_xnShutdown;
    alias nothrow void     function( XnContext* ) da_xnForceShutdown;
    alias nothrow void     function( XnNodeHandle ) da_xnProductionNodeRelease;
    alias nothrow void     function( XnNodeHandle ) da_xnUnrefProductionNode;
    alias nothrow void     function( XnContext*, XnCallbackHandle ) da_xnContextUnregisterFromShutdown;
}

__gshared
{
    //XnContext
    da_XnInit XnInit;
    da_xnContextRunXmlScriptFromFileEx xnContextRunXmlScriptFromFileEx;
    da_xnContextRunXmlScriptFromFile xnContextRunXmlScriptFromFile;
    da_xnContextRunXmlScriptEx xnContextRunXmlScriptEx;
    da_xnContextRunXmlScript xnContextRunXmlScript;
    da_xnInitFromXmlFileEx xnInitFromXmlFileEx;
    da_xnInitFromXmlFile xnInitFromXmlFile;
    da_xnContextOpenFileRecordingEx xnContextOpenFileRecordingEx;
    da_xnContextOpenFileRecording xnContextOpenFileRecording;
    da_xnContextAddRef xnContextAddRef;
    da_xnContextRegisterForShutdown xnContextRegisterForShutdown;
    da_xnEnumerateProductionTrees xnEnumerateProductionTrees;
    da_xnCreateProductionTree xnCreateProductionTree;
    da_xnRefProductionNode xnRefProductionNode;
    da_xnEnumerateExistingNodes xnEnumerateExistingNodes;
    da_xnEnumerateExistingNodesByType xnEnumerateExistingNodesByType;
    da_xnFindExistingRefNodeByType xnFindExistingRefNodeByType;
    da_xnFindExistingNodeByType xnFindExistingNodeByType;
    da_xnGetRefNodeHandleByName xnGetRefNodeHandleByName;
    da_xnGetNodeHandleByName xnGetNodeHandleByName;
    da_xnWaitAndUpdateAll xnWaitAndUpdateAll;
    da_xnWaitOneUpdateAll xnWaitOneUpdateAll;
    da_xnWaitAnyUpdateAll xnWaitAnyUpdateAll;
    da_xnWaitNoneUpdateAll xnWaitNoneUpdateAll;
    da_xnStartGeneratingAll xnStartGeneratingAll;
    da_xnStopGeneratingAll xnStopGeneratingAll;
    da_xnSetGlobalMirror xnSetGlobalMirror;
    da_xnGetGlobalErrorState xnGetGlobalErrorState;
    da_xnRegisterToGlobalErrorStateChange xnRegisterToGlobalErrorStateChange;
    da_xnGetGlobalMirror xnGetGlobalMirror;
    da_xnUnregisterFromGlobalErrorStateChange xnUnregisterFromGlobalErrorStateChange;
    da_xnContextRelease xnContextRelease;
    da_xnShutdown xnShutdown;
    da_xnForceShutdown xnForceShutdown;
    da_xnProductionNodeRelease xnProductionNodeRelease;
    da_xnUnrefProductionNode xnUnrefProductionNode;
    da_xnContextUnregisterFromShutdown xnContextUnregisterFromShutdown;
}
