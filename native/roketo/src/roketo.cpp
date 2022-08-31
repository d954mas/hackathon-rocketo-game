#define EXTENSION_NAME roketo
#define LIB_NAME "roketo"
#define MODULE_NAME "roketo"

#include <dmsdk/sdk.h>
#include <stdlib.h>
#include "game_utils.h"

#if defined(DM_PLATFORM_HTML5)


extern "C" {
    void RoketoSdkJs_initNear();
    bool RoketoSdkJs_isLoggedIn();
    void RoketoSdkJs_login();
    char * RoketoSdkJs_getAccountId();
    void RoketoSdkJs_contractGetGame(int idx);
     void RoketoSdkJs_contractCreateGame(char const * firstPlayer,char const * secondPlayer, int fieldSize);
    void RoketoSdkJs_contractGetGamesList(char const * player);
    void RoketoSdkJs_contractGetGamesActiveList(char const * player);
    void RoketoSdkJs_streamBuyPremium();
    void RoketoSdkJs_streamIsPremium();
    void RoketoSdkJs_streamCalculateEndTimestamp();

}

static int RoketoSdkJs_initNearLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 0);
    RoketoSdkJs_initNear();
    return 0;
}

static int RoketoSdkJs_isLoggedInLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 1);
    game_utils::check_arg_count(L, 0);
    bool result = RoketoSdkJs_isLoggedIn();
    lua_pushboolean(L,result);
    return 1;
}

static int RoketoSdkJs_loginLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 0);
    RoketoSdkJs_login();
    return 0;
}

static int RoketoSdkJs_getAccountIdLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 1);
    game_utils::check_arg_count(L, 0);
    char * accountId = RoketoSdkJs_getAccountId();
    lua_pushstring(L,accountId);
    free(accountId);
    return 1;
}

static int RoketoSdkJs_contractGetGameLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 1);
    int idx = lua_tonumber(L,1);
    RoketoSdkJs_contractGetGame(idx);
    return 0;
}

static int RoketoSdkJs_contractCreateGameLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 3);
    const char * firstPlayer = lua_tostring (L,1);
    const char * secondPlayer = lua_tostring (L,2);
    int fieldSize = lua_tonumber(L,3);
    RoketoSdkJs_contractCreateGame(firstPlayer,secondPlayer,fieldSize);
    return 0;
}

static int RoketoSdkJs_contractGetGamesListLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 1);
    const char * player = lua_tostring (L,1);
    RoketoSdkJs_contractGetGamesList(player);
    return 0;
}

static int RoketoSdkJs_contractGetGamesActiveListLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 1);
    const char * player = lua_tostring (L,1);
    RoketoSdkJs_contractGetGamesActiveList(player);
    return 0;
}

static int RoketoSdkJs_streamBuyPremiumLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 0);
    RoketoSdkJs_streamBuyPremium();
    return 0;
}

static int RoketoSdkJs_streamIsPremiumLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 0);
    RoketoSdkJs_streamIsPremium();
    return 0;
}

static int RoketoSdkJs_streamCalculateEndTimestampLua(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    game_utils::check_arg_count(L, 0);
    RoketoSdkJs_streamCalculateEndTimestamp();
    return 0;
}



// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"init_near", RoketoSdkJs_initNearLua},
    {"is_logged_in", RoketoSdkJs_isLoggedInLua},
    {"login", RoketoSdkJs_loginLua},
    {"get_account_id", RoketoSdkJs_getAccountIdLua},
    {"contract_create_game", RoketoSdkJs_contractCreateGameLua},
    {"contract_get_game", RoketoSdkJs_contractGetGameLua},
    {"contract_get_games_list", RoketoSdkJs_contractGetGamesListLua},
    {"contract_get_games_active_list", RoketoSdkJs_contractGetGamesActiveListLua},
    {"stream_buy_premium", RoketoSdkJs_streamBuyPremiumLua},
    {"stream_is_premium", RoketoSdkJs_streamIsPremiumLua},
    {"stream_calculate_end_timestamp", RoketoSdkJs_streamCalculateEndTimestampLua},
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
