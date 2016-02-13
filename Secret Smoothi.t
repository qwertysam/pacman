setscreen ("graphics:448;576, nobuttonbar, position:center;center, noecho, offscreenonly")


type Direction : enum (up, down, left, right, none)
type FontType : enum (normal_white, normal_pink)

% Initializes all the procedures and their parameters
forward proc drawPlayScreen
forward proc drawText (x, y : int, font : FontType, text : string)
forward proc gameInput
forward proc drawMenuScreen
forward proc addScore (score : int)
forward proc menuInput
forward proc gameMath
forward proc reset
forward proc setupNextLevel
forward proc updateAI

const debug := false

const typeface := "Fixedsys"
const halfx := floor (maxx / 2)
const halfy := floor (maxy / 2)
const xMenuOff := 110
const yMenuOff := 430

const tickInterval := (1000 / 60) % The time in milliseconds between ticks
var currentTime := 0
var lastTick := 0

var inGame := false % Defaults to Main Menu

var score := 0

% Loads all the sprites
const iMap : int := Pic.Scale (Pic.FileNew ("pacman/map.bmp"), maxx, maxy)
const iTitle : int := Pic.Scale (Pic.FileNew ("pacman/title.bmp"), maxx, maxy)

var iTextCredit : array 0 .. 1 of int
iTextCredit (0) := Pic.Scale (Pic.FileNew ("pacman/text_credit1.bmp"), 142, 14)
iTextCredit (1) := Pic.Scale (Pic.FileNew ("pacman/text_credit2.bmp"), 142, 14)

var iPacmanLeft : array 0 .. 3 of int
iPacmanLeft (0) := Pic.Scale (Pic.FileNew ("pacman/pacman0.bmp"), 32, 32)
iPacmanLeft (1) := Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32)
iPacmanLeft (2) := Pic.Scale (Pic.FileNew ("pacman/pacman2.bmp"), 32, 32)
iPacmanLeft (3) := Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32)

var iPacmanDown : array 0 .. 3 of int
iPacmanDown (0) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman0.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (1) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (2) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman2.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (3) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32), 270, 16, 16))

var iPacmanRight : array 0 .. 3 of int
iPacmanRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pacman0.bmp"), 32, 32))
iPacmanRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32))
iPacmanRight (2) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pacman2.bmp"), 32, 32))
iPacmanRight (3) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32))

var iPacmanUp : array 0 .. 3 of int
iPacmanUp (0) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman0.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (1) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (2) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman2.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (3) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/pacman1.bmp"), 32, 32), 270, 16, 16)

var iPacmanDead : array 0 .. 12 of int
iPacmanDead (0) := Pic.Scale (Pic.FileNew ("pacman/pacman3.bmp"), 32, 32)
iPacmanDead (1) := Pic.Scale (Pic.FileNew ("pacman/pacman4.bmp"), 32, 32)
iPacmanDead (2) := Pic.Scale (Pic.FileNew ("pacman/pacman5.bmp"), 32, 32)
iPacmanDead (3) := Pic.Scale (Pic.FileNew ("pacman/pacman6.bmp"), 32, 32)
iPacmanDead (4) := Pic.Scale (Pic.FileNew ("pacman/pacman7.bmp"), 32, 32)
iPacmanDead (5) := Pic.Scale (Pic.FileNew ("pacman/pacman8.bmp"), 32, 32)
iPacmanDead (6) := Pic.Scale (Pic.FileNew ("pacman/pacman9.bmp"), 32, 32)
iPacmanDead (7) := Pic.Scale (Pic.FileNew ("pacman/pacman10.bmp"), 32, 32)
iPacmanDead (8) := Pic.Scale (Pic.FileNew ("pacman/pacman11.bmp"), 32, 32)
iPacmanDead (9) := Pic.Scale (Pic.FileNew ("pacman/pacman12.bmp"), 32, 32)
iPacmanDead (10) := Pic.Scale (Pic.FileNew ("pacman/pacman13.bmp"), 32, 32)
iPacmanDead (11) := Pic.Scale (Pic.FileNew ("pacman/pacman14.bmp"), 32, 32)
iPacmanDead (12) := Pic.Scale (Pic.FileNew ("pacman/pacman15.bmp"), 32, 32)


var iBlinkyLeft : array 0 .. 1 of int
iBlinkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/blinky_side1.bmp"), 32, 32)
iBlinkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/blinky_side2.bmp"), 32, 32)

var iBlinkyDown : array 0 .. 1 of int
iBlinkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/blinky_down1.bmp"), 32, 32)
iBlinkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/blinky_down2.bmp"), 32, 32)

var iBlinkyRight : array 0 .. 1 of int
iBlinkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/blinky_side1.bmp"), 32, 32))
iBlinkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/blinky_side2.bmp"), 32, 32))

var iBlinkyUp : array 0 .. 1 of int
iBlinkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/blinky_up1.bmp"), 32, 32)
iBlinkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/blinky_up2.bmp"), 32, 32)

var iClydeLeft : array 0 .. 1 of int
iClydeLeft (0) := Pic.Scale (Pic.FileNew ("pacman/clyde_side1.bmp"), 32, 32)
iClydeLeft (1) := Pic.Scale (Pic.FileNew ("pacman/clyde_side2.bmp"), 32, 32)

var iClydeDown : array 0 .. 1 of int
iClydeDown (0) := Pic.Scale (Pic.FileNew ("pacman/clyde_down1.bmp"), 32, 32)
iClydeDown (1) := Pic.Scale (Pic.FileNew ("pacman/clyde_down2.bmp"), 32, 32)

var iClydeRight : array 0 .. 1 of int
iClydeRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/clyde_side1.bmp"), 32, 32))
iClydeRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/clyde_side2.bmp"), 32, 32))

var iClydeUp : array 0 .. 1 of int
iClydeUp (0) := Pic.Scale (Pic.FileNew ("pacman/clyde_up1.bmp"), 32, 32)
iClydeUp (1) := Pic.Scale (Pic.FileNew ("pacman/clyde_up2.bmp"), 32, 32)


