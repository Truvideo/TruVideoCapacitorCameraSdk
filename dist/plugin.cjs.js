'use strict';

var core = require('@capacitor/core');

const CameraPlugin = core.registerPlugin('CameraPlugin', {
    web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.CameraPluginWeb()),
});

class CameraPluginWeb extends core.WebPlugin {
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    CameraPluginWeb: CameraPluginWeb
});

exports.CameraPlugin = CameraPlugin;
//# sourceMappingURL=plugin.cjs.js.map
