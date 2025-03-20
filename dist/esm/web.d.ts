import { WebPlugin } from '@capacitor/core';
import type { CameraPluginPlugin } from './definitions';
export declare class CameraPluginWeb extends WebPlugin implements CameraPluginPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