var iInkyLeft : array 0 .. 1 of int
iInkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/inky_side1.bmp"), 32, 32)
iInkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/inky_side2.bmp"), 32, 32)

var iInkyDown : array 0 .. 1 of int
iInkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/inky_down1.bmp"), 32, 32)
iInkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/inky_down2.bmp"), 32, 32)

var iInkyRight : array 0 .. 1 of int
iInkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/inky_side1.bmp"), 32, 32))
iInkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/inky_side2.bmp"), 32, 32))

var iInkyUp : array 0 .. 1 of int
iInkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/inky_up1.bmp"), 32, 32)
iInkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/inky_up2.bmp"), 32, 32)

var iPinkyLeft : array 0 .. 1 of int
iPinkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/pinky_side1.bmp"), 32, 32)
iPinkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/pinky_side2.bmp"), 32, 32)

var iPinkyDown : array 0 .. 1 of int
iPinkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/pinky_down1.bmp"), 32, 32)
iPinkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/pinky_down2.bmp"), 32, 32)

var iPinkyRight : array 0 .. 1 of int
iPinkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pinky_side1.bmp"), 32, 32))
iPinkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/pinky_side2.bmp"), 32, 32))

var iPinkyUp : array 0 .. 1 of int
iPinkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/pinky_up1.bmp"), 32, 32)
iPinkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/pinky_up2.bmp"), 32, 32)

var iScaredGhost : array 0 .. 1 of int
iScaredGhost (0) := Pic.Scale (Pic.FileNew ("pacman/scared_ghost1.bmp"), 32, 32)
iScaredGhost (1) := Pic.Scale (Pic.FileNew ("pacman/scared_ghost2.bmp"), 32, 32)


var iLargePellet : array 0 .. 1 of int
iLargePellet (0) := Pic.Scale (Pic.FileNew ("pacman/pellet_large1.bmp"), 16, 16)
iLargePellet (1) := Pic.Scale (Pic.FileNew ("pacman/pellet_large2.bmp"), 16, 16)

var iSmallPellet : array 0 .. 0 of int
iSmallPellet (0) := Pic.Scale (Pic.FileNew ("pacman/pellet_small.bmp"), 16, 16)


var iWhiteText : array 0 .. 40 of int
iWhiteText (0) := Pic.Scale (Pic.FileNew ("pacman/font/white0.bmp"), 16, 16)
iWhiteText (1) := Pic.Scale (Pic.FileNew ("pacman/font/white1.bmp"), 16, 16)
iWhiteText (2) := Pic.Scale (Pic.FileNew ("pacman/font/white2.bmp"), 16, 16)
iWhiteText (3) := Pic.Scale (Pic.FileNew ("pacman/font/white3.bmp"), 16, 16)
iWhiteText (4) := Pic.Scale (Pic.FileNew ("pacman/font/white4.bmp"), 16, 16)
iWhiteText (5) := Pic.Scale (Pic.FileNew ("pacman/font/white5.bmp"), 16, 16)
iWhiteText (6) := Pic.Scale (Pic.FileNew ("pacman/font/white6.bmp"), 16, 16)
iWhiteText (7) := Pic.Scale (Pic.FileNew ("pacman/font/white7.bmp"), 16, 16)
iWhiteText (8) := Pic.Scale (Pic.FileNew ("pacman/font/white8.bmp"), 16, 16)
iWhiteText (9) := Pic.Scale (Pic.FileNew ("pacman/font/white9.bmp"), 16, 16)
iWhiteText (10) := Pic.Scale (Pic.FileNew ("pacman/font/whitea.bmp"), 16, 16)
iWhiteText (11) := Pic.Scale (Pic.FileNew ("pacman/font/whiteb.bmp"), 16, 16)
iWhiteText (12) := Pic.Scale (Pic.FileNew ("pacman/font/whitec.bmp"), 16, 16)
iWhiteText (13) := Pic.Scale (Pic.FileNew ("pacman/font/whited.bmp"), 16, 16)
iWhiteText (14) := Pic.Scale (Pic.FileNew ("pacman/font/whitee.bmp"), 16, 16)
iWhiteText (15) := Pic.Scale (Pic.FileNew ("pacman/font/whitef.bmp"), 16, 16)
iWhiteText (16) := Pic.Scale (Pic.FileNew ("pacman/font/whiteg.bmp"), 16, 16)
iWhiteText (17) := Pic.Scale (Pic.FileNew ("pacman/font/whiteh.bmp"), 16, 16)
iWhiteText (18) := Pic.Scale (Pic.FileNew ("pacman/font/whitei.bmp"), 16, 16)
iWhiteText (19) := Pic.Scale (Pic.FileNew ("pacman/font/whitej.bmp"), 16, 16)
iWhiteText (20) := Pic.Scale (Pic.FileNew ("pacman/font/whitek.bmp"), 16, 16)
iWhiteText (21) := Pic.Scale (Pic.FileNew ("pacman/font/whitel.bmp"), 16, 16)
iWhiteText (22) := Pic.Scale (Pic.FileNew ("pacman/font/whiten.bmp"), 16, 16)
iWhiteText (23) := Pic.Scale (Pic.FileNew ("pacman/font/whitem.bmp"), 16, 16)
iWhiteText (24) := Pic.Scale (Pic.FileNew ("pacman/font/whiteo.bmp"), 16, 16)
iWhiteText (25) := Pic.Scale (Pic.FileNew ("pacman/font/whitep.bmp"), 16, 16)
iWhiteText (26) := Pic.Scale (Pic.FileNew ("pacman/font/whiteq.bmp"), 16, 16)
iWhiteText (27) := Pic.Scale (Pic.FileNew ("pacman/font/whiter.bmp"), 16, 16)
iWhiteText (28) := Pic.Scale (Pic.FileNew ("pacman/font/whites.bmp"), 16, 16)
iWhiteText (29) := Pic.Scale (Pic.FileNew ("pacman/font/whitet.bmp"), 16, 16)
iWhiteText (30) := Pic.Scale (Pic.FileNew ("pacman/font/whiteu.bmp"), 16, 16)
iWhiteText (31) := Pic.Scale (Pic.FileNew ("pacman/font/whitev.bmp"), 16, 16)
iWhiteText (32) := Pic.Scale (Pic.FileNew ("pacman/font/whitew.bmp"), 16, 16)
iWhiteText (33) := Pic.Scale (Pic.FileNew ("pacman/font/whitex.bmp"), 16, 16)
iWhiteText (34) := Pic.Scale (Pic.FileNew ("pacman/font/whitey.bmp"), 16, 16)
iWhiteText (35) := Pic.Scale (Pic.FileNew ("pacman/font/whitez.bmp"), 16, 16)
iWhiteText (36) := Pic.Scale (Pic.FileNew ("pacman/font/whiteperiod.bmp"), 16, 16)
iWhiteText (37) := Pic.Scale (Pic.FileNew ("pacman/font/whiteexclaim.bmp"), 16, 16)
iWhiteText (38) := Pic.Scale (Pic.FileNew ("pacman/font/whiteslash.bmp"), 16, 16)
iWhiteText (39) := Pic.Scale (Pic.FileNew ("pacman/font/whitequote.bmp"), 16, 16)
iWhiteText (40) := Pic.Scale (Pic.FileNew ("pacman/font/whitehyphen.bmp"), 16, 16)

