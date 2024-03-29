const express = require('express')
const observer = require('./homecoming-observer')

const port = 7080
const app = express()
app.use(express.json())

app.get('/health', async (req, res) => {
    let status
    if (observer.isRunning()) {
        status = { status: 'running' }
    } else {
        status = { status: 'up' }
    }
    console.log(status)
    res.send(status)
})

app.get('/start', async (req, res) => {
    observer.observe()
    res.send({ status: 'running' })
})

app.listen(port, () => {
    console.log(`Started Homecoming server on port:${port}`)
})
