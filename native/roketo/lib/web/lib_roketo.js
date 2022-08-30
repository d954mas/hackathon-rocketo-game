// https://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html

var LibRoketoSdk = {
    RoketoSdkJs_initNear: function () {
        const sdk = window.game_sdk
        sdk.initNear();
    },

    RoketoSdkJs_isLoggedIn: function () {
        const sdk = window.game_sdk
        return sdk.isLoggedIn();
    },

    RoketoSdkJs_login: function () {
        const sdk = window.game_sdk
        return sdk.login();
    },
    RoketoSdkJs_getAccountId: function () {
        const sdk = window.game_sdk
        let accountId = sdk.getAccountId();
        return allocate(intArrayFromString(accountId.toString()), ALLOC_NORMAL)

    },

    RoketoSdkJs_contractGetGame: function (idx) {
        const sdk = window.game_sdk
        return sdk.contractGetGame(idx);
    },

    RoketoSdkJs_contractCreateGame: function (first_player, second_player, field_size) {
        const sdk = window.game_sdk
        return sdk.contractCreateGame(UTF8ToString(first_player),UTF8ToString(second_player), field_size);
    },
}

mergeInto(LibraryManager.library, LibRoketoSdk);
