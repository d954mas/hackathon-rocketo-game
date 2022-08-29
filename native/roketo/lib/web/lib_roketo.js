// https://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html

var LibRoketoSdk = {
    RoketoSdkJs_initNear: function () {
        const sdk = window.game_sdk //Getting the SDK
        sdk.initNear(); //Initializing the SDK, call as early as possible
    },

    RoketoSdkJs_isLoggedIn: function () {
        const sdk = window.game_sdk //Getting the SDK
        return sdk.isLoggedIn(); //Initializing the SDK, call as early as possible
    },

    RoketoSdkJs_login: function () {
        const sdk = window.game_sdk //Getting the SDK
        return sdk.login(); //Initializing the SDK, call as early as possible
    },
}

mergeInto(LibraryManager.library, LibRoketoSdk);
