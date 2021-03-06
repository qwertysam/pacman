proc playMusic
	Music.PlayFileReturn ("pacman/audio/pacman_alarm1.wav")
    end playMusic
    
% Loop playing background music until 'finished' is true.
process BackgroundMusic
    
    loop
	playMusic
	delay(900)
    end loop


end BackgroundMusic

fork BackgroundMusic            % Start the background music

var x, y, clr : int
loop
    x := Rand.Int (0, maxx)
    y := Rand.Int (0, maxy)
    clr := Rand.Int (0, maxcolor)
    Draw.FillOval (x, y, 30, 30, clr)
    exit when hasch
end loop
Music.PlayFileStop
