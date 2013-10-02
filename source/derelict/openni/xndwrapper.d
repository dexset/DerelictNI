typedef void (XN_CALLBACK_TYPE* StateChangedHandler)(ProductionNode& node, void* pCookie);

typedef XnStatus (*_XnRegisterStateChangeFuncPtr)(XnNodeHandle hNode, XnStateChangedHandler handler, void* pCookie, XnCallbackHandle* phCallback);
typedef void (*_XnUnregisterStateChangeFuncPtr)(XnNodeHandle hNode, XnCallbackHandle hCallback);

static XnStatus _RegisterToStateChange(_XnRegisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);
static void _UnregisterFromStateChange(_XnUnregisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, XnCallbackHandle hCallback);

class Version
{
public:
    Version(const XnVersion& version) : m_version(version) {}
    Version(XnUInt8 nMajor, XnUInt8 nMinor, XnUInt16 nMaintenance, XnUInt32 nBuild)
    {
        m_version.nMajor = nMajor;
        m_version.nMinor = nMinor;
        m_version.nMaintenance = nMaintenance;
        m_version.nBuild = nBuild;
    }

    bool operator==(const Version& other) const
    {
        return (xnVersionCompare(&m_version, &other.m_version) == 0);
    }
    bool operator!=(const Version& other) const
    {
        return (xnVersionCompare(&m_version, &other.m_version) != 0);
    }
    bool operator<(const Version& other) const 
    {
        return (xnVersionCompare(&m_version, &other.m_version) < 0);
    }
    bool operator<=(const Version& other) const
    {
        return (xnVersionCompare(&m_version, &other.m_version) <= 0);
    }
    bool operator>(const Version& other) const
    {
        return (xnVersionCompare(&m_version, &other.m_version) > 0);
    }
    bool operator>=(const Version& other) const
    {
        return (xnVersionCompare(&m_version, &other.m_version) >= 0);
    }
private:
    XnVersion m_version;
};

class OutputMetaData
{
public:
    inline OutputMetaData(const XnUInt8** ppData) : m_pAllocatedData(NULL), m_ppData(ppData), m_nAllocatedSize(0)
    {
        xnOSMemSet(&m_output, 0, sizeof(XnOutputMetaData));
    }

    virtual ~OutputMetaData() { Free(); }

    inline XnUInt64 Timestamp() const { return m_output.nTimestamp; }
    inline XnUInt64& Timestamp() { return m_output.nTimestamp; }

    inline XnUInt32 FrameID() const { return m_output.nFrameID; }
    inline XnUInt32& FrameID() { return m_output.nFrameID; }

    inline XnUInt32 DataSize() const { return m_output.nDataSize; }
    inline XnUInt32& DataSize() { return m_output.nDataSize; }

    inline XnBool IsDataNew() const { return m_output.bIsNew; }
    inline XnBool& IsDataNew() { return m_output.bIsNew; }

    inline const XnOutputMetaData* GetUnderlying() const { return &m_output; }
    inline XnOutputMetaData* GetUnderlying() { return &m_output; }

    inline const XnUInt8* Data() const { return *m_ppData; }
    inline const XnUInt8*& Data() { return *m_ppData; }
    inline XnUInt8* WritableData()
    {
        MakeDataWritable();
        return m_pAllocatedData;
    }

    XnStatus AllocateData(XnUInt32 nBytes)
    {
        if (nBytes > m_nAllocatedSize)
        {
            XnUInt8* pData = (XnUInt8*)xnOSMallocAligned(nBytes, XN_DEFAULT_MEM_ALIGN);
            XN_VALIDATE_ALLOC_PTR(pData);

            Free();
            m_pAllocatedData = pData;
            m_nAllocatedSize = nBytes;
        }

        DataSize() = nBytes;
        *m_ppData = m_pAllocatedData;

        return XN_STATUS_OK;
    }

    void Free()
    {
        if (m_nAllocatedSize != 0)
        {
            xnOSFreeAligned(m_pAllocatedData);
            m_pAllocatedData = NULL;
            m_nAllocatedSize = 0;
        }
    }

    XnStatus MakeDataWritable()
    {
        XnStatus nRetVal = XN_STATUS_OK;

        if (Data() != m_pAllocatedData || DataSize() > m_nAllocatedSize)
        {
            const XnUInt8* pOrigData = *m_ppData;

            nRetVal = AllocateData(DataSize());
            XN_IS_STATUS_OK(nRetVal);

            if (pOrigData != NULL)
            {
                xnOSMemCopy(m_pAllocatedData, pOrigData, DataSize());
            }
            else
            {
                xnOSMemSet(m_pAllocatedData, 0, DataSize());
            }
        }

        return (XN_STATUS_OK);
    }

protected:
    XnUInt8* m_pAllocatedData;

private:
    XnOutputMetaData m_output;

    const XnUInt8** m_ppData;
    XnUInt32 m_nAllocatedSize;
};

class MapMetaData : public OutputMetaData
{
public:
    inline MapMetaData(XnPixelFormat format, const XnUInt8** ppData) : OutputMetaData(ppData)
    {
        xnOSMemSet(&m_map, 0, sizeof(XnMapMetaData));
        m_map.pOutput = OutputMetaData::GetUnderlying();
        m_map.PixelFormat = format;
    }

    inline XnUInt32 XRes() const { return m_map.Res.X; }
    inline XnUInt32& XRes() { return m_map.Res.X; }

    inline XnUInt32 YRes() const { return m_map.Res.Y; }
    inline XnUInt32& YRes() { return m_map.Res.Y; }

    inline XnUInt32 XOffset() const { return m_map.Offset.X; }
    inline XnUInt32& XOffset() { return m_map.Offset.X; }

    inline XnUInt32 YOffset() const { return m_map.Offset.Y; }
    inline XnUInt32& YOffset() { return m_map.Offset.Y; }

    inline XnUInt32 FullXRes() const { return m_map.FullRes.X; }
    inline XnUInt32& FullXRes() { return m_map.FullRes.X; }

    inline XnUInt32 FullYRes() const { return m_map.FullRes.Y; }
    inline XnUInt32& FullYRes() { return m_map.FullRes.Y; }

    inline XnUInt32 FPS() const { return m_map.nFPS; }
    inline XnUInt32& FPS() { return m_map.nFPS; }

    inline XnPixelFormat PixelFormat() const { return m_map.PixelFormat; }

    inline const XnMapMetaData* GetUnderlying() const { return &m_map; }
    inline XnMapMetaData* GetUnderlying() { return &m_map; }

    inline XnUInt32 BytesPerPixel() const
    {
        switch (PixelFormat())
        {
            case XN_PIXEL_FORMAT_RGB24:
                return sizeof(XnRGB24Pixel);
            case XN_PIXEL_FORMAT_YUV422:
                return sizeof(XnYUV422DoublePixel)/2;
            case XN_PIXEL_FORMAT_GRAYSCALE_8_BIT:
                return sizeof(XnGrayscale8Pixel);
            case XN_PIXEL_FORMAT_GRAYSCALE_16_BIT:
                return sizeof(XnGrayscale16Pixel);
            case XN_PIXEL_FORMAT_MJPEG:
                return 2;
            default:
                XN_ASSERT(FALSE);
                return 0;
        }
    }

    XnStatus AllocateData(XnUInt32 nXRes, XnUInt32 nYRes)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        XnUInt32 nSize = nXRes * nYRes * BytesPerPixel();
        nRetVal = OutputMetaData::AllocateData(nSize);
        XN_IS_STATUS_OK(nRetVal);

        FullXRes() = XRes() = nXRes;
        FullYRes() = YRes() = nYRes;
        XOffset() = YOffset() = 0;
        
        return (XN_STATUS_OK);
    }

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnUInt8* pExternalBuffer)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        if (pExternalBuffer == NULL)
        {
            nRetVal = AllocateData(nXRes, nYRes);
            XN_IS_STATUS_OK(nRetVal);
        }
        else
        {
            FullXRes() = XRes() = nXRes;
            FullYRes() = YRes() = nYRes;
            XOffset() = YOffset() = 0;
            Data() = pExternalBuffer;
            DataSize() = nXRes * nYRes * BytesPerPixel();
        }

        return (XN_STATUS_OK);
    }

protected:
    XnPixelFormat& PixelFormatImpl() { return m_map.PixelFormat; }

private:
    MapMetaData& operator=(const MapMetaData&);
    inline MapMetaData(const MapMetaData& other);

    XnMapMetaData m_map;
};

#define _XN_DECLARE_MAP_DATA_CLASS(_name, _pixelType)							\
class _name																	\
{																			\
public:																		\
    inline _name(_pixelType*& pData, XnUInt32& nXRes, XnUInt32 &nYRes) :	\
    m_pData(pData), m_nXRes(nXRes), m_nYRes(nYRes) {}						\
                                                                            \
    inline XnUInt32 XRes() const { return m_nXRes; }						\
    inline XnUInt32 YRes() const { return m_nYRes; }						\
                                                                            \
    inline const _pixelType& operator[](XnUInt32 nIndex) const				\
    {																		\
        XN_ASSERT(nIndex < (m_nXRes * m_nYRes));							\
        return m_pData[nIndex];												\
    }																		\
    inline _pixelType& operator[](XnUInt32 nIndex)							\
    {																		\
        XN_ASSERT(nIndex < (m_nXRes *m_nYRes));								\
        return m_pData[nIndex];												\
    }																		\
                                                                            \
    inline const _pixelType& operator()(XnUInt32 x, XnUInt32 y) const		\
    {																		\
        XN_ASSERT(x < m_nXRes && y < m_nYRes);								\
        return m_pData[y*m_nXRes + x];										\
    }																		\
    inline _pixelType& operator()(XnUInt32 x, XnUInt32 y)					\
    {																		\
        XN_ASSERT(x < m_nXRes && y < m_nYRes);								\
        return m_pData[y*m_nXRes + x];										\
    }																		\
                                                                            \
private:																	\
    _name(const _name& other);												\
    _name& operator=(const _name&);											\
                                                                            \
    _pixelType*& m_pData;													\
    XnUInt32& m_nXRes;														\
    XnUInt32& m_nYRes;														\
};																		

_XN_DECLARE_MAP_DATA_CLASS(DepthMap, XnDepthPixel);
_XN_DECLARE_MAP_DATA_CLASS(ImageMap, XnUInt8);
_XN_DECLARE_MAP_DATA_CLASS(RGB24Map, XnRGB24Pixel);
_XN_DECLARE_MAP_DATA_CLASS(Grayscale16Map, XnGrayscale16Pixel);
_XN_DECLARE_MAP_DATA_CLASS(Grayscale8Map, XnGrayscale8Pixel);
_XN_DECLARE_MAP_DATA_CLASS(IRMap, XnIRPixel);
_XN_DECLARE_MAP_DATA_CLASS(LabelMap, XnLabel);

