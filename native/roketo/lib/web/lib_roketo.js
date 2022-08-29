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

    RoketoSdkJs_contractGetGame: function (idx) {
        const sdk = window.game_sdk
        return sdk.contractGetGame(idx);
    },
}

mergeInto(LibraryManager.library, LibRoketoSdk);