var iPinkText : array 0 .. 40 of int
iPinkText (0) := Pic.Scale (Pic.FileNew ("pacman/font/pink0.bmp"), 16, 16)
iPinkText (1) := Pic.Scale (Pic.FileNew ("pacman/font/pink1.bmp"), 16, 16)
iPinkText (2) := Pic.Scale (Pic.FileNew ("pacman/font/pink2.bmp"), 16, 16)
iPinkText (3) := Pic.Scale (Pic.FileNew ("pacman/font/pink3.bmp"), 16, 16)
iPinkText (4) := Pic.Scale (Pic.FileNew ("pacman/font/pink4.bmp"), 16, 16)
iPinkText (5) := Pic.Scale (Pic.FileNew ("pacman/font/pink5.bmp"), 16, 16)
iPinkText (6) := Pic.Scale (Pic.FileNew ("pacman/font/pink6.bmp"), 16, 16)
iPinkText (7) := Pic.Scale (Pic.FileNew ("pacman/font/pink7.bmp"), 16, 16)
iPinkText (8) := Pic.Scale (Pic.FileNew ("pacman/font/pink8.bmp"), 16, 16)
iPinkText (9) := Pic.Scale (Pic.FileNew ("pacman/font/pink9.bmp"), 16, 16)
iPinkText (10) := Pic.Scale (Pic.FileNew ("pacman/font/pinka.bmp"), 16, 16)
iPinkText (11) := Pic.Scale (Pic.FileNew ("pacman/font/pinkb.bmp"), 16, 16)
iPinkText (12) := Pic.Scale (Pic.FileNew ("pacman/font/pinkc.bmp"), 16, 16)
iPinkText (13) := Pic.Scale (Pic.FileNew ("pacman/font/pinkd.bmp"), 16, 16)
iPinkText (14) := Pic.Scale (Pic.FileNew ("pacman/font/pinke.bmp"), 16, 16)
iPinkText (15) := Pic.Scale (Pic.FileNew ("pacman/font/pinkf.bmp"), 16, 16)
iPinkText (16) := Pic.Scale (Pic.FileNew ("pacman/font/pinkg.bmp"), 16, 16)
iPinkText (17) := Pic.Scale (Pic.FileNew ("pacman/font/pinkh.bmp"), 16, 16)
iPinkText (18) := Pic.Scale (Pic.FileNew ("pacman/font/pinki.bmp"), 16, 16)
iPinkText (19) := Pic.Scale (Pic.FileNew ("pacman/font/pinkj.bmp"), 16, 16)
iPinkText (20) := Pic.Scale (Pic.FileNew ("pacman/font/pinkk.bmp"), 16, 16)
iPinkText (21) := Pic.Scale (Pic.FileNew ("pacman/font/pinkl.bmp"), 16, 16)
iPinkText (22) := Pic.Scale (Pic.FileNew ("pacman/font/pinkn.bmp"), 16, 16)
iPinkText (23) := Pic.Scale (Pic.FileNew ("pacman/font/pinkm.bmp"), 16, 16)
iPinkText (24) := Pic.Scale (Pic.FileNew ("pacman/font/pinko.bmp"), 16, 16)
iPinkText (25) := Pic.Scale (Pic.FileNew ("pacman/font/pinkp.bmp"), 16, 16)
iPinkText (26) := Pic.Scale (Pic.FileNew ("pacman/font/pinkq.bmp"), 16, 16)
iPinkText (27) := Pic.Scale (Pic.FileNew ("pacman/font/pinkr.bmp"), 16, 16)
iPinkText (28) := Pic.Scale (Pic.FileNew ("pacman/font/pinks.bmp"), 16, 16)
iPinkText (29) := Pic.Scale (Pic.FileNew ("pacman/font/pinkt.bmp"), 16, 16)
iPinkText (30) := Pic.Scale (Pic.FileNew ("pacman/font/pinku.bmp"), 16, 16)
iPinkText (31) := Pic.Scale (Pic.FileNew ("pacman/font/pinkv.bmp"), 16, 16)
iPinkText (32) := Pic.Scale (Pic.FileNew ("pacman/font/pinkw.bmp"), 16, 16)
iPinkText (33) := Pic.Scale (Pic.FileNew ("pacman/font/pinkx.bmp"), 16, 16)
iPinkText (34) := Pic.Scale (Pic.FileNew ("pacman/font/pinky.bmp"), 16, 16)
iPinkText (35) := Pic.Scale (Pic.FileNew ("pacman/font/pinkz.bmp"), 16, 16)
iPinkText (36) := Pic.Scale (Pic.FileNew ("pacman/font/pinkperiod.bmp"), 16, 16)
iPinkText (37) := Pic.Scale (Pic.FileNew ("pacman/font/pinkexclaim.bmp"), 16, 16)
iPinkText (38) := Pic.Scale (Pic.FileNew ("pacman/font/pinkslash.bmp"), 16, 16)
iPinkText (39) := Pic.Scale (Pic.FileNew ("pacman/font/pinkquote.bmp"), 16, 16)
iPinkText (40) := Pic.Scale (Pic.FileNew ("pacman/font/pinkhyphen.bmp"), 16, 16)