class DepthMetaData : public MapMetaData
{
public:
    inline DepthMetaData() : 
        MapMetaData(XN_PIXEL_FORMAT_GRAYSCALE_16_BIT, (const XnUInt8**)&m_depth.pData),
        m_depthMap(const_cast<XnDepthPixel*&>(m_depth.pData), MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableDepthMap((XnDepthPixel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y)
    {
        xnOSMemSet(&m_depth, 0, sizeof(XnDepthMetaData));
        m_depth.pMap = MapMetaData::GetUnderlying();
    }

    inline void InitFrom(const DepthMetaData& other)
    {
        xnCopyDepthMetaData(&m_depth, &other.m_depth);
    }

    inline XnStatus InitFrom(const DepthMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnDepthPixel* pExternalBuffer)
    {
        InitFrom(other);
        return ReAdjust(nXRes, nYRes, pExternalBuffer);
    }

    XnStatus CopyFrom(const DepthMetaData& other)
    {
        InitFrom(other);
        return MakeDataWritable();
    }

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnDepthPixel* pExternalBuffer = NULL)
    {
        return MapMetaData::ReAdjust(nXRes, nYRes, (const XnUInt8*)pExternalBuffer);
    }

    inline XnDepthPixel ZRes() const { return m_depth.nZRes; }
    inline XnDepthPixel& ZRes() { return m_depth.nZRes; }

    inline const XnDepthPixel* Data() const { return (const XnDepthPixel*)MapMetaData::Data(); }
    inline const XnDepthPixel*& Data() { return (const XnDepthPixel*&)MapMetaData::Data(); }
    inline XnDepthPixel* WritableData() { return (XnDepthPixel*)MapMetaData::WritableData(); }

    inline const xn::DepthMap& DepthMap() const { return m_depthMap; }
    inline xn::DepthMap& WritableDepthMap() 
    { 
        MakeDataWritable();
        return m_writableDepthMap; 
    }

    inline const XnDepthPixel& operator[](XnUInt32 nIndex) const 
    { 
        XN_ASSERT(nIndex < (XRes()*YRes()));
        return Data()[nIndex]; 
    }

    inline const XnDepthPixel& operator()(XnUInt32 x, XnUInt32 y) const 
    {
        XN_ASSERT(x < XRes() && y < YRes());
        return Data()[y*XRes() + x]; 
    }

    inline const XnDepthMetaData* GetUnderlying() const { return &m_depth; }
    inline XnDepthMetaData* GetUnderlying() { return &m_depth; }

private:
    DepthMetaData(const DepthMetaData& other);
    DepthMetaData& operator=(const DepthMetaData&);

    XnDepthMetaData m_depth;
    const xn::DepthMap m_depthMap;
    xn::DepthMap m_writableDepthMap;
};

class ImageMetaData : public MapMetaData
{
public:
    inline ImageMetaData() : 
        MapMetaData(XN_PIXEL_FORMAT_RGB24, &m_image.pData),
        m_imageMap(const_cast<XnUInt8*&>(m_image.pData), MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableImageMap((XnUInt8*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_rgb24Map((XnRGB24Pixel*&)m_image.pData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableRgb24Map((XnRGB24Pixel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_gray16Map((XnGrayscale16Pixel*&)m_image.pData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableGray16Map((XnGrayscale16Pixel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_gray8Map((XnGrayscale8Pixel*&)m_image.pData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableGray8Map((XnGrayscale8Pixel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y)
    {
        xnOSMemSet(&m_image, 0, sizeof(XnImageMetaData));
        m_image.pMap = MapMetaData::GetUnderlying();
    }

    inline void InitFrom(const ImageMetaData& other)
    {
        xnCopyImageMetaData(&m_image, &other.m_image);
    }

    inline XnStatus InitFrom(const ImageMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format, const XnUInt8* pExternalBuffer)
    {
        InitFrom(other);
        XnStatus nRetVal = ReAdjust(nXRes, nYRes, format, pExternalBuffer);
        XN_IS_STATUS_OK(nRetVal);
        PixelFormat() = format;
        return XN_STATUS_OK;
    }

    inline XnStatus AllocateData(XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format)
    {
        XnPixelFormat origFormat = PixelFormat();
        PixelFormat() = format;
        XnStatus nRetVal = MapMetaData::AllocateData(nXRes, nYRes);
        if (nRetVal != XN_STATUS_OK)
        {
            PixelFormat() = origFormat;
            return (nRetVal);
        }

        return XN_STATUS_OK;
    }

    inline XnStatus CopyFrom(const ImageMetaData& other)
    {
        xnCopyImageMetaData(&m_image, &other.m_image);
        return MakeDataWritable();
    }

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, XnPixelFormat format, const XnUInt8* pExternalBuffer = NULL)
    {
        XnPixelFormat origFormat = PixelFormat();
        PixelFormat() = format;
        XnStatus nRetVal = MapMetaData::ReAdjust(nXRes, nYRes, pExternalBuffer);
        if (nRetVal != XN_STATUS_OK)
        {
            PixelFormat() = origFormat;
            return (nRetVal);
        }

        return XN_STATUS_OK;
    }

    inline XnPixelFormat PixelFormat() const { return MapMetaData::PixelFormat(); }
    inline XnPixelFormat& PixelFormat() { return MapMetaData::PixelFormatImpl(); }

    inline XnUInt8* WritableData() { return MapMetaData::WritableData(); }

    inline const XnRGB24Pixel* RGB24Data() const { return (const XnRGB24Pixel*)MapMetaData::Data(); }
    inline const XnRGB24Pixel*& RGB24Data() { return (const XnRGB24Pixel*&)MapMetaData::Data(); }
    inline XnRGB24Pixel* WritableRGB24Data() { return (XnRGB24Pixel*)MapMetaData::WritableData(); }

    inline const XnYUV422DoublePixel* YUV422Data() const { return (const XnYUV422DoublePixel*)MapMetaData::Data(); }
    inline const XnYUV422DoublePixel*& YUV422Data() { return (const XnYUV422DoublePixel*&)MapMetaData::Data(); }
    inline XnYUV422DoublePixel* WritableYUV422Data() { return (XnYUV422DoublePixel*)MapMetaData::WritableData(); }

    inline const XnGrayscale8Pixel* Grayscale8Data() const { return (const XnGrayscale8Pixel*)MapMetaData::Data(); }
    inline const XnGrayscale8Pixel*& Grayscale8Data() { return (const XnGrayscale8Pixel*&)MapMetaData::Data(); }
    inline XnGrayscale8Pixel* WritableGrayscale8Data() { return (XnGrayscale8Pixel*)MapMetaData::WritableData(); }

    inline const XnGrayscale16Pixel* Grayscale16Data() const { return (const XnGrayscale16Pixel*)MapMetaData::Data(); }
    inline const XnGrayscale16Pixel*& Grayscale16Data() { return (const XnGrayscale16Pixel*&)MapMetaData::Data(); }
    inline XnGrayscale16Pixel* WritableGrayscale16Data() { return (XnGrayscale16Pixel*)MapMetaData::WritableData(); }

    inline const xn::ImageMap& ImageMap() const { return m_imageMap; }
    inline xn::ImageMap& WritableImageMap() { MakeDataWritable(); return m_writableImageMap; }

    inline const xn::RGB24Map& RGB24Map() const { return m_rgb24Map; }
    inline xn::RGB24Map& WritableRGB24Map() { MakeDataWritable(); return m_writableRgb24Map; }

    inline const xn::Grayscale8Map& Grayscale8Map() const { return m_gray8Map; }
    inline xn::Grayscale8Map& WritableGrayscale8Map() { MakeDataWritable(); return m_writableGray8Map; }

    inline const xn::Grayscale16Map& Grayscale16Map() const { return m_gray16Map; }
    inline xn::Grayscale16Map& WritableGrayscale16Map() { MakeDataWritable(); return m_writableGray16Map; }

    inline const XnImageMetaData* GetUnderlying() const { return &m_image; }
    inline XnImageMetaData* GetUnderlying() { return &m_image; }

private:
    ImageMetaData(const ImageMetaData& other);
    ImageMetaData& operator=(const ImageMetaData&);

    XnImageMetaData m_image;
    const xn::ImageMap m_imageMap;
    xn::ImageMap m_writableImageMap;
    const xn::RGB24Map m_rgb24Map;
    xn::RGB24Map m_writableRgb24Map;
    const xn::Grayscale16Map m_gray16Map;
    xn::Grayscale16Map m_writableGray16Map;
    const xn::Grayscale8Map m_gray8Map;
    xn::Grayscale8Map m_writableGray8Map;
};

class IRMetaData : public MapMetaData
{
public:
    inline IRMetaData() : 
        MapMetaData(XN_PIXEL_FORMAT_GRAYSCALE_16_BIT, (const XnUInt8**)&m_ir.pData),
        m_irMap(const_cast<XnIRPixel*&>(m_ir.pData), MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableIRMap((XnIRPixel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y)
    {
        xnOSMemSet(&m_ir, 0, sizeof(XnIRMetaData));
        m_ir.pMap = MapMetaData::GetUnderlying();
    }

    inline void InitFrom(const IRMetaData& other)
    {
        xnCopyIRMetaData(&m_ir, &other.m_ir);
    }

    inline XnStatus InitFrom(const IRMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnIRPixel* pExternalBuffer)
    {
        InitFrom(other);
        return ReAdjust(nXRes, nYRes, pExternalBuffer);
    }

    XnStatus CopyFrom(const IRMetaData& other)
    {
        xnCopyIRMetaData(&m_ir, &other.m_ir);
        return MakeDataWritable();
    }

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnIRPixel* pExternalBuffer = NULL)
    {
        return MapMetaData::ReAdjust(nXRes, nYRes, (const XnUInt8*)pExternalBuffer);
    }

    inline const XnIRPixel* Data() const { return (const XnIRPixel*)MapMetaData::Data(); }
    inline const XnIRPixel*& Data() { return (const XnIRPixel*&)MapMetaData::Data(); }
    inline XnIRPixel* WritableData() { return (XnIRPixel*)MapMetaData::WritableData(); }

    inline const xn::IRMap& IRMap() const { return m_irMap; }
    inline xn::IRMap& WritableIRMap() { MakeDataWritable(); return m_writableIRMap; }

    inline const XnIRMetaData* GetUnderlying() const { return &m_ir; }
    inline XnIRMetaData* GetUnderlying() { return &m_ir; }

private:
    IRMetaData(const IRMetaData& other);
    IRMetaData& operator=(const IRMetaData&);

    XnIRMetaData m_ir;
    const xn::IRMap m_irMap;
    xn::IRMap m_writableIRMap;
};

class AudioMetaData : public OutputMetaData
{
public:
    inline AudioMetaData() : OutputMetaData(&m_audio.pData)
    {
        xnOSMemSet(&m_audio, 0, sizeof(XnAudioMetaData));
        m_audio.pOutput = OutputMetaData::GetUnderlying();
    }

    inline void InitFrom(const AudioMetaData& other)
    {
        xnCopyAudioMetaData(&m_audio, &other.m_audio);
    }

    inline XnUInt8 NumberOfChannels() const { return m_audio.Wave.nChannels; }
    inline XnUInt8& NumberOfChannels() { return m_audio.Wave.nChannels; }

    inline XnUInt32 SampleRate() const { return m_audio.Wave.nSampleRate; }
    inline XnUInt32& SampleRate() { return m_audio.Wave.nSampleRate; }

    inline XnUInt16 BitsPerSample() const { return m_audio.Wave.nBitsPerSample; }
    inline XnUInt16& BitsPerSample() { return m_audio.Wave.nBitsPerSample; }

    inline const XnAudioMetaData* GetUnderlying() const { return &m_audio; }
    inline XnAudioMetaData* GetUnderlying() { return &m_audio; }

private:
    AudioMetaData(const AudioMetaData& other);
    AudioMetaData& operator=(const AudioMetaData&);

    XnAudioMetaData m_audio;
    XnBool m_bAllocated;
};

class SceneMetaData : public MapMetaData
{
public:
    inline SceneMetaData() : 
        MapMetaData(XN_PIXEL_FORMAT_GRAYSCALE_16_BIT, (const XnUInt8**)&m_scene.pData),
        m_labelMap(const_cast<XnLabel*&>(m_scene.pData), MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y),
        m_writableLabelMap((XnLabel*&)m_pAllocatedData, MapMetaData::GetUnderlying()->Res.X, MapMetaData::GetUnderlying()->Res.Y)
    {
        xnOSMemSet(&m_scene, 0, sizeof(XnSceneMetaData));
        m_scene.pMap = MapMetaData::GetUnderlying();
    }

    inline void InitFrom(const SceneMetaData& other)
    {
        xnCopySceneMetaData(&m_scene, &other.m_scene);
    }

    inline XnStatus InitFrom(const SceneMetaData& other, XnUInt32 nXRes, XnUInt32 nYRes, const XnLabel* pExternalBuffer)
    {
        InitFrom(other);
        return ReAdjust(nXRes, nYRes, pExternalBuffer);
    }

    XnStatus CopyFrom(const SceneMetaData& other)
    {
        xnCopySceneMetaData(&m_scene, &other.m_scene);
        return MakeDataWritable();
    }

    XnStatus ReAdjust(XnUInt32 nXRes, XnUInt32 nYRes, const XnLabel* pExternalBuffer = NULL)
    {
        return MapMetaData::ReAdjust(nXRes, nYRes, (const XnUInt8*)pExternalBuffer);
    }

    inline const XnLabel* Data() const { return (const XnLabel*)MapMetaData::Data(); }
    inline const XnLabel*& Data() { return (const XnLabel*&)MapMetaData::Data(); }
    inline XnLabel* WritableData() { return (XnLabel*)MapMetaData::WritableData(); }

    inline const xn::LabelMap& LabelMap() const { return m_labelMap; }
    inline xn::LabelMap& WritableLabelMap() { MakeDataWritable(); return m_writableLabelMap; }

    inline const XnLabel& operator[](XnUInt32 nIndex) const
    {
        XN_ASSERT(nIndex < (XRes()*YRes()));
        return Data()[nIndex];
    }

    inline const XnLabel& operator()(XnUInt32 x, XnUInt32 y) const
    {
        XN_ASSERT(x < XRes() && y < YRes());
        return (*this)[y*XRes() + x];
    }

    inline const XnSceneMetaData* GetUnderlying() const { return &m_scene; }
    inline XnSceneMetaData* GetUnderlying() { return &m_scene; }

private:
    SceneMetaData(const SceneMetaData& other);
    SceneMetaData& operator=(const SceneMetaData&);

    XnSceneMetaData m_scene;
    const xn::LabelMap m_labelMap;
    xn::LabelMap m_writableLabelMap;
};

class NodeWrapper
{
public:
    friend class Context;

    inline NodeWrapper(XnNodeHandle hNode) : m_hNode(NULL), m_hShuttingDownCallback(NULL)
    {
        NodeWrapper::SetHandle(hNode);
    }

    inline NodeWrapper(const NodeWrapper& other) : m_hNode(NULL), m_hShuttingDownCallback(NULL)
    {
        NodeWrapper::SetHandle(other.GetHandle());
    }

    inline NodeWrapper& operator=(const NodeWrapper& other)
    {
        NodeWrapper::SetHandle(other.GetHandle());
        return *this;
    }

    inline ~NodeWrapper()
    {
        NodeWrapper::SetHandle(NULL);
    }

    inline operator XnNodeHandle() const { return GetHandle(); }

    inline XnNodeHandle GetHandle() const { return m_hNode; }

    
    inline XnBool operator==(const NodeWrapper& other)
    {
        return (GetHandle() == other.GetHandle());
    }

    
    inline XnBool operator!=(const NodeWrapper& other)
    {
        return (GetHandle() != other.GetHandle());
    }

    inline XnBool IsValid() const { return (GetHandle() != NULL); }
    
    
    const XnChar* GetName() const {return xnGetNodeName(GetHandle()); }

    
    inline XnStatus AddRef() { return xnProductionNodeAddRef(GetHandle()); }

    
    inline void Release() 
    {
        NodeWrapper::SetHandle(NULL);
    }

    inline XnStatus XN_API_DEPRECATED("Please use AddRef() instead.") Ref() { return AddRef(); }
    inline void XN_API_DEPRECATED("Please use Release() instead.") Unref() { Release(); }

    inline void SetHandle(XnNodeHandle hNode) 
    { 
        if (m_hNode == hNode)
        {
            return;
        }

        if (m_hNode != NULL)
        {
            XnContext* pContext = xnGetRefContextFromNodeHandle(m_hNode);
            xnContextUnregisterFromShutdown(pContext, m_hShuttingDownCallback);
            xnContextRelease(pContext);
            xnProductionNodeRelease(m_hNode);
        }

        if (hNode != NULL)
        {
            XnStatus nRetVal = xnProductionNodeAddRef(hNode);
            XN_ASSERT(nRetVal == XN_STATUS_OK);

            XnContext* pContext = xnGetRefContextFromNodeHandle(hNode);

            nRetVal = xnContextRegisterForShutdown(pContext, ContextShuttingDownCallback, this, &m_hShuttingDownCallback);
            XN_ASSERT(nRetVal == XN_STATUS_OK);

            xnContextRelease(pContext);
        }

        m_hNode = hNode; 
    }

    inline void TakeOwnership(XnNodeHandle hNode)
    {
        SetHandle(hNode);

        if (hNode != NULL)
        {
            xnProductionNodeRelease(hNode);
        }
    }

private:
    XnNodeHandle m_hNode;
    XnCallbackHandle m_hShuttingDownCallback;

    static void XN_CALLBACK_TYPE ContextShuttingDownCallback(XnContext* /*pContext*/, void* pCookie)
    {
        NodeWrapper* pThis = (NodeWrapper*)pCookie;
        pThis->m_hNode = NULL;
    }
};

class NodeInfo
{
public:
    
    NodeInfo(XnNodeInfo* pInfo) : m_pNeededNodes(NULL), m_bOwnerOfNode(FALSE)
    {
        SetUnderlyingObject(pInfo);
    }

    NodeInfo(const NodeInfo& other) : m_pNeededNodes(NULL), m_bOwnerOfNode(FALSE)
    {
        SetUnderlyingObject(other.m_pInfo);
    }

    ~NodeInfo()
    {
        SetUnderlyingObject(NULL);
    }

    inline NodeInfo& operator=(const NodeInfo& other)
    {
        SetUnderlyingObject(other.m_pInfo);
        return *this;
    }

    inline operator XnNodeInfo*()
    {
        return m_pInfo;
    }

    inline XnStatus SetInstanceName(const XnChar* strName)
    {
        return xnNodeInfoSetInstanceName(m_pInfo, strName);
    }

    inline const XnProductionNodeDescription& GetDescription() const
    {
        return *xnNodeInfoGetDescription(m_pInfo);
    }

    inline const XnChar* GetInstanceName() const
    {
        return xnNodeInfoGetInstanceName(m_pInfo);
    }

    		inline const XnChar* GetCreationInfo() const
    {
        return xnNodeInfoGetCreationInfo(m_pInfo);
    }

    inline NodeInfoList& GetNeededNodes() const;

    inline XnStatus GetInstance(ProductionNode& node) const;

    inline const void* GetAdditionalData() const
    {
        return xnNodeInfoGetAdditionalData(m_pInfo);
    }

private:
    inline void SetUnderlyingObject(XnNodeInfo* pInfo);

    XnNodeInfo* m_pInfo;
    mutable NodeInfoList* m_pNeededNodes;
    XnBool m_bOwnerOfNode; // backwards compatibility
    friend class Context;
};

class Query
{
public:
    inline Query() : m_bAllocated(TRUE)
    {
        xnNodeQueryAllocate(&m_pQuery);
    }

    inline Query(XnNodeQuery* pNodeQuery) : m_pQuery(pNodeQuery), m_bAllocated(FALSE)
    {
    }

    ~Query()
    {
        if (m_bAllocated)
        {
            xnNodeQueryFree(m_pQuery);
        }
    }

    inline const XnNodeQuery* GetUnderlyingObject() const { return m_pQuery; }
    inline XnNodeQuery* GetUnderlyingObject() { return m_pQuery; }

    inline XnStatus SetVendor(const XnChar* strVendor)
    {
        return xnNodeQuerySetVendor(m_pQuery, strVendor);
    }

    inline XnStatus SetName(const XnChar* strName)
    {
        return xnNodeQuerySetName(m_pQuery, strName);
    }

    inline XnStatus SetMinVersion(const XnVersion& minVersion)
    {
        return xnNodeQuerySetMinVersion(m_pQuery, &minVersion);
    }

    inline XnStatus SetMaxVersion(const XnVersion& maxVersion)
    {
        return xnNodeQuerySetMaxVersion(m_pQuery, &maxVersion);
    }

    inline XnStatus AddSupportedCapability(const XnChar* strNeededCapability)
    {
        return xnNodeQueryAddSupportedCapability(m_pQuery, strNeededCapability);
    }

    inline XnStatus AddSupportedMapOutputMode(const XnMapOutputMode& MapOutputMode)
    {
        return xnNodeQueryAddSupportedMapOutputMode(m_pQuery, &MapOutputMode);
    }

    inline XnStatus SetSupportedMinUserPositions(const XnUInt32 nCount)
    {
        return xnNodeQuerySetSupportedMinUserPositions(m_pQuery, nCount);
    }

    inline XnStatus SetExistingNodeOnly(XnBool bExistingNode)
    {
        return xnNodeQuerySetExistingNodeOnly(m_pQuery, bExistingNode);
    }

    inline XnStatus AddNeededNode(const XnChar* strInstanceName)
    {
        return xnNodeQueryAddNeededNode(m_pQuery, strInstanceName);
    }

    inline XnStatus SetCreationInfo(const XnChar* strCreationInfo)
    {
        return xnNodeQuerySetCreationInfo(m_pQuery, strCreationInfo);
    }

private:
    XnNodeQuery* m_pQuery;
    XnBool m_bAllocated;
};

class NodeInfoList
{
public:
    class Iterator
    {
    public:
        friend class NodeInfoList;

        XnBool operator==(const Iterator& other) const
        {
            return m_it.pCurrent == other.m_it.pCurrent;
        }

        XnBool operator!=(const Iterator& other) const
        {
            return m_it.pCurrent != other.m_it.pCurrent;
        }

        inline Iterator& operator++()
        {
            UpdateInternalObject(xnNodeInfoListGetNext(m_it));
            return *this;
        }

        inline Iterator operator++(int)
        {
            XnNodeInfoListIterator curr = m_it;
            UpdateInternalObject(xnNodeInfoListGetNext(m_it));
            return Iterator(curr);
        }

        inline Iterator& operator--()
        {
            UpdateInternalObject(xnNodeInfoListGetPrevious(m_it));
            return *this;
        }

        inline Iterator operator--(int)
        {
            XnNodeInfoListIterator curr = m_it;
            UpdateInternalObject(xnNodeInfoListGetPrevious(m_it));
            return Iterator(curr);
        }

        inline NodeInfo operator*()
        {
            return m_Info;
        }

    private:
        inline Iterator(XnNodeInfoListIterator it) : m_Info(NULL)
        {
            UpdateInternalObject(it);
        }

        inline void UpdateInternalObject(XnNodeInfoListIterator it)
        {
            m_it = it;
            if (xnNodeInfoListIteratorIsValid(it))
            {
                XnNodeInfo* pInfo = xnNodeInfoListGetCurrent(it);
                m_Info = NodeInfo(pInfo);
            }
            else
            {
                m_Info = NodeInfo(NULL);
            }
        }

        NodeInfo m_Info;
        XnNodeInfoListIterator m_it;
    };

    inline NodeInfoList() 
    {
        xnNodeInfoListAllocate(&m_pList);
        m_bAllocated = TRUE;
    }

    inline NodeInfoList(XnNodeInfoList* pList) : m_pList(pList), m_bAllocated(FALSE) {}

    inline ~NodeInfoList()
    {
        FreeImpl();
    }

    inline XnNodeInfoList* GetUnderlyingObject() const { return m_pList; }

    inline void ReplaceUnderlyingObject(XnNodeInfoList* pList) 
    {
        FreeImpl();
        m_pList = pList;
        m_bAllocated = TRUE;
    }

    inline XnStatus Add(XnProductionNodeDescription& description, const XnChar* strCreationInfo, NodeInfoList* pNeededNodes)
    {
        XnNodeInfoList* pList = (pNeededNodes == NULL) ? NULL : pNeededNodes->GetUnderlyingObject();
        return xnNodeInfoListAdd(m_pList, &description, strCreationInfo, pList);
    }

    inline XnStatus AddEx(XnProductionNodeDescription& description, const XnChar* strCreationInfo, NodeInfoList* pNeededNodes, const void* pAdditionalData, XnFreeHandler pFreeHandler)
    {
        XnNodeInfoList* pList = (pNeededNodes == NULL) ? NULL : pNeededNodes->GetUnderlyingObject();
        return xnNodeInfoListAddEx(m_pList, &description, strCreationInfo, pList, pAdditionalData, pFreeHandler);
    }

    inline XnStatus AddNode(NodeInfo& info)
    {
        return xnNodeInfoListAddNode(m_pList, info);
    }

    inline XnStatus AddNodeFromAnotherList(Iterator& it)
    {
        return xnNodeInfoListAddNodeFromList(m_pList, it.m_it);
    }

    inline Iterator Begin() const
    {
        return Iterator(xnNodeInfoListGetFirst(m_pList));
    }

    inline Iterator End() const
    {
        XnNodeInfoListIterator it = { NULL };
        return Iterator(it);
    }

    inline Iterator RBegin() const
    {
        return Iterator(xnNodeInfoListGetLast(m_pList));
    }

    inline Iterator REnd() const
    {
        XnNodeInfoListIterator it = { NULL };
        return Iterator(it);
    }

    inline XnStatus Remove(Iterator& it)
    {
        return xnNodeInfoListRemove(m_pList, it.m_it);
    }

    inline XnStatus Clear()
    {
        return xnNodeInfoListClear(m_pList);
    }

    inline XnStatus Append(NodeInfoList& other)
    {
        return xnNodeInfoListAppend(m_pList, other.GetUnderlyingObject());
    }

    inline XnBool IsEmpty()
    {
        return xnNodeInfoListIsEmpty(m_pList);
    }

    inline XnStatus FilterList(Context& context, Query& query);

private:
    inline void FreeImpl()
    {
        if (m_bAllocated)
        {
            xnNodeInfoListFree(m_pList);
            m_bAllocated = FALSE;
            m_pList = NULL;
        }
    }

    XnNodeInfoList* m_pList;
    XnBool m_bAllocated;
};

class Capability : public NodeWrapper
{
public:
    Capability(XnNodeHandle hNode) : NodeWrapper(hNode) {}
    Capability(const NodeWrapper& node) : NodeWrapper(node) {}
};

class ErrorStateCapability : public Capability
{
public:
    ErrorStateCapability(XnNodeHandle hNode) : Capability(hNode) {}
    ErrorStateCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnStatus GetErrorState() const
    {
        return xnGetNodeErrorState(GetHandle());
    }

    inline XnStatus RegisterToErrorStateChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToNodeErrorStateChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromErrorStateChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromNodeErrorStateChange, GetHandle(), hCallback);
    }
};

class GeneralIntCapability : public Capability
{
public:
    GeneralIntCapability(XnNodeHandle hNode, const XnChar* strCap) : Capability(hNode), m_strCap(strCap) {}
    GeneralIntCapability(const NodeWrapper& node) : Capability(node) {}

    inline void GetRange(XnInt32& nMin, XnInt32& nMax, XnInt32& nStep, XnInt32& nDefault, XnBool& bIsAutoSupported) const
    {
        xnGetGeneralIntRange(GetHandle(), m_strCap, &nMin, &nMax, &nStep, &nDefault, &bIsAutoSupported);
    }

    inline XnInt32 Get()
    {
        XnInt32 nValue;
        xnGetGeneralIntValue(GetHandle(), m_strCap, &nValue);
        return nValue;
    }

    inline XnStatus Set(XnInt32 nValue)
    {
        return xnSetGeneralIntValue(GetHandle(), m_strCap, nValue);
    }

    XnStatus RegisterToValueChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback);

    void UnregisterFromValueChange(XnCallbackHandle hCallback);

private:
    const XnChar* m_strCap;
};

class ProductionNode : public NodeWrapper
{
public:
    inline ProductionNode(XnNodeHandle hNode = NULL) : NodeWrapper(hNode) {}
    inline ProductionNode(const NodeWrapper& other) : NodeWrapper(other) {}

    inline NodeInfo GetInfo() const { return NodeInfo(xnGetNodeInfo(GetHandle())); }

    inline XnStatus AddNeededNode(ProductionNode& needed)
    {
        return xnAddNeededNode(GetHandle(), needed.GetHandle());
    }

    inline XnStatus RemoveNeededNode(ProductionNode& needed)
    {
        return xnRemoveNeededNode(GetHandle(), needed.GetHandle());
    }

    inline void GetContext(Context& context) const;

    inline XnBool IsCapabilitySupported(const XnChar* strCapabilityName) const
    {
        return xnIsCapabilitySupported(GetHandle(), strCapabilityName);
    }

    inline XnStatus SetIntProperty(const XnChar* strName, XnUInt64 nValue)
    {
        return xnSetIntProperty(GetHandle(), strName, nValue);
    }

    inline XnStatus SetRealProperty(const XnChar* strName, XnDouble dValue)
    {
        return xnSetRealProperty(GetHandle(), strName, dValue);
    }

    inline XnStatus SetStringProperty(const XnChar* strName, const XnChar* strValue)
    {
        return xnSetStringProperty(GetHandle(), strName, strValue);
    }

    inline XnStatus SetGeneralProperty(const XnChar* strName, XnUInt32 nBufferSize, const void* pBuffer)
    {
        return xnSetGeneralProperty(GetHandle(), strName, nBufferSize, pBuffer);
    }

    inline XnStatus GetIntProperty(const XnChar* strName, XnUInt64& nValue) const
    {
        return xnGetIntProperty(GetHandle(), strName, &nValue);
    }

    inline XnStatus GetRealProperty(const XnChar* strName, XnDouble &dValue) const
    {
        return xnGetRealProperty(GetHandle(), strName, &dValue);
    }

    inline XnStatus GetStringProperty(const XnChar* strName, XnChar* csValue, XnUInt32 nBufSize) const
    {
        return xnGetStringProperty(GetHandle(), strName, csValue, nBufSize);
    }

    inline XnStatus GetGeneralProperty(const XnChar* strName, XnUInt32 nBufferSize, void* pBuffer) const
    {
        return xnGetGeneralProperty(GetHandle(), strName, nBufferSize, pBuffer);
    }

    inline XnStatus LockForChanges(XnLockHandle* phLock)
    {
        return xnLockNodeForChanges(GetHandle(), phLock);
    }

    inline void UnlockForChanges(XnLockHandle hLock)
    {
        xnUnlockNodeForChanges(GetHandle(), hLock);
    }

    inline XnStatus LockedNodeStartChanges(XnLockHandle hLock)
    {
        return xnLockedNodeStartChanges(GetHandle(), hLock);
    }

    inline void LockedNodeEndChanges(XnLockHandle hLock)
    {
        xnLockedNodeEndChanges(GetHandle(), hLock);
    }

    inline const ErrorStateCapability GetErrorStateCap() const
    {
        return ErrorStateCapability(GetHandle());
    }

    inline ErrorStateCapability GetErrorStateCap()
    {
        return ErrorStateCapability(GetHandle());
    }

    inline GeneralIntCapability GetGeneralIntCap(const XnChar* strCapability)
    {
        return GeneralIntCapability(GetHandle(), strCapability);
    }
};

class DeviceIdentificationCapability : public Capability
{
public:
    DeviceIdentificationCapability(XnNodeHandle hNode) : Capability(hNode) {}
    DeviceIdentificationCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnStatus GetDeviceName(XnChar* strBuffer, XnUInt32 nBufferSize)
    {
        return xnGetDeviceName(GetHandle(), strBuffer, &nBufferSize);
    }

    inline XnStatus GetVendorSpecificData(XnChar* strBuffer, XnUInt32 nBufferSize)
    {
        return xnGetVendorSpecificData(GetHandle(), strBuffer, &nBufferSize);
    }

    inline XnStatus GetSerialNumber(XnChar* strBuffer, XnUInt32 nBufferSize)
    {
        return xnGetSerialNumber(GetHandle(), strBuffer, &nBufferSize);
    }
};

class Device : public ProductionNode
{
public:
    inline Device(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline Device(const NodeWrapper& other) : ProductionNode(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline DeviceIdentificationCapability GetIdentificationCap()
    {
        return DeviceIdentificationCapability(GetHandle());
    }
};

class MirrorCapability : public Capability
{
public:
    inline MirrorCapability(XnNodeHandle hNode) : Capability(hNode) {}
    MirrorCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnStatus SetMirror(XnBool bMirror)
    {
        return xnSetMirror(GetHandle(), bMirror);
    }

    inline XnBool IsMirrored() const
    {
        return xnIsMirrored(GetHandle());
    }

    inline XnStatus RegisterToMirrorChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToMirrorChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromMirrorChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromMirrorChange, GetHandle(), hCallback);
    }
};

class AlternativeViewPointCapability : public Capability
{
public:
    inline AlternativeViewPointCapability(XnNodeHandle hNode) : Capability(hNode) {}
    AlternativeViewPointCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnBool IsViewPointSupported(ProductionNode& otherNode) const
    {
        return xnIsViewPointSupported(GetHandle(), otherNode.GetHandle());
    }

    inline XnStatus SetViewPoint(ProductionNode& otherNode)
    {
        return xnSetViewPoint(GetHandle(), otherNode.GetHandle());
    }

    inline XnStatus ResetViewPoint()
    {
        return xnResetViewPoint(GetHandle());
    }

    inline XnBool IsViewPointAs(ProductionNode& otherNode) const
    {
        return xnIsViewPointAs(GetHandle(), otherNode.GetHandle());
    }

    inline XnStatus RegisterToViewPointChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToViewPointChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromViewPointChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromViewPointChange, GetHandle(), hCallback);
    }
};

class FrameSyncCapability : public Capability
{
public:
    inline FrameSyncCapability(XnNodeHandle hNode) : Capability(hNode) {}
    FrameSyncCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnBool CanFrameSyncWith(Generator& other) const;

    inline XnStatus FrameSyncWith(Generator& other);

    inline XnStatus StopFrameSyncWith(Generator& other);

    inline XnBool IsFrameSyncedWith(Generator& other) const;

    inline XnStatus RegisterToFrameSyncChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToFrameSyncChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromFrameSyncChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromFrameSyncChange, GetHandle(), hCallback);
    }
};

class Generator : public ProductionNode
{
public:
    inline Generator(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline Generator(const NodeWrapper& other) : ProductionNode(other) {}

    inline XnStatus StartGenerating()
    {
        return xnStartGenerating(GetHandle());
    }

    inline XnBool IsGenerating() const
    {
        return xnIsGenerating(GetHandle());
    }

    inline XnStatus StopGenerating()
    {
        return xnStopGenerating(GetHandle());
    }

    inline XnStatus RegisterToGenerationRunningChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle &hCallback)
    {
        return _RegisterToStateChange(xnRegisterToGenerationRunningChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromGenerationRunningChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromGenerationRunningChange, GetHandle(), hCallback);
    }

    inline XnStatus RegisterToNewDataAvailable(StateChangedHandler handler, void* pCookie, XnCallbackHandle &hCallback)
    {
        return _RegisterToStateChange(xnRegisterToNewDataAvailable, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromNewDataAvailable(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromNewDataAvailable, GetHandle(), hCallback);
    }

    inline XnBool IsNewDataAvailable(XnUInt64* pnTimestamp = NULL) const
    {
        return xnIsNewDataAvailable(GetHandle(), pnTimestamp);
    }

    inline XnStatus WaitAndUpdateData()
    {
        return xnWaitAndUpdateData(GetHandle());
    }

    inline XnBool IsDataNew() const
    {
        return xnIsDataNew(GetHandle());
    }

    inline const void* GetData()
    {
        return xnGetData(GetHandle());
    }
    
    inline XnUInt32 GetDataSize() const
    {
        return xnGetDataSize(GetHandle());
    }

    inline XnUInt64 GetTimestamp() const
    {
        return xnGetTimestamp(GetHandle());
    }

    inline XnUInt32 GetFrameID() const
    {
        return xnGetFrameID(GetHandle());
    }

    inline const MirrorCapability GetMirrorCap() const
    { 
        return MirrorCapability(GetHandle()); 
    }

    inline MirrorCapability GetMirrorCap()
    { 
        return MirrorCapability(GetHandle()); 
    }

    inline const AlternativeViewPointCapability GetAlternativeViewPointCap() const
    { 
        return AlternativeViewPointCapability(GetHandle()); 
    }

    inline AlternativeViewPointCapability GetAlternativeViewPointCap()
    { 
        return AlternativeViewPointCapability(GetHandle()); 
    }

    inline const FrameSyncCapability GetFrameSyncCap() const
    {
        return FrameSyncCapability(GetHandle());
    }

    inline FrameSyncCapability GetFrameSyncCap()
    {
        return FrameSyncCapability(GetHandle());
    }
};

class Recorder : public ProductionNode
{
public:
    inline Recorder(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline Recorder(const NodeWrapper& other) : ProductionNode(other) {}

    inline XnStatus Create(Context& context, const XnChar* strFormatName = NULL);

    inline XnStatus SetDestination(XnRecordMedium destType, const XnChar* strDest)
    {
        return xnSetRecorderDestination(GetHandle(), destType, strDest);
    }

    inline XnStatus GetDestination(XnRecordMedium& destType, XnChar* strDest, XnUInt32 nBufSize)
    {
        return xnGetRecorderDestination(GetHandle(), &destType, strDest, nBufSize);
    }

    inline XnStatus AddNodeToRecording(ProductionNode& Node, XnCodecID compression = XN_CODEC_NULL)
    {
        return xnAddNodeToRecording(GetHandle(), Node.GetHandle(), compression);
    }

    inline XnStatus RemoveNodeFromRecording(ProductionNode& Node)
    {
        return xnRemoveNodeFromRecording(GetHandle(), Node.GetHandle());
    }

    inline XnStatus Record()
    {
        return xnRecord(GetHandle());
    }
};

class Player : public ProductionNode
{
public:
    inline Player(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline Player(const NodeWrapper& other) : ProductionNode(other) {}

    inline XnStatus Create(Context& context, const XnChar* strFormatName);

    inline XnStatus SetRepeat(XnBool bRepeat)
    {
        return xnSetPlayerRepeat(GetHandle(), bRepeat);
    }

    inline XnStatus SetSource(XnRecordMedium sourceType, const XnChar* strSource)
    {
        return xnSetPlayerSource(GetHandle(), sourceType, strSource);
    }

    inline XnStatus GetSource(XnRecordMedium &sourceType, XnChar* strSource, XnUInt32 nBufSize) const
    {
        return xnGetPlayerSource(GetHandle(), &sourceType, strSource, nBufSize);
    }

    inline XnStatus ReadNext()
    {
        return xnPlayerReadNext(GetHandle());
    }

    inline XnStatus SeekToTimeStamp(XnInt64 nTimeOffset, XnPlayerSeekOrigin origin)
    {
        return xnSeekPlayerToTimeStamp(GetHandle(), nTimeOffset, origin);
    }

    inline XnStatus SeekToFrame(const XnChar* strNodeName, XnInt32 nFrameOffset, XnPlayerSeekOrigin origin)
    {
        return xnSeekPlayerToFrame(GetHandle(), strNodeName, nFrameOffset, origin);
    }

    inline XnStatus TellTimestamp(XnUInt64& nTimestamp) const
    {
        return xnTellPlayerTimestamp(GetHandle(), &nTimestamp);
    }

    inline XnStatus TellFrame(const XnChar* strNodeName, XnUInt32& nFrame) const
    {
        return xnTellPlayerFrame(GetHandle(), strNodeName, &nFrame);
    }

    inline XnStatus GetNumFrames(const XnChar* strNodeName, XnUInt32& nFrames) const
    {
        return xnGetPlayerNumFrames(GetHandle(), strNodeName, &nFrames);
    }

    inline const XnChar* GetSupportedFormat() const
    {
        return xnGetPlayerSupportedFormat(GetHandle());
    }

    inline XnStatus EnumerateNodes(NodeInfoList& list) const
    {
        XnNodeInfoList* pList;
        XnStatus nRetVal = xnEnumeratePlayerNodes(GetHandle(), &pList);
        XN_IS_STATUS_OK(nRetVal);

        list.ReplaceUnderlyingObject(pList);

        return (XN_STATUS_OK);
    }

    inline XnBool IsEOF() const
    {
        return xnIsPlayerAtEOF(GetHandle());
    }

    inline XnStatus RegisterToEndOfFileReached(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToEndOfFileReached, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromEndOfFileReached(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromEndOfFileReached, GetHandle(), hCallback);
    }

    inline XnStatus SetPlaybackSpeed(XnDouble dSpeed)
    {
        return xnSetPlaybackSpeed(GetHandle(), dSpeed);
    }

    inline XnDouble GetPlaybackSpeed() const
    {
        return xnGetPlaybackSpeed(GetHandle());
    }
};

class CroppingCapability : public Capability
{
public:
    inline CroppingCapability(XnNodeHandle hNode) : Capability(hNode) {}
    CroppingCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnStatus SetCropping(const XnCropping& Cropping)
    {
        return xnSetCropping(GetHandle(), &Cropping);
    }

    inline XnStatus GetCropping(XnCropping& Cropping) const
    {
        return xnGetCropping(GetHandle(), &Cropping);
    }

    inline XnStatus RegisterToCroppingChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToCroppingChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromCroppingChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromCroppingChange, GetHandle(), hCallback);
    }
};

class AntiFlickerCapability : public Capability
{
public:
    inline AntiFlickerCapability(XnNodeHandle hNode) : Capability(hNode) {}
    AntiFlickerCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnStatus SetPowerLineFrequency(XnPowerLineFrequency nFrequency)
    {
        return xnSetPowerLineFrequency(GetHandle(), nFrequency);
    }

    inline XnPowerLineFrequency GetPowerLineFrequency()
    {
        return xnGetPowerLineFrequency(GetHandle());
    }

    inline XnStatus RegisterToPowerLineFrequencyChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToPowerLineFrequencyChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromPowerLineFrequencyChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromPowerLineFrequencyChange, GetHandle(), hCallback);
    }
};

class MapGenerator : public Generator
{
public:
    inline MapGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {}
    inline MapGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnUInt32 GetSupportedMapOutputModesCount() const
    {
        return xnGetSupportedMapOutputModesCount(GetHandle());
    }

    inline XnStatus GetSupportedMapOutputModes(XnMapOutputMode* aModes, XnUInt32& nCount) const
    {
        return xnGetSupportedMapOutputModes(GetHandle(), aModes, &nCount);
    }

    inline XnStatus SetMapOutputMode(const XnMapOutputMode& OutputMode)
    {
        return xnSetMapOutputMode(GetHandle(), &OutputMode);
    }

    inline XnStatus GetMapOutputMode(XnMapOutputMode &OutputMode) const
    {
        return xnGetMapOutputMode(GetHandle(), &OutputMode);
    }

    inline XnUInt32 GetBytesPerPixel() const
    {
        return xnGetBytesPerPixel(GetHandle());
    }

    inline XnStatus RegisterToMapOutputModeChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToMapOutputModeChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromMapOutputModeChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromMapOutputModeChange, GetHandle(), hCallback);
    }

    inline const CroppingCapability GetCroppingCap() const
    {
        return CroppingCapability(GetHandle());
    }

    inline CroppingCapability GetCroppingCap()
    {
        return CroppingCapability(GetHandle());
    }

    inline GeneralIntCapability GetBrightnessCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_BRIGHTNESS);
    }

