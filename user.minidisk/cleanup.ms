// This little utility program cleans up a sloppy PNG
// by making sure any "almost black" pixels are actually black.

gfx.clear
text.row = 0
while true
	path = input("Image path: ")
	if path == "" then exit
	pic = file.loadImage(path)
	if pic != null then break
	print "Unable to load image at: " + path
end while
print pic.width + " x " + pic.height + " image"
gfx.drawImage pic, 320-pic.width/2, 480-pic.height/2
threshold = input("Threshold [80]: ")
if threshold == "" then threshold = 80 else threshold = val(threshold)

print "Thresholding..."
for y in range(0, pic.height-1)
	for x in range(0, pic.width-1)
		c = color.toList(pic.pixel(x, y))
		changed = false
		if c[0] < threshold then; c[0] = 0; changed = true; end if
		if c[1] < threshold then; c[1] = 0; changed = true; end if
		if c[2] < threshold then; c[2] = 0; changed = true; end if
		if changed then pic.setPixel x, y, color.fromList(c)
	end for
	print ceil(100 * y / pic.height) + "%"
	text.row = text.row + 1
end for

gfx.drawImage pic, 320-pic.width/2, 480-pic.height/2

outPath = path - ".png" + "-clean.png"
file.saveImage outPath, pic
print "Wrote cleaned image to: " + outPath




