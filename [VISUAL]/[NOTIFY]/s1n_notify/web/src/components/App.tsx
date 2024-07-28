import React, {useState} from 'react';
import './App.css'
import {debugData} from "../utils/debugData";
import ShowToast from "./notification/ToastFunc";
import { useNuiEvent } from '../hooks/useNuiEvent';
import {fetchNui} from "../utils/fetchNui";

// This will set the NUI to visible if we are
// developing in browser
debugData([
    {
        action: 'setVisible',
        data: true,
    }
])

interface Notification {
    title: string;
    message: string;
    type: string;
    theme: "white" | "colorful";
    position: "top-left" | "top-right" | "bottom-left" | "bottom-right";
    duration: number;
}

const App: React.FC = () => {
    const [config, setConfig] = useState<object>({});

    useNuiEvent<object>('setConfig', (data) => {
        fetchNui('dataSent');

        // @ts-ignore
        for (const [type, typeData] of Object.entries(data)) {
            // @ts-ignore
            if (typeData.sound) {
                if (typeData.sound.enable) {
                    const audioData = typeData.sound;

                    // From the build folder
                    // @ts-ignore
                    data[type].sound = new Audio(`static/media/${typeData.sound.source}`);

                    // @ts-ignore
                    data[type].sound.volume = audioData.volume !== undefined ? audioData.volume : 1;
                } else {
                    // @ts-ignore
                    delete data[type].sound;
                }
            }
        }

        setConfig(data);
    });

    useNuiEvent<Notification>('myAction', (data) => {
        // @ts-ignore
        if (config[data.type].sound !== undefined) {
            // @ts-ignore
            config[data.type].sound.play();
        }

        ShowToast({
            title: data.title,
            message: data.message,
            type: data.type,
            theme: data.theme,
            position: data.position,
            duration: data.duration,
            // @ts-ignore
            icon: config[data.type].icon,
            // @ts-ignore
            color: config[data.type].color
        });
    })

    return <div></div>;
}

export default App;
