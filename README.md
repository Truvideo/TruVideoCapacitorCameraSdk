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
* [Interfaces](#interfaces)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initCameraScreen(...)

```typescript
initCameraScreen(options: { value: CameraConfiguration; }) => Promise<{ value: string; }>
```

| Param         | Type                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| **`options`** | <code>{ value: <a href="#cameraconfiguration">CameraConfiguration</a>; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### Interfaces


#### CameraConfiguration

| Prop                   | Type                                                |
| ---------------------- | --------------------------------------------------- |
| **`lensFacing`**       | <code><a href="#lensfacing">LensFacing</a></code>   |
| **`flashMode`**        | <code><a href="#flashmode">FlashMode</a></code>     |
| **`orientation`**      | <code><a href="#orientation">Orientation</a></code> |
| **`outputPath`**       | <code>string</code>                                 |
| **`frontResolutions`** | <code>string[]</code>                               |
| **`frontResolution`**  | <code>string</code>                                 |
| **`backResolutions`**  | <code>string[]</code>                               |
| **`backResolution`**   | <code>string</code>                                 |
| **`mode`**             | <code><a href="#mode">Mode</a></code>               |


### Enums


#### LensFacing

| Members     | Value                |
| ----------- | -------------------- |
| **`Back`**  | <code>'back'</code>  |
| **`Front`** | <code>'front'</code> |


#### FlashMode

| Members   | Value              |
| --------- | ------------------ |
| **`Off`** | <code>'off'</code> |
| **`On`**  | <code>'on'</code>  |


#### Orientation

| Members               | Value                          |
| --------------------- | ------------------------------ |
| **`Portrait`**        | <code>'portrait'</code>        |
| **`LandscapeLeft`**   | <code>'landscapeLeft'</code>   |
| **`LandscapeRight`**  | <code>'landscapeRight'</code>  |
| **`PortraitReverse`** | <code>'portraitReverse'</code> |


#### Mode

| Members               | Value                          |
| --------------------- | ------------------------------ |
| **`Video`**           | <code>'video'</code>           |
| **`Picture`**         | <code>'picture'</code>         |
| **`VideoAndPicture`** | <code>'videoAndPicture'</code> |

</docgen-api>