    inline GeneralIntCapability GetContrastCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_CONTRAST);
    }

    inline GeneralIntCapability GetHueCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_HUE);
    }

    inline GeneralIntCapability GetSaturationCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_SATURATION);
    }

    inline GeneralIntCapability GetSharpnessCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_SHARPNESS);
    }

    inline GeneralIntCapability GetGammaCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_GAMMA);
    }

    inline GeneralIntCapability GetWhiteBalanceCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_COLOR_TEMPERATURE);
    }

    inline GeneralIntCapability GetBacklightCompensationCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_BACKLIGHT_COMPENSATION);
    }

    inline GeneralIntCapability GetGainCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_GAIN);
    }

    inline GeneralIntCapability GetPanCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_PAN);
    }

    inline GeneralIntCapability GetTiltCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_TILT);
    }

    inline GeneralIntCapability GetRollCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_ROLL);
    }

    inline GeneralIntCapability GetZoomCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_ZOOM);
    }

    inline GeneralIntCapability GetExposureCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_EXPOSURE);
    }

    inline GeneralIntCapability GetIrisCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_IRIS);
    }

    inline GeneralIntCapability GetFocusCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_FOCUS);
    }

    inline GeneralIntCapability GetLowLightCompensationCap()
    {
        return GeneralIntCapability(GetHandle(), XN_CAPABILITY_LOW_LIGHT_COMPENSATION);
    }

    inline AntiFlickerCapability GetAntiFlickerCap()
    {
        return AntiFlickerCapability(GetHandle());
    }
};

