// Exercise Control Program for:
// Binary Decoder

import "qa"

taskDirName = "binaryDecoder"

if not file.exists("/usr/userdata") then
	file.makedir "/usr/userdata"
end if

dataFolder = "/usr/userdata/" + taskDirName
if not file.exists(dataFolder) then
	file.makedir dataFolder
end if

taskFolder = "/usr/exercises/" + taskDirName

startImagePath = taskFolder + "/start.png"
curImagePath = dataFolder + "/current.png"
if not file.exists(curImagePath) then file.copy startImagePath, curImagePath
circuitPic = file.loadImage(curImagePath)
qa.assert circuitPic

import "pixelLogicSim"
sim = pixelLogicSim
sim.filePath = curImagePath
sim.fileDate = file.info(curImagePath).date
sim.setup
sim.analyze
text.clear

while not key.pressed("escape")
	sim.update
end while
key.clear