View.SetTransparentColor (black)




class Rectangle
    import debug, Direction
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, collisionMove, dir, autoCollisionMove, setDirection

    var x, y, width, height : int

    var dir := Direction.none

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	x := newX
	y := newY
	width := newWidth
	height := newHeight
    end setRectangle


    fcn isTouching (rect : ^Rectangle) : boolean
	result (x < rect -> x + rect -> width and x + width > rect -> x and y < rect -> y + rect -> height and y + height > rect -> y)
    end isTouching

    fcn intersects (inX, inY : int) : boolean
	result (inX > x and inX < x + width and inY > y and inY < inY + height)
    end intersects

    proc setPosition (xPos, yPos : int)
	x := xPos
	y := yPos
    end setPosition

    proc move (xOff, yOff : int)
	x := x + xOff
	y := y + yOff
    end move

    % Use for when the player uses the keys to try and move
    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	move (xOff, yOff)

	for i : 0 .. upper (rects)
	    if isTouching (rects (i)) then
		move (-xOff, -yOff)

		if xOff = 1 and yOff = 0 and dir = Direction.right then
		    dir := Direction.none
		elsif xOff = -1 and yOff = 0 and dir = Direction.left then
		    dir := Direction.none
		elsif xOff = 0 and yOff = 1 and dir = Direction.up then
		    dir := Direction.none
		elsif xOff = 0 and yOff = -1 and dir = Direction.down then
		    dir := Direction.none
		end if

		result false
	    end if
	end for

	if xOff = 1 and yOff = 0 then
	    dir := Direction.right
	elsif xOff = -1 and yOff = 0 then
	    dir := Direction.left
	elsif xOff = 0 and yOff = 1 then
	    dir := Direction.up
	elsif xOff = 0 and yOff = -1 then
	    dir := Direction.down
	end if

	result true
    end collisionMove

    proc setDirection (newDir : Direction)
	dir := newDir
    end setDirection

    % Only used for when the game automatically moves the player
    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	move (xOff, yOff)

	for i : 0 .. upper (rects)
	    if isTouching (rects (i)) then
		move (-xOff, -yOff)
		dir := Direction.none
		result false
	    end if
	end for
	result true
    end autoCollisionMove

    proc draw (fill : boolean)
	if debug then
	    if fill then
		drawfillbox (x * 2, y * 2, (x + width) * 2, (y + height) * 2, white)
	    else
		Draw.Line (x * 2, y * 2, x * 2, (y + height) * 2, white)
		Draw.Line (x * 2, (y + height) * 2, (x + width) * 2, (y + height) * 2, white)
		Draw.Line ((x + width) * 2, (y + height) * 2, (x + width) * 2, y * 2, white)
		Draw.Line ((x + width) * 2, y * 2, x * 2, y * 2, white)
	    end if
	end if
    end draw

end Rectangle

class FrameHolder
    export frames, framesLength, setFrames

    var frames : array 0 .. 15 of int
    var framesLength := 0

    proc setFrames (inFrames : array 0 .. * of int)
	framesLength := upper (inFrames)
	for i : 0 .. framesLength
	    frames (i) := inFrames (i)
	end for
    end setFrames
end FrameHolder

class AnimationRectangle
    import Rectangle, FrameHolder
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, setFrames, collisionMove, autoCollisionMove

    var rec : ^Rectangle
    new rec

    var currentFrameTrack := 0

    var frameTrack : ^FrameHolder
    new frameTrack

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (newFrames : array 0 .. * of int, tpf, spriteOffX, spriteOffY : int)
	ticksPerFrame := tpf

	spriteOffsetX := spriteOffX
	spriteOffsetY := spriteOffY

	frameTrack -> setFrames (newFrames)
    end setFrames

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	rec -> setRectangle (newX, newY, newWidth, newHeight)
    end setRectangle

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> collisionMove (xOff, yOff, rects)
    end collisionMove

    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> autoCollisionMove (xOff, yOff, rects)
    end autoCollisionMove

    proc move (xOff, yOff : int)
	rec -> move (xOff, yOff)
    end move

    proc draw
	framesPassed := framesPassed + 1

	if framesPassed >= ticksPerFrame then
	    framesPassed := 0
	    currentFrame := currentFrame + 1

	    if currentFrame > frameTrack -> framesLength then
		currentFrame := 0
	    end if
	end if

	Pic.Draw (frameTrack -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)

	rec -> draw (false)
    end draw

end AnimationRectangle


