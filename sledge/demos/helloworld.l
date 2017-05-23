(def fb (open "/framebuffer"))
(def refresh (fn (send fb 0)))
(def load (fn path (recv (open path))))

(def width (load "/framebuffer/width"))
(def height (load "/framebuffer/height"))
(def depth (load "/framebuffer/depth"))

(def pixels (mmap "/framebuffer"))
(def pitch (* width depth))

(def font-pixels (load "/sd/unifont.bin"))
(def font-width 4096)
(def font-height 4096)
(def font-pitch 4096)
(def rune-width 16)
(def rune-height 16)
(def rune-mod 256)
(def rune-spacing 8)

(def draw-char
 (fn x y rune
  (do
   (let font-x (* rune-width (% rune rune-mod)))
   (let font-y (* rune-height (/ rune rune-mod)))
   (let font-offset (+ font-x (* font-y font-pitch)))
   (let offset (+ (shl x 1) (* y pitch)))

   (let i 0)
   (while (lt i rune-height)
    (do
     (let j 0)
     (while (lt j rune-width)
      (do
       (let color (get8 font-pixels (+ font-offset (shr j 1))))
       (put8 pixels (+ offset j) color)
       (let j (+ j 1))
       (put8 pixels (+ offset j) color)
       (let j (+ j 1))))
     (let font-offset (+ font-offset font-pitch))
     (let offset (+ offset pitch))
     (let i (+ i 1)))))))

(def draw-string
 (fn x y string
  (do
   (let i 0)
   (let max (size string))
   (let offset x)
   (while (lt i max)
    (do
     (let char (get8 string i))
     (draw-char offset y char)
     (let offset (+ offset rune-spacing))
     (let i (+ i 1)))))))

(draw-string 300 200 "Hello World!")
(refresh)
(gc)