class UserPositionCapability : public Capability
{
public:
    inline UserPositionCapability(XnNodeHandle hNode = NULL) : Capability(hNode) {}
    UserPositionCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnUInt32 GetSupportedUserPositionsCount() const
    {
        return xnGetSupportedUserPositionsCount(GetHandle());
    }

    inline XnStatus SetUserPosition(XnUInt32 nIndex, const XnBoundingBox3D& Position)
    {
        return xnSetUserPosition(GetHandle(), nIndex, &Position);
    }

    inline XnStatus GetUserPosition(XnUInt32 nIndex, XnBoundingBox3D& Position) const
    {
        return xnGetUserPosition(GetHandle(), nIndex, &Position);
    }

    inline XnStatus RegisterToUserPositionChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToUserPositionChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromUserPositionChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromUserPositionChange, GetHandle(), hCallback);
    }
};

class DepthGenerator : public MapGenerator
{
public:
    inline DepthGenerator(XnNodeHandle hNode = NULL) : MapGenerator(hNode) {}
    inline DepthGenerator(const NodeWrapper& other) : MapGenerator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline void GetMetaData(DepthMetaData& metaData) const 
    {
        xnGetDepthMetaData(GetHandle(), metaData.GetUnderlying());
    }

    inline const XnDepthPixel* GetDepthMap() const
    {
        return xnGetDepthMap(GetHandle());
    }

    inline XnDepthPixel GetDeviceMaxDepth() const
    {
        return xnGetDeviceMaxDepth(GetHandle());
    }

    inline XnStatus GetFieldOfView(XnFieldOfView& FOV) const
    {
        return xnGetDepthFieldOfView(GetHandle(), &FOV);
    }

    inline XnStatus RegisterToFieldOfViewChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToDepthFieldOfViewChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromFieldOfViewChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromDepthFieldOfViewChange, GetHandle(), hCallback);
    }

    inline XnStatus ConvertProjectiveToRealWorld(XnUInt32 nCount, const XnPoint3D aProjective[], XnPoint3D aRealWorld[]) const
    {
        return xnConvertProjectiveToRealWorld(GetHandle(), nCount, aProjective, aRealWorld);
    }

    inline XnStatus ConvertRealWorldToProjective(XnUInt32 nCount, const XnPoint3D aRealWorld[], XnPoint3D aProjective[]) const
    {
        return xnConvertRealWorldToProjective(GetHandle(), nCount, aRealWorld, aProjective);
    }

    inline const UserPositionCapability GetUserPositionCap() const
    {
        return UserPositionCapability(GetHandle());
    }

    inline UserPositionCapability GetUserPositionCap()
    {
        return UserPositionCapability(GetHandle());
    }
};

class MockDepthGenerator : public DepthGenerator
{
public:
    inline MockDepthGenerator(XnNodeHandle hNode = NULL) : DepthGenerator(hNode) {}
    inline MockDepthGenerator(const NodeWrapper& other) : DepthGenerator(other) {}

    XnStatus Create(Context& context, const XnChar* strName = NULL);

    XnStatus CreateBasedOn(DepthGenerator& other, const XnChar* strName = NULL);

    inline XnStatus SetData(XnUInt32 nFrameID, XnUInt64 nTimestamp, XnUInt32 nDataSize, const XnDepthPixel* pDepthMap)
    {
        return xnMockDepthSetData(GetHandle(), nFrameID, nTimestamp, nDataSize, pDepthMap);
    }

    inline XnStatus SetData(const DepthMetaData& depthMD, XnUInt32 nFrameID, XnUInt64 nTimestamp)
    {
        return SetData(nFrameID, nTimestamp, depthMD.DataSize(), depthMD.Data());
    }

    inline XnStatus SetData(const DepthMetaData& depthMD)
    {
        return SetData(depthMD, depthMD.FrameID(), depthMD.Timestamp());
    }
};

class ImageGenerator : public MapGenerator
{
public:
    inline ImageGenerator(XnNodeHandle hNode = NULL) : MapGenerator(hNode) {}
    inline ImageGenerator(const NodeWrapper& other) : MapGenerator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline void GetMetaData(ImageMetaData& metaData) const 
    {
        xnGetImageMetaData(GetHandle(), metaData.GetUnderlying());
    }

    inline const XnRGB24Pixel* GetRGB24ImageMap() const
    {
        return xnGetRGB24ImageMap(GetHandle());
    }

    inline const XnYUV422DoublePixel* GetYUV422ImageMap() const
    {
        return xnGetYUV422ImageMap(GetHandle());
    }

    inline const XnGrayscale8Pixel* GetGrayscale8ImageMap() const
    {
        return xnGetGrayscale8ImageMap(GetHandle());
    }

    inline const XnGrayscale16Pixel* GetGrayscale16ImageMap() const
    {
        return xnGetGrayscale16ImageMap(GetHandle());
    }

    inline const XnUInt8* GetImageMap() const
    {
        return xnGetImageMap(GetHandle());
    }

    inline XnBool IsPixelFormatSupported(XnPixelFormat Format) const
    {
        return xnIsPixelFormatSupported(GetHandle(), Format);
    }

    inline XnStatus SetPixelFormat(XnPixelFormat Format)
    {
        return xnSetPixelFormat(GetHandle(), Format);
    }

    inline XnPixelFormat GetPixelFormat() const
    {
        return xnGetPixelFormat(GetHandle());
    }

    inline XnStatus RegisterToPixelFormatChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToPixelFormatChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromPixelFormatChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromPixelFormatChange, GetHandle(), hCallback);
    }
};

class MockImageGenerator : public ImageGenerator
{
public:
    inline MockImageGenerator(XnNodeHandle hNode = NULL) : ImageGenerator(hNode) {}
    inline MockImageGenerator(const NodeWrapper& other) : ImageGenerator(other) {}

    XnStatus Create(Context& context, const XnChar* strName = NULL);

    XnStatus CreateBasedOn(ImageGenerator& other, const XnChar* strName = NULL);

    inline XnStatus SetData(XnUInt32 nFrameID, XnUInt64 nTimestamp, XnUInt32 nDataSize, const XnUInt8* pImageMap)
    {
        return xnMockImageSetData(GetHandle(), nFrameID, nTimestamp, nDataSize, pImageMap);
    }

    inline XnStatus SetData(const ImageMetaData& imageMD, XnUInt32 nFrameID, XnUInt64 nTimestamp)
    {
        return SetData(nFrameID, nTimestamp, imageMD.DataSize(), imageMD.Data());
    }

    inline XnStatus SetData(const ImageMetaData& imageMD)
    {
        return SetData(imageMD, imageMD.FrameID(), imageMD.Timestamp());
    }
};

class IRGenerator : public MapGenerator
{
public:
    inline IRGenerator(XnNodeHandle hNode = NULL) : MapGenerator(hNode) {}
    inline IRGenerator(const NodeWrapper& other) : MapGenerator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline void GetMetaData(IRMetaData& metaData) const 
    { 
        xnGetIRMetaData(GetHandle(), metaData.GetUnderlying());
    }

    inline const XnIRPixel* GetIRMap() const
    {
        return xnGetIRMap(GetHandle());
    }
};

class MockIRGenerator : public IRGenerator
{
public:
    inline MockIRGenerator(XnNodeHandle hNode = NULL) : IRGenerator(hNode) {}
    inline MockIRGenerator(const NodeWrapper& other) : IRGenerator(other) {}

    XnStatus Create(Context& context, const XnChar* strName = NULL);
    XnStatus CreateBasedOn(IRGenerator& other, const XnChar* strName = NULL);

    inline XnStatus SetData(XnUInt32 nFrameID, XnUInt64 nTimestamp, XnUInt32 nDataSize, const XnIRPixel* pIRMap)
    {
        return xnMockIRSetData(GetHandle(), nFrameID, nTimestamp, nDataSize, pIRMap);
    }

    inline XnStatus SetData(const IRMetaData& irMD, XnUInt32 nFrameID, XnUInt64 nTimestamp)
    {
        return SetData(nFrameID, nTimestamp, irMD.DataSize(), irMD.Data());
    }

    inline XnStatus SetData(const IRMetaData& irMD)
    {
        return SetData(irMD, irMD.FrameID(), irMD.Timestamp());
    }
};

class GestureGenerator : public Generator
{
public:
    inline GestureGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {} 
    inline GestureGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline XnStatus AddGesture(const XnChar* strGesture, XnBoundingBox3D* pArea)
    {
        return xnAddGesture(GetHandle(), strGesture, pArea);
    }

    inline XnStatus RemoveGesture(const XnChar* strGesture)
    {
        return xnRemoveGesture(GetHandle(), strGesture);
    }

    inline XnStatus GetActiveGestures(XnChar*& astrGestures, XnUInt16& nGestures) const
    {
        return xnGetActiveGestures(GetHandle(), &astrGestures, &nGestures);
    }

    inline XnStatus GetAllActiveGestures(XnChar** astrGestures, XnUInt32 nNameLength, XnUInt16& nGestures) const
    {
        return xnGetAllActiveGestures(GetHandle(), astrGestures, nNameLength, &nGestures);
    }

    inline XnStatus EnumerateGestures(XnChar*& astrGestures, XnUInt16& nGestures) const
    {
        return xnEnumerateGestures(GetHandle(), &astrGestures, &nGestures);
    }
    inline XnStatus EnumerateAllGestures(XnChar** astrGestures, XnUInt32 nNameLength, XnUInt16& nGestures) const
    {
        return xnEnumerateAllGestures(GetHandle(), astrGestures, nNameLength, &nGestures);
    }

    inline XnBool IsGestureAvailable(const XnChar* strGesture) const
    {
        return xnIsGestureAvailable(GetHandle(), strGesture);
    }

    inline XnBool IsGestureProgressSupported(const XnChar* strGesture) const
    {
        return xnIsGestureProgressSupported(GetHandle(), strGesture);
    }

    typedef void (XN_CALLBACK_TYPE* GestureRecognized)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pIDPosition, const XnPoint3D* pEndPosition, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* GestureProgress)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pPosition, XnFloat fProgress, void* pCookie);

    XnStatus RegisterGestureCallbacks(GestureRecognized RecognizedCB, GestureProgress ProgressCB, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        GestureCookie* pGestureCookie;
        XN_VALIDATE_ALLOC(pGestureCookie, GestureCookie);
        pGestureCookie->recognizedHandler = RecognizedCB;
        pGestureCookie->progressHandler = ProgressCB;
        pGestureCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterGestureCallbacks(GetHandle(), GestureRecognizedCallback, GestureProgressCallback, pGestureCookie, &pGestureCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pGestureCookie);
            return (nRetVal);
        }

        hCallback = pGestureCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterGestureCallbacks(XnCallbackHandle hCallback)
    {
        GestureCookie* pGestureCookie = (GestureCookie*)hCallback;
        xnUnregisterGestureCallbacks(GetHandle(), pGestureCookie->hCallback);
        xnOSFree(pGestureCookie);
    }

    inline XnStatus RegisterToGestureChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToGestureChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromGestureChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromGestureChange, GetHandle(), hCallback);
    }

    typedef void (XN_CALLBACK_TYPE* GestureIntermediateStageCompleted)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pPosition, void* pCookie);
    XnStatus RegisterToGestureIntermediateStageCompleted(GestureIntermediateStageCompleted handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        GestureIntermediateStageCompletedCookie* pGestureCookie;
        XN_VALIDATE_ALLOC(pGestureCookie, GestureIntermediateStageCompletedCookie);
        pGestureCookie->handler = handler;
        pGestureCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToGestureIntermediateStageCompleted(GetHandle(), GestureIntermediateStageCompletedCallback, pGestureCookie, &pGestureCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pGestureCookie);
            return (nRetVal);
        }

        hCallback = pGestureCookie;

        return (XN_STATUS_OK);
    }
    inline void UnregisterFromGestureIntermediateStageCompleted(XnCallbackHandle hCallback)
    {
        GestureIntermediateStageCompletedCookie* pGestureCookie = (GestureIntermediateStageCompletedCookie*)hCallback;
        xnUnregisterFromGestureIntermediateStageCompleted(GetHandle(), pGestureCookie->hCallback);
        xnOSFree(pGestureCookie);
    }

    typedef void (XN_CALLBACK_TYPE* GestureReadyForNextIntermediateStage)(GestureGenerator& generator, const XnChar* strGesture, const XnPoint3D* pPosition, void* pCookie);
    XnStatus RegisterToGestureReadyForNextIntermediateStage(GestureReadyForNextIntermediateStage handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        GestureReadyForNextIntermediateStageCookie* pGestureCookie;
        XN_VALIDATE_ALLOC(pGestureCookie, GestureReadyForNextIntermediateStageCookie);
        pGestureCookie->handler = handler;
        pGestureCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToGestureReadyForNextIntermediateStage(GetHandle(), GestureReadyForNextIntermediateStageCallback, pGestureCookie, &pGestureCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pGestureCookie);
            return (nRetVal);
        }

        hCallback = pGestureCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromGestureReadyForNextIntermediateStageCallbacks(XnCallbackHandle hCallback)
    {
        GestureReadyForNextIntermediateStageCookie* pGestureCookie = (GestureReadyForNextIntermediateStageCookie*)hCallback;
        xnUnregisterFromGestureReadyForNextIntermediateStage(GetHandle(), pGestureCookie->hCallback);
        xnOSFree(pGestureCookie);
    }