class SpriteRectangle
    import Rectangle, Direction, FrameHolder
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, setFrames, collisionMove, direction, autoCollisionMove, setDirection

    var rec : ^Rectangle
    new rec

    var currentFrameTrack := 0

    var frameTracks : array 0 .. 3 of ^FrameHolder
    new frameTracks (0)
    new frameTracks (1)
    new frameTracks (2)
    new frameTracks (3)

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (up : array 0 .. * of int, down : array 0 .. * of int, left : array 0 .. * of int, right : array 0 .. * of int, tpf, spriteOffX, spriteOffY : int)
	ticksPerFrame := tpf

	spriteOffsetX := spriteOffX
	spriteOffsetY := spriteOffY

	frameTracks (0) -> setFrames (up)

	frameTracks (1) -> setFrames (down)

	frameTracks (2) -> setFrames (left)

	frameTracks (3) -> setFrames (right)
    end setFrames

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	rec -> setRectangle (newX, newY, newWidth, newHeight)
    end setRectangle

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> collisionMove (xOff, yOff, rects)
    end collisionMove

    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> autoCollisionMove (xOff, yOff, rects)
    end autoCollisionMove

    proc move (xOff, yOff : int)
	rec -> move (xOff, yOff)
    end move

    fcn direction : Direction
	result rec -> dir
    end direction

    proc setDirection (newDir : Direction)
	rec -> setDirection (newDir)
    end setDirection

    proc draw
	framesPassed := framesPassed + 1

	if rec -> dir = Direction.none then
	    currentFrame := 1
	elsif framesPassed >= ticksPerFrame then
	    framesPassed := 0
	    currentFrame := currentFrame + 1

	    if currentFrame > frameTracks (currentFrameTrack) -> framesLength then
		currentFrame := 0
	    end if
	end if

	if rec -> dir = Direction.up then
	    currentFrameTrack := 0
	elsif rec -> dir = Direction.down then
	    currentFrameTrack := 1
	elsif rec -> dir = Direction.left then
	    currentFrameTrack := 2
	elsif rec -> dir = Direction.right then
	    currentFrameTrack := 3
	end if

	Pic.Draw (frameTracks (currentFrameTrack) -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)

	rec -> draw (false)
    end draw

end SpriteRectangle

class Pellet
    import Rectangle, Direction, FrameHolder, iLargePellet, iSmallPellet, addScore, SpriteRectangle
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setPellet, x, y, width, height, isTouching, draw, setPosition, setFrames, update, reset

    var rec : ^Rectangle
    new rec

    var isLargePellet := false
    var isEaten := false
    var scoreValue := 0

    var currentFrameTrack := 0

    var frameTracks : array 0 .. 1 of ^FrameHolder
    new frameTracks (0)
    new frameTracks (1)

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (tpf : int)
	ticksPerFrame := tpf

	if not isLargePellet then
	    spriteOffsetX := -6
	    spriteOffsetY := -6
	end if

	frameTracks (0) -> setFrames (iSmallPellet)

	frameTracks (1) -> setFrames (iLargePellet)
    end setFrames

    proc setPellet (newX, newY : int, largePellet : boolean)
	isLargePellet := largePellet

	var newHeight, newWidth, returnX, returnY : int

	if isLargePellet then
	    newHeight := 8
	    newWidth := 8
	    returnX := newX
	    returnY := newY
	    currentFrameTrack := 1
	    scoreValue := 100
	else
	    newHeight := 2
	    newWidth := 2
	    returnX := newX
	    returnY := newY
	    currentFrameTrack := 0
	    scoreValue := 50
	    setFrames (0)
	end if
	rec -> setRectangle (returnX, returnY, newWidth, newHeight)
    end setPellet

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc update (user : ^Rectangle)
	if user -> isTouching (rec) and not isEaten then
	    isEaten := true
	    addScore (scoreValue)
	end if
    end update

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    proc reset
	isEaten := false
	framesPassed := 0
	currentFrame := 0
    end reset

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    proc draw
	if not isEaten then
	    if not isLargePellet then
		Pic.Draw (frameTracks (currentFrameTrack) -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)
	    else
		framesPassed := framesPassed + 1

		if framesPassed >= ticksPerFrame then
		    framesPassed := 0
		    currentFrame := currentFrame + 1

		    if currentFrame > frameTracks (currentFrameTrack) -> framesLength then
			currentFrame := 0
		    end if
		end if
		Pic.Draw (frameTracks (currentFrameTrack) -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)
	    end if
	    rec -> draw (false)
	end if
    end draw

end Pellet

var User : ^SpriteRectangle
new User

User -> setRectangle (104, 68, 16, 16)
User -> setFrames (iPacmanUp, iPacmanDown, iPacmanLeft, iPacmanRight, 5, 1, 0)

var bottomWall0 : ^Rectangle
new bottomWall0
bottomWall0 -> setRectangle (0, 16, 224, 4)

var bottomWall1 : ^Rectangle
new bottomWall1
bottomWall1 -> setRectangle (0, 16, 4, 124)

var bottomWall2 : ^Rectangle
new bottomWall2
bottomWall2 -> setRectangle (20, 36, 72, 8)

var bottomWall3 : ^Rectangle
new bottomWall3
bottomWall3 -> setRectangle (132, 36, 72, 8)

var bottomWall4 : ^Rectangle
new bottomWall4
bottomWall4 -> setRectangle (220, 16, 4, 124)

var bottomWall5 : ^Rectangle
new bottomWall5
bottomWall5 -> setRectangle (108, 36, 8, 32)

var bottomWall6 : ^Rectangle
new bottomWall6
bottomWall6 -> setRectangle (84, 60, 56, 8)

var bottomWall7 : ^Rectangle
new bottomWall7
bottomWall7 -> setRectangle (60, 36, 8, 32)

var bottomWall8 : ^Rectangle
new bottomWall8
bottomWall8 -> setRectangle (156, 36, 8, 32)

var bottomWall9 : ^Rectangle
new bottomWall9
bottomWall9 -> setRectangle (0, 60, 20, 8)

var bottomWall10 : ^Rectangle
new bottomWall10
bottomWall10 -> setRectangle (204, 60, 20, 8)

var bottomWall11 : ^Rectangle
new bottomWall11
bottomWall11 -> setRectangle (60, 84, 32, 8)

var bottomWall12 : ^Rectangle
new bottomWall12
bottomWall12 -> setRectangle (132, 84, 32, 8)

var bottomWall13 : ^Rectangle
new bottomWall13
bottomWall13 -> setRectangle (108, 84, 8, 32)

var bottomWall14 : ^Rectangle
new bottomWall14
bottomWall14 -> setRectangle (84, 108, 56, 8)

var leftWall1 : ^Rectangle
new leftWall1
leftWall1 -> setRectangle (0, 108, 44, 32)

