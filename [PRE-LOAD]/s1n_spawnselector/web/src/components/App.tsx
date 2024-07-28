import React, {useState, useEffect} from 'react';
import './App.css'
import {debugData} from "../utils/debugData";
import {fetchNui} from "../utils/fetchNui";

import {useNuiEvent} from '../hooks/useNuiEvent';

import nextArrow from '../images/next.png'

debugData([
    {
        action: 'setVisible',
        data: true,
    }
])

interface SetSpawnsData {
    spawns: object[],
    showLastSpawn: boolean,
    Translations: any
}

const App: React.FC = () => {
    const [currentSelected, setSelected] = useState<any | null>(null)
    const [locations, setLocations] = useState<any | null>([])
    const [showLastSpawn, setShowSpawn] = useState(false)
    const [translations, setTranslations] = useState<any>(null);

    useNuiEvent<any>("setSpawns", function (data: SetSpawnsData) {
        setLocations(data.spawns)
        setShowSpawn(data.showLastSpawn)
        setTranslations(data.Translations)
        setSelected(0)
    });

    function next() {
        if (currentSelected !== locations.length - 1) {
            const list = document.getElementsByClassName("spawnsList")[0] as HTMLInputElement
            list.scrollBy(150, 0);
            setSelected(currentSelected + 1)
        } else {
            const list = document.getElementsByClassName("spawnsList")[0] as HTMLInputElement
            setSelected(0)
        }
    }

    function back() {
        if (currentSelected !== 0) {
            const list = document.getElementsByClassName("spawnsList")[0] as HTMLInputElement
            list.scrollBy(-190, 0);
            setSelected(currentSelected - 1)
        } else {
            const list = document.getElementsByClassName("spawnsList")[0] as HTMLInputElement
            setSelected(locations.length - 1)
        }
    }

    useEffect(() => {
        if (translations !== null && currentSelected >= 0) {
            const backImage = document.getElementsByClassName("nui-wrapper")[0] as HTMLInputElement

            if (locations[currentSelected].imageLink) {
                backImage.style.backgroundImage = `url(${locations[currentSelected].imageLink})`
            } else {
                backImage.style.backgroundImage = `url('${window.location.origin}/web/assets/${locations[currentSelected].imageFileName}')`
            }
        }

    }, [currentSelected])

    useEffect(() => {
        if (translations !== null && locations.length > 0) {
            const arrows = document.getElementsByClassName('nextback')[0] as HTMLInputElement
            const locationsdiv = document.getElementsByClassName('spawnsRows')[0] as HTMLInputElement
            const title = document.getElementsByClassName('spawnLocation')[0] as HTMLInputElement

            const locationsLength = locationsdiv.getBoundingClientRect()
            const titleLocation = locationsdiv.getBoundingClientRect()

            arrows.style.width = `${locationsLength.width}px`;
        }

    }, [locations])

    function spawn() {
        fetchNui<any>('spawnPlayer', {location: currentSelected + 1}).then(() => {
            fetchNui<any>('hideFrame', {})
            setSelected(0)
        })
    }


    function lastLocationSpawn() {
        fetchNui<any>('spawnPlayer', {location: -1}).then(() => {
            fetchNui<any>('hideFrame', {})
            setSelected(0)
        })
    }

    return translations === null ? (<></>) : (
        <div className="nui-wrapper">
            {
                locations.length > 0 ?
                    <div className='popup-thing'>
                        <div className='Spawns'>

                            <div className='spawnLocation'>
                                <div className='spawnText'>
                                    <p>{translations.TEXT_DESTINATION}</p>
                                    <h1>{locations[currentSelected].locationName}</h1>
                                </div>
                                {
                                    showLastSpawn == true ?
                                        <div className='spawnButton'>
                                            <button className='lastspawnButton' onClick={() => {
                                                lastLocationSpawn()
                                            }}>{translations.BUTTON_SPAWN_LAST_LOCATION}</button>
                                        </div>
                                        : ' '
                                }

                            </div>
                            <div className='spawnsList'>
                                <div className='nextback'>
                                    <img onClick={() => {
                                        back()
                                    }} src={nextArrow}></img>
                                    <img onClick={() => {
                                        next()
                                    }} src={nextArrow}></img>
                                </div>

                                <div className='spawnsRows'>
                                    {locations.map((spawn: any, index: number) => {
                                        return (
                                            <div style={{backgroundImage: spawn.imageFileName ? `url('${window.location.origin}/web/assets/${spawn.imageFileName}')` : `url(${spawn.imageLink})`}}
                                                 className={currentSelected == index ? 'spawnRow selectedSpawnRow' : 'spawnRow'}>
                                            </div>
                                        )
                                    })}
                                </div>
                                <div className='spawnRightButton'>
                                    <button className='spawnBtn' onClick={() => {
                                        spawn()
                                    }}>
                                        {translations.BUTTON_SPAWN}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    : ''
            }
        </div>
    );
}

export default App;
