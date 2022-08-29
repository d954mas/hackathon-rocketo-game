#define EXTENSION_NAME roketo
#define LIB_NAME "roketo"
#define MODULE_NAME "roketo"

#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_HTML5)


extern "C" {
    void RoketoSdkJs_testlib();
    void RoketoSdkJs_initNear();
}

static int RoketoSdkJs_testlibLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    RoketoSdkJs_testlib();
    return 0;
}

static int RoketoSdkJs_initNearLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    RoketoSdkJs_initNear();
    return 0;
}



// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"test_lib", RoketoSdkJs_testlibLua},
    {"init_near", RoketoSdkJs_initNearLua},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);

    luaL_register(L, MODULE_NAME, Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

dmExtension::Result InitializeRoketoSdk(dmExtension::Params* params)
{
    LuaInit(params->m_L);
    return dmExtension::RESULT_OK;
}

dmExtension::Result FinalizeRoketoSdk(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

#else // unsupported platforms

dmExtension::Result InitializeRoketoSdk(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

dmExtension::Result FinalizeRoketoSdk(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

#endif

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, 0, 0, InitializeRoketoSdk, 0, 0, FinalizeRoketoSdk)