private:
    typedef struct GestureCookie
    {
        GestureRecognized recognizedHandler;
        GestureProgress progressHandler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } GestureCookie;

    static void XN_CALLBACK_TYPE GestureRecognizedCallback(XnNodeHandle hNode, const XnChar* strGesture, const XnPoint3D* pIDPosition, const XnPoint3D* pEndPosition, void* pCookie)
    {
        GestureCookie* pGestureCookie = (GestureCookie*)pCookie;
        GestureGenerator gen(hNode);
        if (pGestureCookie->recognizedHandler != NULL)
        {
            pGestureCookie->recognizedHandler(gen, strGesture, pIDPosition, pEndPosition, pGestureCookie->pUserCookie);
        }
    }

    static void XN_CALLBACK_TYPE GestureProgressCallback(XnNodeHandle hNode, const XnChar* strGesture, const XnPoint3D* pPosition, XnFloat fProgress, void* pCookie)
    {
        GestureCookie* pGestureCookie = (GestureCookie*)pCookie;
        GestureGenerator gen(hNode);
        if (pGestureCookie->progressHandler != NULL)
        {
            pGestureCookie->progressHandler(gen, strGesture, pPosition, fProgress, pGestureCookie->pUserCookie);
        }
    }

    typedef struct GestureIntermediateStageCompletedCookie
    {
        GestureIntermediateStageCompleted handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } GestureIntermediateStageCompletedCookie;

    static void XN_CALLBACK_TYPE GestureIntermediateStageCompletedCallback(XnNodeHandle hNode, const XnChar* strGesture, const XnPoint3D* pPosition, void* pCookie)
    {
        GestureIntermediateStageCompletedCookie* pGestureCookie = (GestureIntermediateStageCompletedCookie*)pCookie;
        GestureGenerator gen(hNode);
        if (pGestureCookie->handler != NULL)
        {
            pGestureCookie->handler(gen, strGesture, pPosition, pGestureCookie->pUserCookie);
        }
    }

    typedef struct GestureReadyForNextIntermediateStageCookie
    {
        GestureReadyForNextIntermediateStage handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } GestureReadyForNextIntermediateStageCookie;

    static void XN_CALLBACK_TYPE GestureReadyForNextIntermediateStageCallback(XnNodeHandle hNode, const XnChar* strGesture, const XnPoint3D* pPosition, void* pCookie)
    {
        GestureReadyForNextIntermediateStageCookie* pGestureCookie = (GestureReadyForNextIntermediateStageCookie*)pCookie;
        GestureGenerator gen(hNode);
        if (pGestureCookie->handler != NULL)
        {
            pGestureCookie->handler(gen, strGesture, pPosition, pGestureCookie->pUserCookie);
        }
    }
};

class SceneAnalyzer : public MapGenerator
{
public:
    inline SceneAnalyzer(XnNodeHandle hNode = NULL) : MapGenerator(hNode) {}
    inline SceneAnalyzer(const NodeWrapper& other) : MapGenerator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline void GetMetaData(SceneMetaData& metaData) const
    {
        xnGetSceneMetaData(GetHandle(), metaData.GetUnderlying());
    }

    inline const XnLabel* GetLabelMap() const
    {
        return xnGetLabelMap(GetHandle());
    }

    inline XnStatus GetFloor(XnPlane3D& Plane) const
    {
        return xnGetFloor(GetHandle(), &Plane);
    }
};

class HandTouchingFOVEdgeCapability : public Capability
{
public:
    inline HandTouchingFOVEdgeCapability(XnNodeHandle hNode) : Capability(hNode) {}
    HandTouchingFOVEdgeCapability(const NodeWrapper& node) : Capability(node) {}

    typedef void (XN_CALLBACK_TYPE* HandTouchingFOVEdge)(HandTouchingFOVEdgeCapability& touchingfov, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, XnDirection eDir, void* pCookie);
    inline XnStatus RegisterToHandTouchingFOVEdge(HandTouchingFOVEdge handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        HandTouchingFOVEdgeCookie* pHandCookie;
        XN_VALIDATE_ALLOC(pHandCookie, HandTouchingFOVEdgeCookie);
        pHandCookie->handler = handler;
        pHandCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToHandTouchingFOVEdge(GetHandle(), HandTouchingFOVEdgeCB, pHandCookie, &pHandCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pHandCookie);
            return (nRetVal);
        }

        hCallback = pHandCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromHandTouchingFOVEdge(XnCallbackHandle hCallback)
    {
        HandTouchingFOVEdgeCookie* pHandCookie = (HandTouchingFOVEdgeCookie*)hCallback;
        xnUnregisterFromHandTouchingFOVEdge(GetHandle(), pHandCookie->hCallback);
        xnOSFree(pHandCookie);
    }
private:
    typedef struct HandTouchingFOVEdgeCookie
    {
        HandTouchingFOVEdge handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } HandTouchingFOVEdgeCookie;

    static void XN_CALLBACK_TYPE HandTouchingFOVEdgeCB(XnNodeHandle hNode, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, XnDirection eDir, void* pCookie)
    {
        HandTouchingFOVEdgeCookie* pHandCookie = (HandTouchingFOVEdgeCookie*)pCookie;
        HandTouchingFOVEdgeCapability cap(hNode);
        if (pHandCookie->handler != NULL)
        {
            pHandCookie->handler(cap, user, pPosition, fTime, eDir, pHandCookie->pUserCookie);
        }
    }

};
class HandsGenerator : public Generator
{
public:
    inline HandsGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {}
    inline HandsGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    typedef void (XN_CALLBACK_TYPE* HandCreate)(HandsGenerator& generator, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* HandUpdate)(HandsGenerator& generator, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* HandDestroy)(HandsGenerator& generator, XnUserID user, XnFloat fTime, void* pCookie);

    inline XnStatus RegisterHandCallbacks(HandCreate CreateCB, HandUpdate UpdateCB, HandDestroy DestroyCB, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        HandCookie* pHandCookie;
        XN_VALIDATE_ALLOC(pHandCookie, HandCookie);
        pHandCookie->createHandler = CreateCB;
        pHandCookie->updateHandler = UpdateCB;
        pHandCookie->destroyHandler = DestroyCB;
        pHandCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterHandCallbacks(GetHandle(), HandCreateCB, HandUpdateCB, HandDestroyCB, pHandCookie, &pHandCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pHandCookie);
            return (nRetVal);
        }

        hCallback = pHandCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterHandCallbacks(XnCallbackHandle hCallback)
    {
        HandCookie* pHandCookie = (HandCookie*)hCallback;
        xnUnregisterHandCallbacks(GetHandle(), pHandCookie->hCallback);
        xnOSFree(pHandCookie);
    }

    inline XnStatus StopTracking(XnUserID user)
    {
        return xnStopTracking(GetHandle(), user);
    }

    inline XnStatus StopTrackingAll()
    {
        return xnStopTrackingAll(GetHandle());
    }

    inline XnStatus StartTracking(const XnPoint3D& ptPosition)
    {
        return xnStartTracking(GetHandle(), &ptPosition);
    }

    inline XnStatus SetSmoothing(XnFloat fSmoothingFactor)
    {
        return xnSetTrackingSmoothing(GetHandle(), fSmoothingFactor);
    }

    inline const HandTouchingFOVEdgeCapability GetHandTouchingFOVEdgeCap() const
    {
        return HandTouchingFOVEdgeCapability(GetHandle());
    }

    inline HandTouchingFOVEdgeCapability GetHandTouchingFOVEdgeCap()
    {
        return HandTouchingFOVEdgeCapability(GetHandle());
    }

private:
    typedef struct HandCookie
    {
        HandCreate createHandler;
        HandUpdate updateHandler;
        HandDestroy destroyHandler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } HandCookie;

    static void XN_CALLBACK_TYPE HandCreateCB(XnNodeHandle hNode, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie)
    {
        HandCookie* pHandCookie = (HandCookie*)pCookie;
        HandsGenerator gen(hNode);
        if (pHandCookie->createHandler != NULL)
        {
            pHandCookie->createHandler(gen, user, pPosition, fTime, pHandCookie->pUserCookie);
        }
    }
    static void XN_CALLBACK_TYPE HandUpdateCB(XnNodeHandle hNode, XnUserID user, const XnPoint3D* pPosition, XnFloat fTime, void* pCookie)
    {
        HandCookie* pHandCookie = (HandCookie*)pCookie;
        HandsGenerator gen(hNode);
        if (pHandCookie->updateHandler != NULL)
        {
            pHandCookie->updateHandler(gen, user, pPosition, fTime, pHandCookie->pUserCookie);
        }
    }
    static void XN_CALLBACK_TYPE HandDestroyCB(XnNodeHandle hNode, XnUserID user, XnFloat fTime, void* pCookie)
    {
        HandCookie* pHandCookie = (HandCookie*)pCookie;
        HandsGenerator gen(hNode);
        if (pHandCookie->destroyHandler != NULL)
        {
            pHandCookie->destroyHandler(gen, user, fTime, pHandCookie->pUserCookie);
        }
    }
};

class SkeletonCapability : public Capability
{
public:
    inline SkeletonCapability(XnNodeHandle hNode) : Capability(hNode) {}
    SkeletonCapability(const NodeWrapper& node) : Capability(node) {}

    inline XnBool IsJointAvailable(XnSkeletonJoint eJoint) const
    {
        return xnIsJointAvailable(GetHandle(), eJoint);
    }

    inline XnBool IsProfileAvailable(XnSkeletonProfile eProfile) const
    {
        return xnIsProfileAvailable(GetHandle(), eProfile);
    }

    inline XnStatus SetSkeletonProfile(XnSkeletonProfile eProfile)
    {
        return xnSetSkeletonProfile(GetHandle(), eProfile);
    }

    inline XnStatus SetJointActive(XnSkeletonJoint eJoint, XnBool bState)
    {
        return xnSetJointActive(GetHandle(), eJoint, bState);
    }

    inline XnBool IsJointActive(XnSkeletonJoint eJoint) const
    {
        return xnIsJointActive(GetHandle(), eJoint);
    }

    inline XnStatus RegisterToJointConfigurationChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToJointConfigurationChange, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromJointConfigurationChange(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromJointConfigurationChange, GetHandle(), hCallback);
    }

    inline XnStatus EnumerateActiveJoints(XnSkeletonJoint* pJoints, XnUInt16& nJoints) const
    {
        return xnEnumerateActiveJoints(GetHandle(), pJoints, &nJoints);
    }

    inline XnStatus GetSkeletonJoint(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointTransformation& Joint) const
    {
        return xnGetSkeletonJoint(GetHandle(), user, eJoint, &Joint);
    }

    inline XnStatus GetSkeletonJointPosition(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointPosition& Joint) const
    {
        return xnGetSkeletonJointPosition(GetHandle(), user, eJoint, &Joint);
    }

    inline XnStatus GetSkeletonJointOrientation(XnUserID user, XnSkeletonJoint eJoint, XnSkeletonJointOrientation& Joint) const
    {
        return xnGetSkeletonJointOrientation(GetHandle(), user, eJoint, &Joint);
    }

    inline XnBool IsTracking(XnUserID user) const
    {
        return xnIsSkeletonTracking(GetHandle(), user);
    }

    inline XnBool IsCalibrated(XnUserID user) const
    {
        return xnIsSkeletonCalibrated(GetHandle(), user);
    }

    inline XnBool IsCalibrating(XnUserID user) const
    {
        return xnIsSkeletonCalibrating(GetHandle(), user);
    }

    inline XnStatus RequestCalibration(XnUserID user, XnBool bForce)
    {
        return xnRequestSkeletonCalibration(GetHandle(), user, bForce);
    }

    inline XnStatus AbortCalibration(XnUserID user)
    {
        return xnAbortSkeletonCalibration(GetHandle(), user);
    }

    inline XnStatus SaveCalibrationDataToFile(XnUserID user, const XnChar* strFileName)
    {
        return xnSaveSkeletonCalibrationDataToFile(GetHandle(), user, strFileName);
    }

    inline XnStatus LoadCalibrationDataFromFile(XnUserID user, const XnChar* strFileName)
    {
        return xnLoadSkeletonCalibrationDataFromFile(GetHandle(), user, strFileName);
    }

    inline XnStatus SaveCalibrationData(XnUserID user, XnUInt32 nSlot)
    {
        return xnSaveSkeletonCalibrationData(GetHandle(), user, nSlot);
    }

    inline XnStatus LoadCalibrationData(XnUserID user, XnUInt32 nSlot)
    {
        return xnLoadSkeletonCalibrationData(GetHandle(), user, nSlot);
    }

    inline XnStatus ClearCalibrationData(XnUInt32 nSlot)
    {
        return xnClearSkeletonCalibrationData(GetHandle(), nSlot);
    }

    inline XnBool IsCalibrationData(XnUInt32 nSlot) const
    {
        return xnIsSkeletonCalibrationData(GetHandle(), nSlot);
    }

    inline XnStatus StartTracking(XnUserID user)
    {
        return xnStartSkeletonTracking(GetHandle(), user);
    }

    inline XnStatus StopTracking(XnUserID user)
    {
        return xnStopSkeletonTracking(GetHandle(), user);
    }

    inline XnStatus Reset(XnUserID user)
    {
        return xnResetSkeleton(GetHandle(), user);
    }

    inline XnBool NeedPoseForCalibration() const
    {
        return xnNeedPoseForSkeletonCalibration(GetHandle());
    }

    inline XnStatus GetCalibrationPose(XnChar* strPose) const
    {
        return xnGetSkeletonCalibrationPose(GetHandle(), strPose);
    }

    inline XnStatus SetSmoothing(XnFloat fSmoothingFactor)
    {
        return xnSetSkeletonSmoothing(GetHandle(), fSmoothingFactor);
    }

    typedef void (XN_CALLBACK_TYPE* CalibrationStart)(SkeletonCapability& skeleton, XnUserID user, void* pCookie);
    typedef void (XN_CALLBACK_TYPE* CalibrationEnd)(SkeletonCapability& skeleton, XnUserID user, XnBool bSuccess, void* pCookie);

    inline XnStatus XN_API_DEPRECATED("Please use RegisterToCalibrationStart/Complete") RegisterCalibrationCallbacks(CalibrationStart CalibrationStartCB, CalibrationEnd CalibrationEndCB, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        SkeletonCookie* pSkeletonCookie;
        XN_VALIDATE_ALLOC(pSkeletonCookie, SkeletonCookie);
        pSkeletonCookie->startHandler = CalibrationStartCB;
        pSkeletonCookie->endHandler = CalibrationEndCB;
        pSkeletonCookie->pUserCookie = pCookie;

#pragma warning (push)
#pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        nRetVal = xnRegisterCalibrationCallbacks(GetHandle(), CalibrationStartBundleCallback, CalibrationEndBundleCallback, pSkeletonCookie, &pSkeletonCookie->hCallback);
#pragma warning (pop)
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pSkeletonCookie);
            return (nRetVal);
        }

        hCallback = pSkeletonCookie;

        return (XN_STATUS_OK);
    }

    inline void XN_API_DEPRECATED("Please use UnregisterFromCalibrationStart/Complete") UnregisterCalibrationCallbacks(XnCallbackHandle hCallback)
    {
        SkeletonCookie* pSkeletonCookie = (SkeletonCookie*)hCallback;
#pragma warning (push)
#pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        xnUnregisterCalibrationCallbacks(GetHandle(), pSkeletonCookie->hCallback);
#pragma warning (pop)
        xnOSFree(pSkeletonCookie);
    }

    inline XnStatus RegisterToCalibrationStart(CalibrationStart handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        CalibrationStartCookie* pCalibrationCookie;
        XN_VALIDATE_ALLOC(pCalibrationCookie, CalibrationStartCookie);
        pCalibrationCookie->handler = handler;
        pCalibrationCookie->pUserCookie = pCookie;
        nRetVal = xnRegisterToCalibrationStart(GetHandle(), CalibrationStartCallback, pCalibrationCookie, &pCalibrationCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pCalibrationCookie);
            return nRetVal;
        }
        hCallback = pCalibrationCookie;
        return XN_STATUS_OK;
    }
    inline XnStatus UnregisterFromCalibrationStart(XnCallbackHandle hCallback)
    {
        CalibrationStartCookie* pCalibrationCookie = (CalibrationStartCookie*)hCallback;
        xnUnregisterFromCalibrationStart(GetHandle(), pCalibrationCookie->hCallback);
        xnOSFree(pCalibrationCookie);
        return XN_STATUS_OK;
    }

    typedef void (XN_CALLBACK_TYPE* CalibrationInProgress)(SkeletonCapability& skeleton, XnUserID user, XnCalibrationStatus calibrationError, void* pCookie);

    inline XnStatus RegisterToCalibrationInProgress(CalibrationInProgress handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        CalibrationInProgressCookie* pSkeletonCookie;
        XN_VALIDATE_ALLOC(pSkeletonCookie, CalibrationInProgressCookie);
        pSkeletonCookie->handler = handler;
        pSkeletonCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToCalibrationInProgress(GetHandle(), CalibrationInProgressCallback, pSkeletonCookie, &pSkeletonCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pSkeletonCookie);
            return (nRetVal);
        }

        hCallback = pSkeletonCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromCalibrationInProgress(XnCallbackHandle hCallback)
    {
        CalibrationInProgressCookie* pSkeletonCookie = (CalibrationInProgressCookie*)hCallback;
        xnUnregisterFromCalibrationInProgress(GetHandle(), pSkeletonCookie->hCallback);
        xnOSFree(pSkeletonCookie);
    }

    typedef void (XN_CALLBACK_TYPE* CalibrationComplete)(SkeletonCapability& skeleton, XnUserID user, XnCalibrationStatus calibrationError, void* pCookie);
    inline XnStatus RegisterToCalibrationComplete(CalibrationComplete handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        CalibrationCompleteCookie* pSkeletonCookie;
        XN_VALIDATE_ALLOC(pSkeletonCookie, CalibrationCompleteCookie);
        pSkeletonCookie->handler = handler;
        pSkeletonCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToCalibrationComplete(GetHandle(), CalibrationCompleteCallback, pSkeletonCookie, &pSkeletonCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pSkeletonCookie);
            return (nRetVal);
        }

        hCallback = pSkeletonCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromCalibrationComplete(XnCallbackHandle hCallback)
    {
        CalibrationCompleteCookie* pSkeletonCookie = (CalibrationCompleteCookie*)hCallback;
        xnUnregisterFromCalibrationComplete(GetHandle(), pSkeletonCookie->hCallback);
        xnOSFree(pSkeletonCookie);
    }
