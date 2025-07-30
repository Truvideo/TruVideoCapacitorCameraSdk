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
* [`initARCameraScreen(...)`](#initarcamerascreen)
* [`initScanerScreen(...)`](#initscanerscreen)
* [`version()`](#version)
* [`environment()`](#environment)
* [`isAugmentedRealityInstalled()`](#isaugmentedrealityinstalled)
* [`isAugmentedRealitySupported()`](#isaugmentedrealitysupported)
* [`requestInstallAugmentedReality()`](#requestinstallaugmentedreality)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initCameraScreen(...)

```typescript
initCameraScreen(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### initARCameraScreen(...)

```typescript
initARCameraScreen(configuration: string) => Promise<{ value: string; }>
```

| Param               | Type                |
| ------------------- | ------------------- |
| **`configuration`** | <code>string</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### initScanerScreen(...)

```typescript
initScanerScreen(configuration: string) => Promise<{ value: string; }>
```

| Param               | Type                |
| ------------------- | ------------------- |
| **`configuration`** | <code>string</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### version()

```typescript
version() => Promise<string>
```

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### environment()

```typescript
environment() => Promise<string>
```

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### isAugmentedRealityInstalled()

```typescript
isAugmentedRealityInstalled() => Promise<string>
```

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### isAugmentedRealitySupported()

```typescript
isAugmentedRealitySupported() => Promise<string>
```

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### requestInstallAugmentedReality()

```typescript
requestInstallAugmentedReality() => Promise<string>
```

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------

</docgen-api>