var leftWall2 : ^Rectangle
new leftWall2
leftWall2 -> setRectangle (36, 60, 8, 32)

var rightWall1 : ^Rectangle
new rightWall1
rightWall1 -> setRectangle (180, 108, 44, 32)

var rightWall2 : ^Rectangle
new rightWall2
rightWall2 -> setRectangle (180, 60, 8, 32)

var leftWall3 : ^Rectangle
new leftWall3
leftWall3 -> setRectangle (20, 84, 24, 8)

var rightWall3 : ^Rectangle
new rightWall3
rightWall3 -> setRectangle (180, 84, 24, 8)

var leftWall4 : ^Rectangle
new leftWall4
leftWall4 -> setRectangle (0, 156, 44, 32)

var rightWall4 : ^Rectangle
new rightWall4
rightWall4 -> setRectangle (180, 156, 44, 32)

var leftWall5 : ^Rectangle
new leftWall5
leftWall5 -> setRectangle (60, 108, 8, 32)

var rightWall5 : ^Rectangle
new rightWall5
rightWall5 -> setRectangle (156, 108, 8, 32)

var centerWall1 : ^Rectangle
new centerWall1
centerWall1 -> setRectangle (84, 132, 56, 4)

var centerWall2 : ^Rectangle
new centerWall2
centerWall2 -> setRectangle (84, 132, 4, 32)

var centerWall3 : ^Rectangle
new centerWall3
centerWall3 -> setRectangle (84, 160, 20, 4)

var centerWall4 : ^Rectangle
new centerWall4
centerWall4 -> setRectangle (120, 160, 20, 4)

var centerWall5 : ^Rectangle
new centerWall5
centerWall5 -> setRectangle (136, 132, 4, 32)

var leftWall6 : ^Rectangle
new leftWall6
leftWall6 -> setRectangle (0, 156, 4, 108)

var rightWall6 : ^Rectangle
new rightWall6
rightWall6 -> setRectangle (220, 156, 4, 108)

var upperWall1 : ^Rectangle
new upperWall1
upperWall1 -> setRectangle (0, 260, 224, 4)

var upperWall2 : ^Rectangle
new upperWall2
upperWall2 -> setRectangle (108, 228, 8, 36)

var upperWall3 : ^Rectangle
new upperWall3
upperWall3 -> setRectangle (108, 180, 8, 32)

var upperWall4 : ^Rectangle
new upperWall4
upperWall4 -> setRectangle (84, 204, 56, 8)

var upperWall5 : ^Rectangle
new upperWall5
upperWall5 -> setRectangle (60, 228, 32, 16)

var upperWall6 : ^Rectangle
new upperWall6
upperWall6 -> setRectangle (132, 228, 32, 16)

var upperWall7 : ^Rectangle
new upperWall7
upperWall7 -> setRectangle (20, 228, 24, 16)

var upperWall8 : ^Rectangle
new upperWall8
upperWall8 -> setRectangle (180, 228, 24, 16)

var upperWall9 : ^Rectangle
new upperWall9
upperWall9 -> setRectangle (20, 204, 24, 8)

var upperWall10 : ^Rectangle
new upperWall10
upperWall10 -> setRectangle (180, 204, 24, 8)

var upperWall11 : ^Rectangle
new upperWall11
upperWall11 -> setRectangle (60, 156, 8, 56)

var upperWall12 : ^Rectangle
new upperWall12
upperWall12 -> setRectangle (156, 156, 8, 56)

var upperWall13 : ^Rectangle
new upperWall13
upperWall13 -> setRectangle (60, 180, 32, 8)

var upperWall14 : ^Rectangle
new upperWall14
upperWall14 -> setRectangle (132, 180, 32, 8)

var walls : array 0 .. 45 of ^Rectangle
walls (0) := bottomWall0
walls (1) := bottomWall1
walls (2) := bottomWall2
walls (3) := bottomWall3
walls (4) := bottomWall4
walls (5) := bottomWall5
walls (6) := bottomWall6
walls (7) := bottomWall7
walls (8) := bottomWall8
walls (9) := bottomWall9
walls (10) := bottomWall10
walls (11) := bottomWall11
walls (12) := bottomWall12
walls (13) := bottomWall13
walls (14) := bottomWall14
walls (15) := leftWall1
walls (16) := leftWall2
walls (17) := rightWall1
walls (18) := rightWall2
walls (19) := leftWall3
walls (20) := rightWall3
walls (21) := leftWall4
walls (22) := rightWall4
walls (23) := leftWall5
walls (24) := rightWall5
walls (25) := centerWall1
walls (26) := centerWall2
walls (27) := centerWall3
walls (28) := centerWall4
walls (29) := centerWall5
walls (30) := leftWall6
walls (31) := rightWall6
walls (32) := upperWall1
walls (33) := upperWall2
walls (34) := upperWall3
walls (35) := upperWall4
walls (36) := upperWall5
walls (37) := upperWall6
walls (38) := upperWall7
walls (39) := upperWall8
walls (40) := upperWall9
walls (41) := upperWall10
walls (42) := upperWall11
walls (43) := upperWall12
walls (44) := upperWall13
walls (45) := upperWall14

var leftTelePad : ^Rectangle
new leftTelePad
leftTelePad -> setRectangle (-12, 140, 0, 16)

var rightTelePad : ^Rectangle
new rightTelePad
rightTelePad -> setRectangle (224 + 12, 140, 0, 16)

var pellets : array 0 .. 1123 of ^Pellet
var totalPellets := 0

for i : 0 .. 25 % Bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 27, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 51, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75 + (8 * i), 51, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 51, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 51, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

var newPellet1 : ^Pellet
new newPellet1
newPellet1 -> setPellet (8, 72, true)
newPellet1 -> setFrames (20)

pellets (totalPellets) := newPellet1
totalPellets := totalPellets + 1