private:
    typedef struct SkeletonCookie
    {
        CalibrationStart startHandler;
        CalibrationEnd endHandler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } SkeletonCookie;

    static void XN_CALLBACK_TYPE CalibrationStartBundleCallback(XnNodeHandle hNode, XnUserID user, void* pCookie)
    {
        SkeletonCookie* pSkeletonCookie = (SkeletonCookie*)pCookie;
        SkeletonCapability cap(hNode);
        if (pSkeletonCookie->startHandler != NULL)
        {
            pSkeletonCookie->startHandler(cap, user, pSkeletonCookie->pUserCookie);
        }
    }

    static void XN_CALLBACK_TYPE CalibrationEndBundleCallback(XnNodeHandle hNode, XnUserID user, XnBool bSuccess, void* pCookie)
    {
        SkeletonCookie* pSkeletonCookie = (SkeletonCookie*)pCookie;
        SkeletonCapability cap(hNode);
        if (pSkeletonCookie->endHandler != NULL)
        {
            pSkeletonCookie->endHandler(cap, user, bSuccess, pSkeletonCookie->pUserCookie);
        }
    }
    typedef struct CalibrationStartCookie
    {
        CalibrationStart handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } CalibrationStartCookie;

    static void XN_CALLBACK_TYPE CalibrationStartCallback(XnNodeHandle hNode, XnUserID user, void* pCookie)
    {
        CalibrationStartCookie* pCalibrationCookie = (CalibrationStartCookie*)pCookie;
        SkeletonCapability cap(hNode);
        if (pCalibrationCookie->handler != NULL)
        {
            pCalibrationCookie->handler(cap, user, pCalibrationCookie->pUserCookie);
        }
    }
    typedef struct CalibrationInProgressCookie
    {
        CalibrationInProgress handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } CalibrationInProgressCookie;

    static void XN_CALLBACK_TYPE CalibrationInProgressCallback(XnNodeHandle hNode, XnUserID user, XnCalibrationStatus calibrationError, void* pCookie)
    {
        CalibrationInProgressCookie* pSkeletonCookie = (CalibrationInProgressCookie*)pCookie;
        SkeletonCapability cap(hNode);
        if (pSkeletonCookie->handler != NULL)
        {
            pSkeletonCookie->handler(cap, user, calibrationError, pSkeletonCookie->pUserCookie);
        }
    }

    typedef struct CalibrationCompleteCookie
    {
        CalibrationComplete handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } CalibrationCompleteCookie;

    static void XN_CALLBACK_TYPE CalibrationCompleteCallback(XnNodeHandle hNode, XnUserID user, XnCalibrationStatus calibrationError, void* pCookie)
    {
        CalibrationCompleteCookie* pSkeletonCookie = (CalibrationCompleteCookie*)pCookie;
        SkeletonCapability cap(hNode);
        if (pSkeletonCookie->handler != NULL)
        {
            pSkeletonCookie->handler(cap, user, calibrationError, pSkeletonCookie->pUserCookie);
        }
    }
};

class PoseDetectionCapability : public Capability
{
public:
    inline PoseDetectionCapability(XnNodeHandle hNode) : Capability(hNode) {}
    PoseDetectionCapability(const NodeWrapper& node) : Capability(node) {}

    typedef void (XN_CALLBACK_TYPE* PoseDetection)(PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, void* pCookie);

    inline XnUInt32 GetNumberOfPoses() const
    {
        return xnGetNumberOfPoses(GetHandle());
    }

    inline XnStatus GetAvailablePoses(XnChar** pstrPoses, XnUInt32& nPoses) const
    {
        return xnGetAvailablePoses(GetHandle(), pstrPoses, &nPoses);
    }
    inline XnStatus GetAllAvailablePoses(XnChar** pstrPoses, XnUInt32 nNameLength, XnUInt32& nPoses) const
    {
        return xnGetAllAvailablePoses(GetHandle(), pstrPoses, nNameLength, &nPoses);
    }

    inline XnStatus StartPoseDetection(const XnChar* strPose, XnUserID user)
    {
        return xnStartPoseDetection(GetHandle(), strPose, user);
    }

    inline XnStatus StopPoseDetection(XnUserID user)
    {
        return xnStopPoseDetection(GetHandle(), user);
    }

    inline XnStatus XN_API_DEPRECATED("Please use RegisterToPoseDetected/RegisterToOutOfPose instead") RegisterToPoseCallbacks(PoseDetection PoseStartCB, PoseDetection PoseEndCB, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        PoseCookie* pPoseCookie;
        XN_VALIDATE_ALLOC(pPoseCookie, PoseCookie);
        pPoseCookie->startHandler = PoseStartCB;
        pPoseCookie->endHandler = PoseEndCB;
        pPoseCookie->pPoseCookie = pCookie;

#pragma warning (push)
#pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        nRetVal = xnRegisterToPoseCallbacks(GetHandle(), PoseDetectionStartBundleCallback, PoseDetectionStartEndBundleCallback, pPoseCookie, &pPoseCookie->hCallback);
#pragma warning (pop)
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pPoseCookie);
            return (nRetVal);
        }

        hCallback = pPoseCookie;

        return (XN_STATUS_OK);
    }

    inline void XN_API_DEPRECATED("Please use UnregisterFromPoseDetected/UnregisterFromOutOfPose instead") UnregisterFromPoseCallbacks(XnCallbackHandle hCallback)
    {
        PoseCookie* pPoseCookie = (PoseCookie*)hCallback;
#pragma warning (push)
#pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        xnUnregisterFromPoseCallbacks(GetHandle(), pPoseCookie->hCallback);
#pragma warning (pop)
        xnOSFree(pPoseCookie);
    }

    inline XnStatus RegisterToPoseDetected(PoseDetection handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        PoseDetectionCookie* pPoseCookie;
        XN_VALIDATE_ALLOC(pPoseCookie, PoseDetectionCookie);
        pPoseCookie->handler = handler;
        pPoseCookie->pPoseCookie = pCookie;

        nRetVal = xnRegisterToPoseDetected(GetHandle(), PoseDetectionCallback, pPoseCookie, &pPoseCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pPoseCookie);
            return nRetVal;
        }
        hCallback = pPoseCookie;
        return XN_STATUS_OK;
    }
    inline XnStatus RegisterToOutOfPose(PoseDetection handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        PoseDetectionCookie* pPoseCookie;
        XN_VALIDATE_ALLOC(pPoseCookie, PoseDetectionCookie);
        pPoseCookie->handler = handler;
        pPoseCookie->pPoseCookie = pCookie;

        nRetVal = xnRegisterToOutOfPose(GetHandle(), PoseDetectionCallback, pPoseCookie, &pPoseCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pPoseCookie);
            return nRetVal;
        }
        hCallback = pPoseCookie;
        return XN_STATUS_OK;
    }
    inline void UnregisterFromPoseDetected(XnCallbackHandle hCallback)
    {
        PoseDetectionCookie* pPoseCookie = (PoseDetectionCookie*)hCallback;
        xnUnregisterFromPoseDetected(GetHandle(), pPoseCookie->hCallback);
        xnOSFree(pPoseCookie);
    }
    inline void UnregisterFromOutOfPose(XnCallbackHandle hCallback)
    {
        PoseDetectionCookie* pPoseCookie = (PoseDetectionCookie*)hCallback;
        xnUnregisterFromOutOfPose(GetHandle(), pPoseCookie->hCallback);
        xnOSFree(pPoseCookie);
    }

    typedef void (XN_CALLBACK_TYPE* PoseInProgress)(PoseDetectionCapability& pose, const XnChar* strPose, XnUserID user, XnPoseDetectionStatus poseError, void* pCookie);
    inline XnStatus RegisterToPoseInProgress(PoseInProgress handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        PoseInProgressCookie* pPoseCookie;
        XN_VALIDATE_ALLOC(pPoseCookie, PoseInProgressCookie);
        pPoseCookie->handler = handler;
        pPoseCookie->pPoseCookie = pCookie;

        nRetVal = xnRegisterToPoseDetectionInProgress(GetHandle(), PoseDetectionInProgressCallback, pPoseCookie, &pPoseCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pPoseCookie);
            return (nRetVal);
        }

        hCallback = pPoseCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromPoseInProgress(XnCallbackHandle hCallback)
    {
        PoseInProgressCookie* pPoseCookie = (PoseInProgressCookie*)hCallback;
        xnUnregisterFromPoseDetectionInProgress(GetHandle(), pPoseCookie->hCallback);
        xnOSFree(pPoseCookie);
    }

private:
    typedef struct PoseCookie
    {
        PoseDetection startHandler;
        PoseDetection endHandler;
        void* pPoseCookie;
        XnCallbackHandle hCallback;
    } PoseCookie;

    static void XN_CALLBACK_TYPE PoseDetectionStartBundleCallback(XnNodeHandle hNode, const XnChar* strPose, XnUserID user, void* pCookie)
    {
        PoseCookie* pPoseCookie = (PoseCookie*)pCookie;
        PoseDetectionCapability cap(hNode);
        if (pPoseCookie->startHandler != NULL)
        {
            pPoseCookie->startHandler(cap, strPose, user, pPoseCookie->pPoseCookie);
        }
    }

    static void XN_CALLBACK_TYPE PoseDetectionStartEndBundleCallback(XnNodeHandle hNode, const XnChar* strPose, XnUserID user, void* pCookie)
    {
        PoseCookie* pPoseCookie = (PoseCookie*)pCookie;
        PoseDetectionCapability cap(hNode);
        if (pPoseCookie->endHandler != NULL)
        {
            pPoseCookie->endHandler(cap, strPose, user, pPoseCookie->pPoseCookie);
        }
    }
    typedef struct PoseDetectionCookie
    {
        PoseDetection handler;
        void* pPoseCookie;
        XnCallbackHandle hCallback;
    } PoseDetectionCookie;
    static void XN_CALLBACK_TYPE PoseDetectionCallback(XnNodeHandle hNode, const XnChar* strPose, XnUserID user, void* pCookie)
    {
        PoseDetectionCookie* pPoseDetectionCookie = (PoseDetectionCookie*)pCookie;
        PoseDetectionCapability cap(hNode);
        if (pPoseDetectionCookie->handler != NULL)
        {
            pPoseDetectionCookie->handler(cap, strPose, user, pPoseDetectionCookie->pPoseCookie);
        }
    }

    typedef struct PoseInProgressCookie
    {
        PoseInProgress handler;
        void* pPoseCookie;
        XnCallbackHandle hCallback;
    } PoseInProgressCookie;

    static void XN_CALLBACK_TYPE PoseDetectionInProgressCallback(XnNodeHandle hNode, const XnChar* strPose, XnUserID user, XnPoseDetectionStatus poseErrors, void* pCookie)
    {
        PoseInProgressCookie* pPoseCookie = (PoseInProgressCookie*)pCookie;
        PoseDetectionCapability cap(hNode);
        if (pPoseCookie->handler != NULL)
        {
            pPoseCookie->handler(cap, strPose, user, poseErrors, pPoseCookie->pPoseCookie);
        }
    }
};

class UserGenerator : public Generator
{
public:
    inline UserGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {}
    inline UserGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    typedef void (XN_CALLBACK_TYPE* UserHandler)(UserGenerator& generator, XnUserID user, void* pCookie);

    inline XnUInt16 GetNumberOfUsers() const
    {
        return xnGetNumberOfUsers(GetHandle());
    }

    inline XnStatus GetUsers(XnUserID aUsers[], XnUInt16& nUsers) const
    {
        return xnGetUsers(GetHandle(), aUsers, &nUsers);
    }

    inline XnStatus GetCoM(XnUserID user, XnPoint3D& com) const
    {
        return xnGetUserCoM(GetHandle(), user, &com);
    }

    inline XnStatus GetUserPixels(XnUserID user, SceneMetaData& smd) const
    {
        return xnGetUserPixels(GetHandle(), user, smd.GetUnderlying());
    }
    
    inline XnStatus RegisterUserCallbacks(UserHandler NewUserCB, UserHandler LostUserCB, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        UserCookie* pUserCookie;
        XN_VALIDATE_ALLOC(pUserCookie, UserCookie);
        pUserCookie->newHandler = NewUserCB;
        pUserCookie->lostHandler = LostUserCB;
        pUserCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterUserCallbacks(GetHandle(), NewUserCallback, LostUserCallback, pUserCookie, &pUserCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pUserCookie);
            return (nRetVal);
        }

        hCallback = pUserCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterUserCallbacks(XnCallbackHandle hCallback)
    {
        UserCookie* pUserCookie = (UserCookie*)hCallback;
        xnUnregisterUserCallbacks(GetHandle(), pUserCookie->hCallback);
        xnOSFree(pUserCookie);
    }

    inline const SkeletonCapability GetSkeletonCap() const
    {
        return SkeletonCapability(GetHandle());
    }

    inline SkeletonCapability GetSkeletonCap()
    {
        return SkeletonCapability(GetHandle());
    }

    inline const PoseDetectionCapability GetPoseDetectionCap() const
    {
        return PoseDetectionCapability(GetHandle());
    }

    inline PoseDetectionCapability GetPoseDetectionCap()
    {
        return PoseDetectionCapability(GetHandle());
    }

    inline XnStatus RegisterToUserExit(UserHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        UserSingleCookie* pUserCookie;
        XN_VALIDATE_ALLOC(pUserCookie, UserSingleCookie);
        pUserCookie->handler = handler;
        pUserCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToUserExit(GetHandle(), UserSingleCallback, pUserCookie, &pUserCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pUserCookie);
            return (nRetVal);
        }

        hCallback = pUserCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromUserExit(XnCallbackHandle hCallback)
    {
        UserSingleCookie* pUserCookie = (UserSingleCookie*)hCallback;
        xnUnregisterFromUserExit(GetHandle(), pUserCookie->hCallback);
        xnOSFree(pUserCookie);
    }

    inline XnStatus RegisterToUserReEnter(UserHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        UserSingleCookie* pUserCookie;
        XN_VALIDATE_ALLOC(pUserCookie, UserSingleCookie);
        pUserCookie->handler = handler;
        pUserCookie->pUserCookie = pCookie;

        nRetVal = xnRegisterToUserReEnter(GetHandle(), UserSingleCallback, pUserCookie, &pUserCookie->hCallback);
        if (nRetVal != XN_STATUS_OK)
        {
            xnOSFree(pUserCookie);
            return (nRetVal);
        }

        hCallback = pUserCookie;

        return (XN_STATUS_OK);
    }

