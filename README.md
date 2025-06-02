# truvideo-capacitor-camera-sdk

camera module functionality of Truvideo video camera sdk

## Install

```bash
npm install truvideo-capacitor-camera-sdk
npx cap sync
```

## API

<docgen-index>

* [`initCameraScreen(...)`](#initcamerascreen)
* [`addListener('cameraEvent', ...)`](#addlistenercameraevent-)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initCameraScreen(...)

```typescript
initCameraScreen(options: { configuration: string; }) => Promise<{ result: string; }>
```

| Param         | Type                                    |
| ------------- | --------------------------------------- |
| **`options`** | <code>{ configuration: string; }</code> |

**Returns:** <code>Promise&lt;{ result: string; }&gt;</code>

--------------------


### addListener('cameraEvent', ...)

```typescript
addListener(eventName: 'cameraEvent', listenerFunc: (event: { cameraEvent: { type: string; createdAt: number; }; }) => void) => PluginListenerHandle
```

| Param              | Type                                                                                    |
| ------------------ | --------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'cameraEvent'</code>                                                              |
| **`listenerFunc`** | <code>(event: { cameraEvent: { type: string; createdAt: number; }; }) =&gt; void</code> |

**Returns:** <code><a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
