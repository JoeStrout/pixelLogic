// Bitmap Logic Simulator
// based on: https://realhet.wordpress.com/2015/09/02/bitmap-logic-simulator/

import "mathUtil"

// Define the map.
mapW = 320    // map width
mapH = 96    // map height

maxX = mapW-1
maxY = mapH-1
xrange = range(0, maxX)
yrange = range(0, maxY)

// We'll just draw the map in a Pixel display.  That makes it
// easy to load and save designs as images, and we can scale
// or scroll it as needed.
// (Only drawback to this: setting individual pixels may be
// slower than setting tile colors.  Need to test that.)
clear
gfx.clear color.black, mapW, mapH
//gfx.drawImage file.loadImage("circuits/BAndNotA.png")
gfx.drawImage file.loadImage("circuits/8bitHexDisplay.png")
gfx.scale = 5
//gfx.scrollY = mapH - 640

// Node: represents a set of pixels that are logically all
// one unit, i.e., they're all either on or off together.
Node = {}
Node.coords = null  // list of [x,y,color] coordinates+colors
Node.inputs = []  // list of Gates that are inputs to this node
Node.on = true
Node.draw = function()
	for p in self.coords
		if self.on then
			gfx.setPixel p[0], p[1], p[2]
		else
			gfx.setPixel p[0], p[1], color.lerp(p[2], "#000000", 0.7)
		end if
	end for
end function
Node.setOn = function(nowOn)
	if nowOn == self.on then return
	self.on = nowOn
	self.draw
end function
Node.update = function
	// Set this node on if ANY of its input gates are on.
	setOn = false
	for g in self.inputs
		if g.on then
			setOn = true
			break
		end if
	end for
	if setOn != self.on then
		self.on = setOn
		self.draw
	end if
end function

// Gate: a special location on the map where special logic
// applies.  It's either a crossing (0), or a a NOT
// gate facing South (1), West (2), North (3), or East (4).
Gate = {}
Gate.x = null
Gate.y = null
Gate.type = 0  // 0: crossing; 1-4: NOT gate
Gate.on = false // output value of the gate (if it's a NOT gate)
Gate.make = function(x, y, type)
	result = new Gate
	result.x = x
	result.y = y
	result.type = type
	// print "Gate at " + x +"," + y + " of type " + type
	return result
end function

// Set the alpha of all non-black pixels is FF, i.e., 
// the pixel is fully "on".
resetAlpha = function
	for y in yrange
		for x in xrange
			c = gfx.pixel(x,y)
			if c == "#000000FF" then continue
			if c[-2:] != "FF" then
				gfx.setPixel x, y, c[:7] + "FF"
			end if
		end for
	end for
end function

// Do a flood-fill starting at x,y, setting the alpha of each
// connected pixel to F0, and gathering the coordinates of
// those pixels into a Node object.
createNodeAt = function(x,y)
	node = new Node
	node.coords = []
	node.inputs = []
	toDo = [[x,y]]
	while toDo
		pos = toDo.pop
		x = pos[0]; y = pos[1]
		c = gfx.pixel(x, y)
		if c == "#000000FF" or c[-2:] != "FF" then continue
		
		gfx.setPixel x, y, c[:7] + "F0"
		node.coords.push [x, y, c]
		// push immediate neighbors
		if x > 0 then toDo.push [x-1, y]
		if x < maxX then toDo.push [x+1, y]
		if y > 0 then toDo.push [x, y-1]
		if y < maxY then toDo.push [x, y+1]	
		// if our immediate neighbor is a crossing, push the other side
		if x > 1 and gfx.pixel(x-1,y) == crossingColor then toDo.push [x-2, y]
		if x < maxX-1 and gfx.pixel(x+1,y) == crossingColor then toDo.push [x+2, y]
		if y > 1 and gfx.pixel(x,y-1) == crossingColor then toDo.push [x, y-2]
		if y < maxY-1 and gfx.pixel(x,y+1) == crossingColor then toDo.push [x, y+2]	
	end while
	return node
end function

// Search the current map for all Gates.  Return as a list.
// Also, while we're at it, set Crossing gate pixels to a 
// secret color so we can quickly identify them later.
crossingColor = "#FF00FFF0"
findGates = function
	result = []
	for y in range(1, maxY-1)
		for x in range(1, maxX-1)
			// gates always have a black pixel in the middle
			if gfx.pixel(x,y) != "#000000FF" then continue
			// if we have that, check the pattern of surrounding pixels
			pat = []
			for j in range(y-1, y+1)
				for i in range(x-1, x+1)
					if gfx.pixel(i,j) == "#000000FF" then pat.push "0" else pat.push "1"
				end for				
			end for
			pat = pat.join("")
			if pat == "000000000" then continue
			// print pat
			if pat == "010101010" then  // crossing
				result.push Gate.make(x, y, 0)
				gfx.setPixel x, y, crossingColor				
			else if pat == "110101110" then  // NOT (East)
				result.push Gate.make(x, y, 4)
			else if pat == "111101010" then // NOT (North)
				result.push Gate.make(x, y, 3)
			else if pat == "011101011" then // NOT (West)
				result.push Gate.make(x, y, 2)
			else if pat == "010101111" then // NOT (South)
				result.push Gate.make(x, y, 1)
			end if
		end for
	end for
	return result