    inline void UnregisterFromUserReEnter(XnCallbackHandle hCallback)
    {
        UserSingleCookie* pUserCookie = (UserSingleCookie*)hCallback;
        xnUnregisterFromUserReEnter(GetHandle(), pUserCookie->hCallback);
        xnOSFree(pUserCookie);
    }

private:
    typedef struct UserCookie
    {
        UserHandler newHandler;
        UserHandler lostHandler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } UserCookie;

    static void XN_CALLBACK_TYPE NewUserCallback(XnNodeHandle hNode, XnUserID user, void* pCookie)
    {
        UserCookie* pUserCookie = (UserCookie*)pCookie;
        UserGenerator gen(hNode);
        if (pUserCookie->newHandler != NULL)
        {
            pUserCookie->newHandler(gen, user, pUserCookie->pUserCookie);
        }
    }

    static void XN_CALLBACK_TYPE LostUserCallback(XnNodeHandle hNode, XnUserID user, void* pCookie)
    {
        UserCookie* pUserCookie = (UserCookie*)pCookie;
        UserGenerator gen(hNode);
        if (pUserCookie->lostHandler != NULL)
        {
            pUserCookie->lostHandler(gen, user, pUserCookie->pUserCookie);
        }
    }

    typedef struct UserSingleCookie
    {
        UserHandler handler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } UserSingleCookie;

    static void XN_CALLBACK_TYPE UserSingleCallback(XnNodeHandle hNode, XnUserID user, void* pCookie)
    {
        UserSingleCookie* pUserCookie = (UserSingleCookie*)pCookie;
        UserGenerator gen(hNode);
        if (pUserCookie->handler != NULL)
        {
            pUserCookie->handler(gen, user, pUserCookie->pUserCookie);
        }
    }
};

class AudioGenerator : public Generator
{
public:
    inline AudioGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {}
    inline AudioGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnStatus Create(Context& context, Query* pQuery = NULL, EnumerationErrors* pErrors = NULL);

    inline void GetMetaData(AudioMetaData& metaData) const
    {
        xnGetAudioMetaData(GetHandle(), metaData.GetUnderlying());
    }

    inline const XnUChar* GetAudioBuffer() const
    {
        return xnGetAudioBuffer(GetHandle());
    }

    inline XnUInt32 GetSupportedWaveOutputModesCount() const
    {
        return xnGetSupportedWaveOutputModesCount(GetHandle());
    }

    inline XnStatus GetSupportedWaveOutputModes(XnWaveOutputMode* aSupportedModes, XnUInt32& nCount) const
    {
        return xnGetSupportedWaveOutputModes(GetHandle(), aSupportedModes, &nCount);
    }

    inline XnStatus SetWaveOutputMode(const XnWaveOutputMode& OutputMode)
    {
        return xnSetWaveOutputMode(GetHandle(), &OutputMode);
    }

    inline XnStatus GetWaveOutputMode(XnWaveOutputMode& OutputMode) const
    {
        return xnGetWaveOutputMode(GetHandle(), &OutputMode);
    }

    inline XnStatus RegisterToWaveOutputModeChanges(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return _RegisterToStateChange(xnRegisterToWaveOutputModeChanges, GetHandle(), handler, pCookie, hCallback);
    }

    inline void UnregisterFromWaveOutputModeChanges(XnCallbackHandle hCallback)
    {
        _UnregisterFromStateChange(xnUnregisterFromWaveOutputModeChanges, GetHandle(), hCallback);
    }
};

class MockAudioGenerator : public AudioGenerator
{
public:
    inline MockAudioGenerator(XnNodeHandle hNode = NULL) : AudioGenerator(hNode) {}
    inline MockAudioGenerator(const NodeWrapper& other) : AudioGenerator(other) {}

    XnStatus Create(Context& context, const XnChar* strName = NULL);

    XnStatus CreateBasedOn(AudioGenerator& other, const XnChar* strName = NULL);

    inline XnStatus SetData(XnUInt32 nFrameID, XnUInt64 nTimestamp, XnUInt32 nDataSize, const XnUInt8* pAudioBuffer)
    {
        return xnMockAudioSetData(GetHandle(), nFrameID, nTimestamp, nDataSize, pAudioBuffer);
    }

    inline XnStatus SetData(const AudioMetaData& audioMD, XnUInt32 nFrameID, XnUInt64 nTimestamp)
    {
        return SetData(nFrameID, nTimestamp, audioMD.DataSize(), audioMD.Data());
    }

    inline XnStatus SetData(const AudioMetaData& audioMD)
    {
        return SetData(audioMD, audioMD.FrameID(), audioMD.Timestamp());
    }
};

class MockRawGenerator : public Generator
{
public:
    MockRawGenerator(XnNodeHandle hNode = NULL) : Generator(hNode) {}
    MockRawGenerator(const NodeWrapper& other) : Generator(other) {}

    inline XnStatus Create(Context& context, const XnChar* strName = NULL);

    inline XnStatus SetData(XnUInt32 nFrameID, XnUInt64 nTimestamp, XnUInt32 nDataSize, const void* pData)
    {
        return xnMockRawSetData(GetHandle(), nFrameID, nTimestamp, nDataSize, pData);
    }

};

class Codec : public ProductionNode
{
public:
    inline Codec(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline Codec(const NodeWrapper& other) : ProductionNode(other) {}

    inline XnStatus Create(Context& context, XnCodecID codecID, ProductionNode& initializerNode);

    inline XnCodecID GetCodecID() const
    {
        return xnGetCodecID(GetHandle());
    }

    inline XnStatus EncodeData(const void* pSrc, XnUInt32 nSrcSize, void* pDst, XnUInt32 nDstSize, XnUInt* pnBytesWritten) const
    {
        return xnEncodeData(GetHandle(), pSrc, nSrcSize, pDst, nDstSize, pnBytesWritten);
    }

    inline XnStatus DecodeData(const void* pSrc, XnUInt32 nSrcSize, void* pDst, XnUInt32 nDstSize, XnUInt* pnBytesWritten) const
    {
        return xnDecodeData(GetHandle(), pSrc, nSrcSize, pDst, nDstSize, pnBytesWritten);
    }
};

class ScriptNode : public ProductionNode
{
public:
    inline ScriptNode(XnNodeHandle hNode = NULL) : ProductionNode(hNode) {}
    inline ScriptNode(const NodeWrapper& other) : ProductionNode(other) {}

    inline const XnChar* GetSupportedFormat()
    {
        return xnScriptNodeGetSupportedFormat(GetHandle());
    }

    inline XnStatus LoadScriptFromFile(const XnChar* strFileName)
    {
        return xnLoadScriptFromFile(GetHandle(), strFileName);
    }

    inline XnStatus LoadScriptFromString(const XnChar* strScript)
    {
        return xnLoadScriptFromString(GetHandle(), strScript);
    }

    inline XnStatus Run(EnumerationErrors* pErrors);
};

class EnumerationErrors
{
public:
    inline EnumerationErrors() : m_pErrors(NULL), m_bAllocated(TRUE) { xnEnumerationErrorsAllocate(&m_pErrors); }

    inline EnumerationErrors(XnEnumerationErrors* pErrors, XnBool bOwn = FALSE) : m_pErrors(pErrors), m_bAllocated(bOwn) {}

    ~EnumerationErrors() { Free(); }

    class Iterator
    {
    public:
        friend class EnumerationErrors;

        XnBool operator==(const Iterator& other) const
        {
            return m_it == other.m_it;
        }

        XnBool operator!=(const Iterator& other) const
        {
            return m_it != other.m_it;
        }

        inline Iterator& operator++()
        {
            m_it = xnEnumerationErrorsGetNext(m_it);
            return *this;
        }

        inline Iterator operator++(int)
        {
            return Iterator(xnEnumerationErrorsGetNext(m_it));
        }

        inline const XnProductionNodeDescription& Description() { return *xnEnumerationErrorsGetCurrentDescription(m_it); }
        inline XnStatus Error() { return xnEnumerationErrorsGetCurrentError(m_it); }

    private:
        inline Iterator(XnEnumerationErrorsIterator it) : m_it(it) {}

        XnEnumerationErrorsIterator m_it;
    };

    inline Iterator Begin() const { return Iterator(xnEnumerationErrorsGetFirst(m_pErrors)); } 
    inline Iterator End() const { return Iterator(NULL); } 

    inline XnStatus ToString(XnChar* csBuffer, XnUInt32 nSize)
    {
        return xnEnumerationErrorsToString(m_pErrors, csBuffer, nSize);
    }

    inline void Free()
    {
        if (m_bAllocated)
        {
            xnEnumerationErrorsFree(m_pErrors);
            m_pErrors = NULL;
            m_bAllocated = FALSE;
        }
    }

    inline XnEnumerationErrors* GetUnderlying() { return m_pErrors; }

private:
    XnEnumerationErrors* m_pErrors;
    XnBool m_bAllocated;
};

class Context
{
public:
    inline Context() : m_pContext(NULL), m_bUsingDeprecatedAPI(FALSE), m_bAllocated(FALSE), m_hShuttingDownCallback(NULL) {}

    inline Context(XnContext* pContext) : m_pContext(NULL), m_bUsingDeprecatedAPI(FALSE), m_bAllocated(FALSE), m_hShuttingDownCallback(NULL)
    {
        SetHandle(pContext);
    }

    inline Context(const Context& other) : m_pContext(NULL), m_bUsingDeprecatedAPI(FALSE), m_bAllocated(FALSE), m_hShuttingDownCallback(NULL)
    {
        SetHandle(other.m_pContext);
    }

    ~Context() 
    { 
        SetHandle(NULL);
    }

    inline Context& operator=(const Context& other)
    {
        SetHandle(other.m_pContext);
        return *this;
    }

    inline XnContext* GetUnderlyingObject() const { return m_pContext; }

    inline XnStatus Init()
    {
        XnContext* pContext = NULL;
        XnStatus nRetVal = xnInit(&pContext);
        XN_IS_STATUS_OK(nRetVal);

        TakeOwnership(pContext);
        m_bAllocated = TRUE;

        return (XN_STATUS_OK);
    }

    inline XnStatus XN_API_DEPRECATED("Use other overload!") RunXmlScript(const XnChar* strScript, EnumerationErrors* pErrors = NULL)
    {
        m_bUsingDeprecatedAPI = TRUE;
        #pragma warning (push)
        #pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        return xnContextRunXmlScript(m_pContext, strScript, pErrors == NULL ? NULL : pErrors->GetUnderlying());
        #pragma warning (pop)
    }

    inline XnStatus RunXmlScript(const XnChar* strScript, ScriptNode& scriptNode, EnumerationErrors* pErrors = NULL)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        XnNodeHandle hScriptNode;
        nRetVal = xnContextRunXmlScriptEx(m_pContext, strScript, pErrors == NULL ? NULL : pErrors->GetUnderlying(), &hScriptNode);
        XN_IS_STATUS_OK(nRetVal);

        scriptNode.TakeOwnership(hScriptNode);
        
        return (XN_STATUS_OK);
    }

    inline XnStatus XN_API_DEPRECATED("Use other overload!") RunXmlScriptFromFile(const XnChar* strFileName, EnumerationErrors* pErrors = NULL)
    {
        m_bUsingDeprecatedAPI = TRUE;
        #pragma warning (push)
        #pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        return xnContextRunXmlScriptFromFile(m_pContext, strFileName, pErrors == NULL ? NULL : pErrors->GetUnderlying());
        #pragma warning (pop)
    }

    inline XnStatus RunXmlScriptFromFile(const XnChar* strFileName, ScriptNode& scriptNode, EnumerationErrors* pErrors = NULL)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hScriptNode;
        nRetVal = xnContextRunXmlScriptFromFileEx(m_pContext, strFileName, pErrors == NULL ? NULL : pErrors->GetUnderlying(), &hScriptNode);
        XN_IS_STATUS_OK(nRetVal);

        scriptNode.TakeOwnership(hScriptNode);

