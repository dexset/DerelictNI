module derelict.openni.functions;

private
{
    import derelict.openni.types;
}

extern( System )
{
    alias nothrow void function( XnContext** ) da_XnInit;
}

__gshared
{
    da_XnInit XnInit;
}
