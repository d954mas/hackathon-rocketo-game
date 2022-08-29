#define EXTENSION_NAME roketo
#define LIB_NAME "roketo"
#define MODULE_NAME "roketo"

#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_HTML5)


extern "C" {
   void RoketoSdkJs_initNear();
    bool RoketoSdkJs_isLoggedIn();
    void RoketoSdkJs_login();

}

static int RoketoSdkJs_initNearLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    RoketoSdkJs_initNear();
    return 0;
}

static int RoketoSdkJs_isLoggedInLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 1);
    bool result = RoketoSdkJs_isLoggedIn();
    lua_pushboolean(L,result);
    return 1;
}

static int RoketoSdkJs_loginLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    RoketoSdkJs_login();
    return 0;
}



// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"init_near", RoketoSdkJs_initNearLua},
    {"is_logged_in", RoketoSdkJs_isLoggedInLua},
    {"login", RoketoSdkJs_loginLua},
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