        return (XN_STATUS_OK);
    }

    inline XnStatus XN_API_DEPRECATED("Use other overload!") InitFromXmlFile(const XnChar* strFileName, EnumerationErrors* pErrors = NULL)
    {
        XnContext* pContext = NULL;
        m_bUsingDeprecatedAPI = TRUE;

        #pragma warning (push)
        #pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        XnStatus nRetVal = xnInitFromXmlFile(strFileName, &pContext, pErrors == NULL ? NULL : pErrors->GetUnderlying());
        #pragma warning (pop)
        XN_IS_STATUS_OK(nRetVal);

        TakeOwnership(pContext);
        m_bAllocated = TRUE;

        return (XN_STATUS_OK);
    }

    inline XnStatus InitFromXmlFile(const XnChar* strFileName, ScriptNode& scriptNode, EnumerationErrors* pErrors = NULL)
    {
        XnContext* pContext = NULL;

        XnNodeHandle hScriptNode;
        XnStatus nRetVal = xnInitFromXmlFileEx(strFileName, &pContext, pErrors == NULL ? NULL : pErrors->GetUnderlying(), &hScriptNode);
        XN_IS_STATUS_OK(nRetVal);

        scriptNode.TakeOwnership(hScriptNode);
        TakeOwnership(pContext);
        m_bAllocated = TRUE;

        return (XN_STATUS_OK);
    }

    inline XnStatus XN_API_DEPRECATED("Use other overload!") OpenFileRecording(const XnChar* strFileName)
    {
        m_bUsingDeprecatedAPI = TRUE;
        #pragma warning (push)
        #pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
        return xnContextOpenFileRecording(m_pContext, strFileName);
        #pragma warning (pop)
    }

    inline XnStatus OpenFileRecording(const XnChar* strFileName, ProductionNode& playerNode)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        XnNodeHandle hPlayer;
        nRetVal = xnContextOpenFileRecordingEx(m_pContext, strFileName, &hPlayer);
        XN_IS_STATUS_OK(nRetVal);

        playerNode.TakeOwnership(hPlayer);
        
        return (XN_STATUS_OK);
    }

    inline XnStatus CreateMockNode(XnProductionNodeType type, const XnChar* strName, ProductionNode& mockNode)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        XnNodeHandle hMockNode;
        nRetVal = xnCreateMockNode(m_pContext, type, strName, &hMockNode);
        XN_IS_STATUS_OK(nRetVal);

        mockNode.TakeOwnership(hMockNode);
        
        return (XN_STATUS_OK);
    }

    inline XnStatus CreateMockNodeBasedOn(ProductionNode& originalNode, const XnChar* strName, ProductionNode& mockNode)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hMockNode;
        nRetVal = xnCreateMockNodeBasedOn(m_pContext, originalNode, strName, &hMockNode);
        XN_IS_STATUS_OK(nRetVal);

        mockNode.TakeOwnership(hMockNode);

        return (XN_STATUS_OK);
    }

    inline XnStatus CreateCodec(XnCodecID codecID, ProductionNode& initializerNode, Codec& codec)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hCodec;
        nRetVal =  xnCreateCodec(m_pContext, codecID, initializerNode.GetHandle(), &hCodec);
        XN_IS_STATUS_OK(nRetVal);

        codec.TakeOwnership(hCodec);

        return (XN_STATUS_OK);
    }

    inline XnStatus AddRef()
    {
        return xnContextAddRef(m_pContext);
    }

    inline void Release()
    {
        SetHandle(NULL);
    }

    inline void XN_API_DEPRECATED("You may use Release() instead, or count on dtor") Shutdown()
    {
        if (m_pContext != NULL)
        {
            #pragma warning (push)
            #pragma warning (disable: XN_DEPRECATED_WARNING_IDS)
            xnShutdown(m_pContext);
            #pragma warning (pop)
            m_pContext = NULL;
        }
    }

    inline XnStatus AddLicense(const XnLicense& License)
    {
        return xnAddLicense(m_pContext, &License);
    }

    inline XnStatus EnumerateLicenses(XnLicense*& aLicenses, XnUInt32& nCount) const
    {
        return xnEnumerateLicenses(m_pContext, &aLicenses, &nCount);
    }

    inline static void FreeLicensesList(XnLicense aLicenses[])
    {
        xnFreeLicensesList(aLicenses);
    }

    XnStatus EnumerateProductionTrees(XnProductionNodeType Type, const Query* pQuery, NodeInfoList& TreesList, EnumerationErrors* pErrors = NULL) const
    {
        XnStatus nRetVal = XN_STATUS_OK;

        const XnNodeQuery* pInternalQuery = (pQuery != NULL) ? pQuery->GetUnderlyingObject() : NULL;

        XnNodeInfoList* pList = NULL;
        nRetVal = xnEnumerateProductionTrees(m_pContext, Type, pInternalQuery, &pList, pErrors == NULL ? NULL : pErrors->GetUnderlying());
        XN_IS_STATUS_OK(nRetVal);

        TreesList.ReplaceUnderlyingObject(pList);

        return (XN_STATUS_OK);
    }

    XnStatus CreateAnyProductionTree(XnProductionNodeType type, Query* pQuery, ProductionNode& node, EnumerationErrors* pErrors = NULL)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        XnNodeQuery* pInternalQuery = (pQuery != NULL) ? pQuery->GetUnderlyingObject() : NULL;

        XnNodeHandle hNode;
        nRetVal = xnCreateAnyProductionTree(m_pContext, type, pInternalQuery, &hNode, pErrors == NULL ? NULL : pErrors->GetUnderlying());
        XN_IS_STATUS_OK(nRetVal);

        node.TakeOwnership(hNode);

        return (XN_STATUS_OK);
    }

    XnStatus XN_API_DEPRECATED("Please use other overload") CreateProductionTree(NodeInfo& Tree)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hNode;
        nRetVal = xnCreateProductionTree(m_pContext, Tree, &hNode);
        XN_IS_STATUS_OK(nRetVal);

        Tree.m_bOwnerOfNode = TRUE;

        return (XN_STATUS_OK);
    }

    XnStatus CreateProductionTree(NodeInfo& Tree, ProductionNode& node)
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hNode;
        nRetVal = xnCreateProductionTree(m_pContext, Tree, &hNode);
        XN_IS_STATUS_OK(nRetVal);

        node.TakeOwnership(hNode);

        return (XN_STATUS_OK);
    }

    XnStatus EnumerateExistingNodes(NodeInfoList& list) const
    {
        XnNodeInfoList* pList;
        XnStatus nRetVal = xnEnumerateExistingNodes(m_pContext, &pList);
        XN_IS_STATUS_OK(nRetVal);

        list.ReplaceUnderlyingObject(pList);

        return (XN_STATUS_OK);
    }

    XnStatus EnumerateExistingNodes(NodeInfoList& list, XnProductionNodeType type) const
    {
        XnNodeInfoList* pList;
        XnStatus nRetVal = xnEnumerateExistingNodesByType(m_pContext, type, &pList);
        XN_IS_STATUS_OK(nRetVal);

        list.ReplaceUnderlyingObject(pList);

        return (XN_STATUS_OK);
    }

    XnStatus FindExistingNode(XnProductionNodeType type, ProductionNode& node) const
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hNode;
        nRetVal = xnFindExistingRefNodeByType(m_pContext, type, &hNode);
        XN_IS_STATUS_OK(nRetVal);

        node.TakeOwnership(hNode);

        return (XN_STATUS_OK);
    }

    XnStatus GetProductionNodeByName(const XnChar* strInstanceName, ProductionNode& node) const
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hNode;
        nRetVal = xnGetRefNodeHandleByName(m_pContext, strInstanceName, &hNode);
        XN_IS_STATUS_OK(nRetVal);

        node.TakeOwnership(hNode);

        return (XN_STATUS_OK);
    }

    XnStatus GetProductionNodeInfoByName(const XnChar* strInstanceName, NodeInfo& nodeInfo) const
    {
        XnStatus nRetVal = XN_STATUS_OK;

        XnNodeHandle hNode;
        nRetVal = xnGetRefNodeHandleByName(m_pContext, strInstanceName, &hNode);
        XN_IS_STATUS_OK(nRetVal);

        xnProductionNodeRelease(hNode);

        nodeInfo = NodeInfo(xnGetNodeInfo(hNode));

        return (XN_STATUS_OK);
    }

    inline XnStatus StartGeneratingAll()
    {
        return xnStartGeneratingAll(m_pContext);
    }

    inline XnStatus StopGeneratingAll()
    {
        return xnStopGeneratingAll(m_pContext);
    }

    inline XnStatus SetGlobalMirror(XnBool bMirror)
    {
        return xnSetGlobalMirror(m_pContext, bMirror);
    }

    inline XnBool GetGlobalMirror()
    {
        return xnGetGlobalMirror(m_pContext);
    }

    inline XnStatus GetGlobalErrorState()
    {
        return xnGetGlobalErrorState(m_pContext);
    }

    inline XnStatus RegisterToErrorStateChange(XnErrorStateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        return xnRegisterToGlobalErrorStateChange(m_pContext, handler, pCookie, &hCallback);
    }

    inline void UnregisterFromErrorStateChange(XnCallbackHandle hCallback)
    {
        xnUnregisterFromGlobalErrorStateChange(m_pContext, hCallback);
    }

    inline XnStatus WaitAndUpdateAll()
    {
        return xnWaitAndUpdateAll(m_pContext);
    }

    inline XnStatus WaitAnyUpdateAll()
    {
        return xnWaitAnyUpdateAll(m_pContext);
    }

    inline XnStatus WaitOneUpdateAll(ProductionNode& node)
    {
        return xnWaitOneUpdateAll(m_pContext, node.GetHandle());
    }

    inline XnStatus WaitNoneUpdateAll()
    {
        return xnWaitNoneUpdateAll(m_pContext);
    }

    inline XnStatus AutoEnumerateOverSingleInput(NodeInfoList& List, XnProductionNodeDescription& description, const XnChar* strCreationInfo, XnProductionNodeType InputType, EnumerationErrors* pErrors, Query* pQuery = NULL) const
    {
        return xnAutoEnumerateOverSingleInput(m_pContext, List.GetUnderlyingObject(), &description, strCreationInfo, InputType, pErrors == NULL ? NULL : pErrors->GetUnderlying(), pQuery == NULL ? NULL : pQuery->GetUnderlyingObject());
    }

    inline void SetHandle(XnContext* pContext)
    {
        if (m_pContext == pContext)
        {
            return;
        }

        if (m_pContext != NULL)
        {
            if (m_bUsingDeprecatedAPI && m_bAllocated)
            {
                xnForceShutdown(m_pContext);
            }
            else
            {
                xnContextUnregisterFromShutdown(m_pContext, m_hShuttingDownCallback);
                xnContextRelease(m_pContext);
            }
        }

        if (pContext != NULL)
        {
            XnStatus nRetVal = xnContextAddRef(pContext);
            XN_ASSERT(nRetVal == XN_STATUS_OK);

            nRetVal = xnContextRegisterForShutdown(pContext, ContextShuttingDownCallback, this, &m_hShuttingDownCallback);
            XN_ASSERT(nRetVal == XN_STATUS_OK);
        }

        m_pContext = pContext;
    }

    inline void TakeOwnership(XnContext* pContext)
    {
        SetHandle(pContext);

        if (pContext != NULL)
        {
            xnContextRelease(pContext);
        }
    }

private:
    static void XN_CALLBACK_TYPE ContextShuttingDownCallback(XnContext* /*pContext*/, void* pCookie)
    {
        Context* pThis = (Context*)pCookie;
        pThis->m_pContext = NULL;
    }

    XnContext* m_pContext;
    XnBool m_bUsingDeprecatedAPI;
    XnBool m_bAllocated;
    XnCallbackHandle m_hShuttingDownCallback;
};

class Resolution
{
public:
    inline Resolution(XnResolution res) : m_Res(res)
    {
        m_nXRes = xnResolutionGetXRes(res);
        m_nYRes = xnResolutionGetYRes(res);
        m_strName = xnResolutionGetName(res);
    }

    inline Resolution(XnUInt32 xRes, XnUInt32 yRes) : m_nXRes(xRes), m_nYRes(yRes)
    {
        m_Res = xnResolutionGetFromXYRes(xRes, yRes);
        m_strName = xnResolutionGetName(m_Res);
    }

    inline Resolution(const XnChar* strName)
    {
        m_Res = xnResolutionGetFromName(strName);
        m_nXRes = xnResolutionGetXRes(m_Res);
        m_nYRes = xnResolutionGetYRes(m_Res);
        m_strName = xnResolutionGetName(m_Res);
    }

    inline XnResolution GetResolution() const { return m_Res; }
    inline XnUInt32 GetXResolution() const { return m_nXRes; }
    inline XnUInt32 GetYResolution() const { return m_nYRes; }
    inline const XnChar* GetName() const { return m_strName; }

private:
    XnResolution m_Res;
    XnUInt32 m_nXRes;
    XnUInt32 m_nYRes;
    const XnChar* m_strName;
};

inline XnStatus NodeInfoList::FilterList(Context& context, Query& query)
{
    return xnNodeQueryFilterList(context.GetUnderlyingObject(), query.GetUnderlyingObject(), m_pList);
}

inline void ProductionNode::GetContext(Context& context) const
{
    context.TakeOwnership(xnGetRefContextFromNodeHandle(GetHandle()));
}

inline NodeInfoList& NodeInfo::GetNeededNodes() const
{
    if (m_pNeededNodes == NULL)
    {
        XnNodeInfoList* pList = xnNodeInfoGetNeededNodes(m_pInfo);
        m_pNeededNodes = XN_NEW(NodeInfoList, pList);
    }

    return *m_pNeededNodes;
}

inline void NodeInfo::SetUnderlyingObject(XnNodeInfo* pInfo)
{
    if (m_pNeededNodes != NULL)
    {
        XN_DELETE(m_pNeededNodes);
    }

    m_bOwnerOfNode = FALSE;
    m_pInfo = pInfo;
    m_pNeededNodes = NULL;
}

inline XnBool FrameSyncCapability::CanFrameSyncWith(Generator& other) const
{
    return xnCanFrameSyncWith(GetHandle(), other.GetHandle());
}

inline XnStatus FrameSyncCapability::FrameSyncWith(Generator& other)
{
    return xnFrameSyncWith(GetHandle(), other.GetHandle());
}

inline XnStatus FrameSyncCapability::StopFrameSyncWith(Generator& other)
{
    return xnStopFrameSyncWith(GetHandle(), other.GetHandle());
}

inline XnBool FrameSyncCapability::IsFrameSyncedWith(Generator& other) const
{
    return xnIsFrameSyncedWith(GetHandle(), other.GetHandle());
}

inline XnStatus NodeInfo::GetInstance(ProductionNode& node) const
{
    if (m_pInfo == NULL)
    {
        return XN_STATUS_INVALID_OPERATION;
    }

    XnNodeHandle hNode = xnNodeInfoGetRefHandle(m_pInfo);
    node.TakeOwnership(hNode);

    if (m_bOwnerOfNode)
    {
        xnProductionNodeRelease(hNode);
    }

    return (XN_STATUS_OK);
}

inline XnStatus Device::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateDevice(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus Recorder::Create(Context& context, const XnChar* strFormatName /*= NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateRecorder(context.GetUnderlyingObject(), strFormatName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus Player::Create(Context& context, const XnChar* strFormatName)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreatePlayer(context.GetUnderlyingObject(), strFormatName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus DepthGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateDepthGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockDepthGenerator::Create(Context& context, const XnChar* strName /* = NULL */)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNode(context.GetUnderlyingObject(), XN_NODE_TYPE_DEPTH, strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockDepthGenerator::CreateBasedOn(DepthGenerator& other, const XnChar* strName /* = NULL */)
{
    Context context;
    other.GetContext(context);
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNodeBasedOn(context.GetUnderlyingObject(), other.GetHandle(), strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus ImageGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateImageGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockImageGenerator::Create(Context& context, const XnChar* strName /* = NULL */)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNode(context.GetUnderlyingObject(), XN_NODE_TYPE_IMAGE, strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockImageGenerator::CreateBasedOn(ImageGenerator& other, const XnChar* strName /* = NULL */)
{
    Context context;
    other.GetContext(context);
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNodeBasedOn(context.GetUnderlyingObject(), other.GetHandle(), strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus IRGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateIRGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockIRGenerator::Create(Context& context, const XnChar* strName /* = NULL */)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNode(context.GetUnderlyingObject(), XN_NODE_TYPE_IR, strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockIRGenerator::CreateBasedOn(IRGenerator& other, const XnChar* strName /* = NULL */)
{
    Context context;
    other.GetContext(context);
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNodeBasedOn(context.GetUnderlyingObject(), other.GetHandle(), strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus GestureGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateGestureGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus SceneAnalyzer::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateSceneAnalyzer(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus HandsGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateHandsGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus UserGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateUserGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus AudioGenerator::Create(Context& context, Query* pQuery/*=NULL*/, EnumerationErrors* pErrors/*=NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateAudioGenerator(context.GetUnderlyingObject(), &hNode, pQuery == NULL ? NULL : pQuery->GetUnderlyingObject(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockAudioGenerator::Create(Context& context, const XnChar* strName /* = NULL */)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNode(context.GetUnderlyingObject(), XN_NODE_TYPE_AUDIO, strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockAudioGenerator::CreateBasedOn(AudioGenerator& other, const XnChar* strName /* = NULL */)
{
    Context context;
    other.GetContext(context);
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNodeBasedOn(context.GetUnderlyingObject(), other.GetHandle(), strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus MockRawGenerator::Create(Context& context, const XnChar* strName /*= NULL*/)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateMockNode(context.GetUnderlyingObject(), XN_NODE_TYPE_GENERATOR, strName, &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus Codec::Create(Context& context, XnCodecID codecID, ProductionNode& initializerNode)
{
    XnNodeHandle hNode;
    XnStatus nRetVal = xnCreateCodec(context.GetUnderlyingObject(), codecID, initializerNode.GetHandle(), &hNode);
    XN_IS_STATUS_OK(nRetVal);
    TakeOwnership(hNode);
    return (XN_STATUS_OK);
}

inline XnStatus ScriptNode::Run(EnumerationErrors* pErrors)
{
    return xnScriptNodeRun(GetHandle(), pErrors == NULL ? NULL : pErrors->GetUnderlying());
}

inline void GetVersion(XnVersion& Version)
{
    xnGetVersion(&Version);
}


class StateChangedCallbackTranslator
{
public:
    StateChangedCallbackTranslator(StateChangedHandler handler, void* pCookie) : m_UserHandler(handler), m_pUserCookie(pCookie), m_hCallback(NULL) {}

    XnStatus Register(_XnRegisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode)
    {
        return xnFunc(hNode, StateChangedCallback, this, &m_hCallback);
    }

    void Unregister(_XnUnregisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode)
    {
        xnFunc(hNode, m_hCallback);
    }

    static XnStatus RegisterToUnderlying(_XnRegisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
    {
        XnStatus nRetVal = XN_STATUS_OK;
        
        StateChangedCallbackTranslator* pTrans;
        XN_VALIDATE_NEW(pTrans, StateChangedCallbackTranslator, handler, pCookie);

        nRetVal = pTrans->Register(xnFunc, hNode);
        if (nRetVal != XN_STATUS_OK)
        {
            XN_DELETE(pTrans);
            return (nRetVal);
        }

        hCallback = pTrans;
        
        return (XN_STATUS_OK);
    }

    static XnStatus UnregisterFromUnderlying(_XnUnregisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, XnCallbackHandle hCallback)
    {
        StateChangedCallbackTranslator* pTrans = (StateChangedCallbackTranslator*)hCallback;
        pTrans->Unregister(xnFunc, hNode);
        XN_DELETE(pTrans);
        return XN_STATUS_OK;
    }

private:
    friend class GeneralIntCapability;

    typedef struct StateChangeCookie
    {
        StateChangedHandler userHandler;
        void* pUserCookie;
        XnCallbackHandle hCallback;
    } StateChangeCookie;

    static void XN_CALLBACK_TYPE StateChangedCallback(XnNodeHandle hNode, void* pCookie)
    {
        StateChangedCallbackTranslator* pTrans = (StateChangedCallbackTranslator*)pCookie;
        ProductionNode node(hNode);
        pTrans->m_UserHandler(node, pTrans->m_pUserCookie);
    }

    StateChangedHandler m_UserHandler;
    void* m_pUserCookie;
    XnCallbackHandle m_hCallback;
};

static XnStatus _RegisterToStateChange(_XnRegisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
{
    return StateChangedCallbackTranslator::RegisterToUnderlying(xnFunc, hNode, handler, pCookie, hCallback);
}

static void _UnregisterFromStateChange(_XnUnregisterStateChangeFuncPtr xnFunc, XnNodeHandle hNode, XnCallbackHandle hCallback)
{
    StateChangedCallbackTranslator::UnregisterFromUnderlying(xnFunc, hNode, hCallback);
}

inline XnStatus GeneralIntCapability::RegisterToValueChange(StateChangedHandler handler, void* pCookie, XnCallbackHandle& hCallback)
{
    XnStatus nRetVal = XN_STATUS_OK;

    StateChangedCallbackTranslator* pTrans;
    XN_VALIDATE_NEW(pTrans, StateChangedCallbackTranslator, handler, pCookie);

    nRetVal = xnRegisterToGeneralIntValueChange(GetHandle(), m_strCap, pTrans->StateChangedCallback, pTrans, &pTrans->m_hCallback);
    if (nRetVal != XN_STATUS_OK)
    {
        XN_DELETE(pTrans);
        return (nRetVal);
    }

    hCallback = pTrans;

    return (XN_STATUS_OK);
}

inline void GeneralIntCapability::UnregisterFromValueChange(XnCallbackHandle hCallback)
{
    StateChangedCallbackTranslator* pTrans = (StateChangedCallbackTranslator*)hCallback;
    xnUnregisterFromGeneralIntValueChange(GetHandle(), m_strCap, pTrans->m_hCallback);
    XN_DELETE(pTrans);
}
