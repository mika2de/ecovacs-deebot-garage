const ecovacsDeebot = require('ecovacs-deebot')
const nodeMachineId = require('node-machine-id')
const axios = require('axios').default
const config = require('config')

const esp2866BaseUrl = config.get('esp2866BaseUrl')
const countryCode = config.get('countryCode')
const username = config.get('username')
const passwordHash = config.get('password')

const EcoVacsAPI = ecovacsDeebot.EcoVacsAPI
const device_id = EcoVacsAPI.getDeviceId(nodeMachineId.machineIdSync())
const continent = ecovacsDeebot.countries[countryCode].continent.toLowerCase()
const api = new EcoVacsAPI(device_id, countryCode, continent)

let vacbot = undefined

const observe = async () => {
    if (vacbot !== undefined) {
        console.log('Already observing')
        return
    }
    console.log('Start observing')

    const connectStatus = await api.connect(username, passwordHash)
    const devices = await api.devices()
    let vacuum = devices[0];
    vacbot = api.getVacBot(api.uid, EcoVacsAPI.REALM, api.resource, api.user_access_token, vacuum, continent)

    vacbot.on('ready', async (event) => {
        console.log('Vacbot ready')

        vacbot.on('CleanReport', async (state) => {
            console.log('CleanReport: ' + state)

            if (state === 'returning') {
                disconnect()
                vacbot = undefined

                console.log('Try open garage door')
                var response = await openGarage()
                console.log('Garage door opens...')

                let i = 0
                while (response !== 200 && i < 5) {
                    i++;
                    console.log(`Error ${response}, retry open garage door #${i}`)
                    response = await openGarage()
                    await sleep(500)
                }
            }
        })
    })

    process.on('SIGINT', function () {
        console.log("\nGracefully shutting down from SIGINT (Ctrl+C)")
        disconnect()
        process.exit()
    });

    function disconnect() {
        try {
            vacbot.disconnect();
        } catch (e) {
            console.log('Failure disconnecting: ', e.message)
        }
    }
}

const openGarage = async () => {
    try {
        const response = await axios.get(`${esp2866BaseUrl}/open`, {
            timeout: 1000
        })
        console.log(`response.status=${response.status}`)
        return response.status
    }
    catch (err) {
        return err
    }
}

const isRunning = () => {
    return vacbot !== undefined
}

const disconnect = () => {
    try {
        vacbot.disconnect()
    } catch (e) {
        console.log('Failure in disconnecting: ', e.message)
    }
    console.log("Exiting...")
}

const sleep = async (millis) => {
    return new Promise(resolve => setTimeout(resolve, millis))
}

module.exports = {
    disconnect,
    isRunning,
    observe
}