end function

// Analyze the current map.  We need to find a series of "nodes"
// connected by NOT gates.  Each node is a set of interconnected
// non-black pixels.  We find these by doing a flood-fill on any
// non-black pixel that hasn't already been assigned to a node.
analyze = function
	// Start by ensuring the alpha of all pixels is FF, i.e.,
	// the pixel is full "on".  Then we'll change them to F0
	// as we go, to keep track of which pixels have already
	// been assigned to nodes.
	resetAlpha
	// Find all the gates.
	globals.gates = findGates
	// Create nodes.
	globals.nodes = []
	for y in yrange
		for x in xrange
			c = gfx.pixel(x,y)
			if c == "#000000FF" then continue
			if c[-2:] != "FF" then continue
			
			node = createNodeAt(x,y)
			// print "Got node at " + x + "," + y + " with " + node.coords.len + " pixels"
			nodes.push node
		end for
	end for
	// Then, take out all the crossing gates, and set them back to black.
	// And for the NOT gates, hook up their inputs and outputs.
	for i in range(gates.len - 1)
		g = gates[i]
		t = g.type
		if t == 0 then
			gfx.setPixel g.x, g.y, "#000000FF"
			gates.remove i
			continue
		else if t == 1 then  // NOT from North to South
			g.input = nodeAtXY(g.x, g.y+1)
			g.output = nodeAtXY(g.x, g.y-1)
		else if t == 2 then // NOT from East to West
			g.input = nodeAtXY(g.x+1, g.y)
			g.output = nodeAtXY(g.x-1, g.y)
		else if t == 3 then // NOT from South to North
			g.input = nodeAtXY(g.x, g.y-1)
			g.output = nodeAtXY(g.x, g.y+1)
		else // NOT from West to East
			g.input = nodeAtXY(g.x-1, g.y)
			g.output = nodeAtXY(g.x+1, g.y)
		end if
		g.output.inputs.push g
	end for
end function

// Find the node at the given gfx (not screen) coordinates.
nodeAtXY = function(gfxX, gfxY)
	for n in nodes
		for p in n.coords
			if p[0] == gfxX and p[1] == gfxY then return n
		end for
	end for
	return null
end function

scales = [0.1, 0.25, 0.5, 0.75] + range(1,32)
scaleIdx = scales.indexOf(gfx.scale)
if scaleIdx == null then scaleIdx = 4

doZoom = function(clicks)
	// get position of mouse in the PixelDisplay
	mx = (mouse.x + gfx.scrollX) / gfx.scale
	my = (mouse.y + gfx.scrollY) / gfx.scale
	// adjust the scroll
	globals.scaleIdx = mathUtil.clamp(scaleIdx + clicks,
	  0, scales.len-1)
	gfx.scale = scales[scaleIdx]
	// adjust scroll so mouse is still over mx, my
	// (just solve the above for scroll -- yay, algebra!)
	gfx.scrollX = mx * gfx.scale - mouse.x
	gfx.scrollY = my * gfx.scale - mouse.y
end function

dragScroll = function
	// get position of mouse in the PixelDisplay
	mx = (mouse.x + gfx.scrollX) / gfx.scale
	my = (mouse.y + gfx.scrollY) / gfx.scale
	
	// while right button down, keep adjusting it
	// so the mouse is still over mx, my
	while mouse.button(1)
		// adjust scroll so mouse is still over mx, my
		// (just solve the above for scroll -- yay, algebra!)
		gfx.scrollX = mx * gfx.scale - mouse.x
		gfx.scrollY = my * gfx.scale - mouse.y
		yield
	end while
end function

handleMouse = function
	zoom = round(key.axis("Mouse ScrollWheel")*5)
	if zoom != 0 then doZoom zoom
	if mouse.button(1) then dragScroll
	if not mouse.button then return
	node = nodeAtXY(floor((mouse.x + gfx.scrollX) / gfx.scale), 
	floor((mouse.y + gfx.scrollY) / gfx.scale))
	if node != null then
		node.setOn not node.on
	end if
	while mouse.button; yield; end while	
end function

simOneStep = function
	handleMouse
	gates.shuffle
	for g in gates
		g.on = not g.input.on
		g.output.update
	end for
end function

print "Analyzing..."
analyze
print "Ready!"
wait
text.clear

while true
	simOneStep
	yield
end while
