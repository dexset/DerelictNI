module derelict.openni.ni;

public
{
    import derelict.openni.types;
    import derelict.openni.constants;
    import derelict.openni.functions;
}

private
{
    import derelict.util.loader;
    import derelict.util.exception;
    import derelict.util.system;
    static if( Derelict_OS_Posix )
    {
        enum libNames = "libOpenNI.so";
    }
    else
        static assert( 0, "Need to implement OpenNI libNames for this operating system." );
}

class DerelictONILoader : SharedLibLoader
{
    protected
    {
        this()
        {
            super(libNames);
        }

        override void loadSymbols()
        {

        }
    }
}

__gshared DerelictONILoader DerelictONI;

shared static this()
{
    DerelictONI = new DerelictONILoader;
}

shared static ~this()
{
    DerelictONI.unload();
}