var newPellet2 : ^Pellet
new newPellet2
newPellet2 -> setPellet (208, 72, true)
newPellet2 -> setFrames (20)

pellets (totalPellets) := newPellet2
totalPellets := totalPellets + 1

var newPellet3 : ^Pellet
new newPellet3
newPellet3 -> setPellet (8, 232, true)
newPellet3 -> setFrames (20)

pellets (totalPellets) := newPellet3
totalPellets := totalPellets + 1

var newPellet4 : ^Pellet
new newPellet4
newPellet4 -> setPellet (208, 232, true)
newPellet4 -> setFrames (20)

pellets (totalPellets) := newPellet4
totalPellets := totalPellets + 1

for i : 0 .. 1 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 75, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 75, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 75, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (195 + (8 * i), 75, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 99, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 99, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 99, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 99, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 9 % Top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 251, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 9 % Top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (131 + (8 * i), 251, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 219, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 13 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 219, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 219, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 195, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75 + (8 * i), 195, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 195, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 195, false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 35 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 35 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 35 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 35 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (27, 59 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75, 59 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (147, 59 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (195, 59 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 24 % Left column GIANT DONG
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (51, 51 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 24 % Right column GIANT DONG
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (171, 51 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 83 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 83 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 83 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 83 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 203 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 243 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75, 203 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 227 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 227 + (8 * i), false)


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (147, 203 + (8 * i), false)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 243 + (8 * i), false)


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 203 + (8 * i), false)


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for


var titleCredits : ^AnimationRectangle
new titleCredits
titleCredits -> setRectangle (17, 1, 71, 7)
titleCredits -> setFrames (iTextCredit, 38, 0, 0)






% Draws the splash screen
drawfillbox (0, 0, maxx, maxy, black)

Font.Draw ("PACMAN", xMenuOff, yMenuOff, Font.New (typeface + ":121:bold"), white)
Font.Draw ("CODED BY SAMSON CLOSE", xMenuOff + 4, yMenuOff - 20, Font.New (typeface + ":8:bold"), white)
View.Update

loop
    currentTime := Time.Elapsed
    exit when currentTime >= 2000
end loop






























% The main gameloop
loop
    currentTime := Time.Elapsed

    if (currentTime > lastTick + tickInterval) then
	if inGame = true then

	    gameInput

	    gameMath

	    updateAI

	    drawPlayScreen

	else

	    menuInput

	    drawMenuScreen

	end if

	lastTick := currentTime
    end if

    % Updates the frame
    View.Update
end loop

% Updates the AI to move towards the closest ball
body proc updateAI

end updateAI

% Does additional game functions that isn't in Input or Rendering or AI
body proc gameMath
    if User -> isTouching (leftTelePad) then
	User -> setPosition (219, 140)
    elsif User -> isTouching (rightTelePad) then
	User -> setPosition (-11, 140)
    end if

    var playerPelletRect : ^Rectangle
    new playerPelletRect
    playerPelletRect -> setRectangle (User -> x + 6, User -> y + 6, User -> width - 12, User -> height - 12)

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> update (playerPelletRect)
	end if
    end for

end gameMath

% Draws the screen
body proc drawPlayScreen
    % Draws the background
    drawfillbox (0, 0, maxx, maxy, black)

    Pic.Draw (iMap, 0, 0, picUnderMerge)

    User -> draw

    for i : 0 .. upper (walls)
	walls (i) -> draw (false)
    end for

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> draw
	end if
    end for
end drawPlayScreen

% Detects when players presses the key for in-game
body proc gameInput
    var autoUpOverride := true
    var autoDownOverride := true
    var autoRightOverride := true
    var autoLeftOverride := true

    var chars : array char of boolean
    Input.KeyDown (chars)

    if (chars (KEY_UP_ARROW)) then
	if User -> collisionMove (0, 1, walls) then
	    autoUpOverride := true
	end if
    else
	autoUpOverride := false
    end if

    if (chars (KEY_DOWN_ARROW)) then
	if User -> collisionMove (0, -1, walls) then
	    autoDownOverride := true
	end if
    else
	autoDownOverride := false
    end if

    if (chars (KEY_RIGHT_ARROW)) then
	if User -> collisionMove (1, 0, walls) then
	    autoRightOverride := true
	end if
    else
	autoRightOverride := false
    end if

    if (chars (KEY_LEFT_ARROW)) then
	if User -> collisionMove (-1, 0, walls) then
	    autoLeftOverride := true
	end if
    else
	autoLeftOverride := false
    end if

    if User -> direction = Direction.right and not autoRightOverride then
	if not User -> autoCollisionMove (1, 0, walls) then

	end if
    elsif User -> direction = Direction.left and not autoLeftOverride then
	if not User -> autoCollisionMove (-1, 0, walls) then

	end if
    elsif User -> direction = Direction.up and not autoUpOverride then
	if not User -> autoCollisionMove (0, 1, walls) then

	end if
    elsif User -> direction = Direction.down and not autoDownOverride then
	if not User -> autoCollisionMove (0, -1, walls) then

	end if
    end if


    if (chars ('r')) then
	reset
    end if

    if chars (KEY_ESC) then
	inGame := false
	reset
    end if
end gameInput


body proc addScore

end addScore

% Resets the in game values
body proc reset
    setupNextLevel
    score := 0
end reset

body proc setupNextLevel
    User -> setPosition (104, 68)
    User -> setDirection (Direction.up)

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> reset
	end if
    end for
end setupNextLevel

%Draws the menu screen
body proc drawMenuScreen

    % Draws the background
    drawfillbox (0, 0, maxx, maxy, black)

    drawText (26, 280, FontType.normal_pink, "1UP")
    drawText (73, 280, FontType.normal_pink, "HIGH SCORE")
    drawText (177, 280, FontType.normal_pink, "2UP")

    drawText (57, 241, FontType.normal_pink, "CHARACTER / NICKNAME")
    
    Pic.Draw (iTitle, 0, 0, picUnderMerge)

    Pic.Draw (iLargePellet (0), 80 * 2, 72 * 2, picUnderMerge)
    Pic.Draw (iSmallPellet (0), (83 * 2) - 6, (91 * 2) - 6, picUnderMerge)

    Pic.Draw (iBlinkyRight (0), (33 * 2) - 2, (222 * 2) - 2, picUnderMerge)
    Pic.Draw (iPinkyRight (0), (33 * 2) - 2, (198 * 2) - 2, picUnderMerge)
    Pic.Draw (iInkyRight (0), (33 * 2) - 2, (174 * 2) - 2, picUnderMerge)
    Pic.Draw (iClydeRight (0), (33 * 2) - 2, (150 * 2) - 2, picUnderMerge)

    Pic.Draw (iScaredGhost (0), (89 * 2) - 2, (117 * 2) - 2, picUnderMerge)
    Pic.Draw (iScaredGhost (0), (104 * 2) - 1, (117 * 2) - 2, picUnderMerge)
    Pic.Draw (iScaredGhost (0), (120 * 2) - 2, (117 * 2) - 2, picUnderMerge)

    titleCredits -> draw

end drawMenuScreen

% Tracks the last value (used for filtering input)
var upLast := false
var downLast := false
var leftLast := false
var rightLast := false

% Detects when players hit a key on the menu screen
body proc menuInput
    var chars : array char of boolean
    Input.KeyDown (chars)

    var keyUp := chars (KEY_UP_ARROW)
    var keyDown := chars (KEY_DOWN_ARROW)
    var keyLeft := chars (KEY_LEFT_ARROW)
    var keyRight := chars (KEY_RIGHT_ARROW)

    if keyUp and not upLast then

    end if

    if keyDown and not downLast then

    end if

    if keyLeft and not leftLast then

    end if

    if keyRight and not rightLast then

    end if

    if chars (KEY_ENTER) then
	inGame := true
	reset
    end if

    % Updates the filtering variables (MUST BE LAST)
    upLast := keyUp
    downLast := keyDown
    leftLast := keyLeft
    rightLast := keyRight
end menuInput

% Draws a number (used to draw the score)
body proc drawText
    for i : 1 .. length (text)
	if not text (i) = " " then
	    var letterOrdinal := 0

	    if text (i) = "0" then
		letterOrdinal := 0
	    elsif text (i) = "1" then
		letterOrdinal := 1
	    elsif text (i) = "2" then
		letterOrdinal := 2
	    elsif text (i) = "3" then
		letterOrdinal := 3
	    elsif text (i) = "4" then
		letterOrdinal := 4
	    elsif text (i) = "5" then
		letterOrdinal := 5
	    elsif text (i) = "6" then
		letterOrdinal := 6
	    elsif text (i) = "7" then
		letterOrdinal := 7
	    elsif text (i) = "8" then
		letterOrdinal := 8
	    elsif text (i) = "9" then
		letterOrdinal := 9
	    elsif text (i) = "A" or text (i) = "a" then
		letterOrdinal := 10
	    elsif text (i) = "B" or text (i) = "b" then
		letterOrdinal := 11
	    elsif text (i) = "C" or text (i) = "c" then
		letterOrdinal := 12
	    elsif text (i) = "D" or text (i) = "d" then
		letterOrdinal := 13
	    elsif text (i) = "E" or text (i) = "e" then
		letterOrdinal := 14
	    elsif text (i) = "F" or text (i) = "f" then
		letterOrdinal := 15
	    elsif text (i) = "G" or text (i) = "g" then
		letterOrdinal := 16
	    elsif text (i) = "H" or text (i) = "h" then
		letterOrdinal := 17
	    elsif text (i) = "I" or text (i) = "i" then
		letterOrdinal := 18
	    elsif text (i) = "J" or text (i) = "j" then
		letterOrdinal := 19
	    elsif text (i) = "K" or text (i) = "k" then
		letterOrdinal := 20
	    elsif text (i) = "L" or text (i) = "l" then
		letterOrdinal := 21
	    elsif text (i) = "M" or text (i) = "m" then
		letterOrdinal := 22
	    elsif text (i) = "N" or text (i) = "n" then
		letterOrdinal := 23
	    elsif text (i) = "O" or text (i) = "o" then
		letterOrdinal := 24
	    elsif text (i) = "P" or text (i) = "p" then
		letterOrdinal := 25
	    elsif text (i) = "Q" or text (i) = "q" then
		letterOrdinal := 26
	    elsif text (i) = "R" or text (i) = "r" then
		letterOrdinal := 27
	    elsif text (i) = "S" or text (i) = "s" then
		letterOrdinal := 28
	    elsif text (i) = "T" or text (i) = "t" then
		letterOrdinal := 29
	    elsif text (i) = "U" or text (i) = "u" then
		letterOrdinal := 30
	    elsif text (i) = "V" or text (i) = "v" then
		letterOrdinal := 31
	    elsif text (i) = "W" or text (i) = "w" then
		letterOrdinal := 32
	    elsif text (i) = "X" or text (i) = "x" then
		letterOrdinal := 33
	    elsif text (i) = "Y" or text (i) = "y" then
		letterOrdinal := 34
	    elsif text (i) = "Z" or text (i) = "z" then
		letterOrdinal := 35
	    elsif text (i) = "." then
		letterOrdinal := 36
	    elsif text (i) = "!" then
		letterOrdinal := 37
	    elsif text (i) = "/" then
		letterOrdinal := 38
	    elsif text (i) = "\"" then
		letterOrdinal := 39
	    elsif text (i) = "-" then
		letterOrdinal := 40
	    end if
	    
	    var picID : int

	    if font = FontType.normal_white then
		picID := iWhiteText (letterOrdinal)
	    elsif font = FontType.normal_pink then
		picID := iPinkText (letterOrdinal)
	    end if

	    Pic.Draw (picID, (x * 2) - 4 + ((i - 1) * 16), (y * 2) - 2, picUnderMerge)
	end if
    end for
end drawText
