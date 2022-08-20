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
gfx.clear color.black, pic.width, pic.height
gfx.scrollX = pic.width/2 - 640
gfx.scrollY = pic.height/2 - 320
gfx.drawImage pic
threshold = input("Threshold [80]: ")
if threshold == "" then threshold = 80 else threshold = val(threshold)

print "Thresholding..."
for y in range(0, pic.height-1)
	for x in range(0, pic.width-1)
		c = gfx.pixel(x, y)
		if c == "#000000FF" then continue
		c = color.toList(c)
		changed = false
		if c[0] < threshold and c[1] < threshold and c[2] < threshold then
			gfx.setPixel x, y, "#000000"
		end if
	end for
	print ceil(100 * y / pic.height) + "%"
	text.row = text.row + 1
end for

pic = gfx.getImage(0, 0, pic.width, pic.height)
outPath = path - ".png" + "-clean.png"
file.saveImage outPath, pic
print "Wrote cleaned image to: " + outPath




