// https://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html

var LibRoketoSdk = {

    RoketoSdkJs_testlib: function () {
        const sdk = window.game_sdk //Getting the SDK
        sdk.testLib(); //Initializing the SDK, call as early as possible
    },

}

mergeInto(LibraryManager.library, LibRoketoSdk);
