(def fb (open "/framebuffer"))
(def refresh (fn (send fb 0)))
(def load (fn path (recv (open path))))

(def width (load "/framebuffer/width"))
(def height (load "/framebuffer/height"))
(def depth (load "/framebuffer/depth"))

(def pixels (mmap "/framebuffer"))
(def pitch (* width depth))

(def red   0xf800)
(def green 0x07e0)
(def blue  0x001f)

(def paint-pixel
 (fn x y color
  (do
   (let offset (+ (* y pitch) (* x depth)))
   (put16 pixels offset color))))

(def fill-square
 (fn x y size color
  (do
   (let i 0)
   (let max (* size size))
   (while (lt i max)
    (do
     (paint-pixel (+ x (% i size)) (+ y (/ i size)) color)
     (let i (+ i 1)))))))

;; draw some stuff for the screenshot
(fill-square 20 20 20 red)
(fill-square 50 20 20 green)
(fill-square 80 20 20 blue)
(refresh)

(def screenshot
 (fn path
  (send (open path) pixels)))

(screenshot "/sd/demos/fb.565")

(def write-bytes
 (fn buf offset bytes
  (do
   (let i 0)
   (let max (size bytes))
   (while (lt i max)
    (do
     (put8 buf (+ offset i) (get8 bytes i))
     (let i (+ i 1)))))))

(def swap
 (fn buf offset
  (do
   (let x (get8 buf offset))
   (let y (get8 buf (+ offset 1)))
   (put8 buf offset y)
   (put8 buf (+ offset 1) x))))

;; http://www.fileformat.info/format/bmp/egff.htm
;; BMP v3.0 (NT)
(def bmp-screenshot
 (fn path
  (do
   (let pixels-size (size pixels))
   (let data-offset 66)
   (let file-size (+ data-offset pixels-size))
   (let buf (alloc file-size))

   ;; file header
   (write-bytes buf 0 "BM")        ; magic byte
   (put32 buf 2 file-size)
   (put16 buf 6 0)                 ; reserved
   (put16 buf 8 0)                 ; reserved
   (put32 buf 10 data-offset)

   ;; image header
   (put32 buf 14 40)               ; size of this header
   (put32 buf 18 width)
   (put32 buf 22 height)
   (put16 buf 26 1)                ; number of places
   (put16 buf 28 16)               ; depth
   (put32 buf 30 3)                ; compression method
   (put32 buf 34 pixels-size)
   (put32 buf 38 2835)             ; horizontal resolution in px/m
   (put32 buf 42 2835)             ; vertical resolution in px/m
   (put32 buf 46 (shl 1 16))       ; number of colors in image
   (put32 buf 50 0)                ; important colors

   ;; color masks
   (write-bytes buf 54 [f8000000]) ; red mask
   (write-bytes buf 58 [07e00000]) ; green mask
   (write-bytes buf 62 [001f0000]) ; blue mask

   ;; image data (bottom to top)
   (let row 0)
   (while (lt row height)
    (do
     (let top-offset (+ data-offset (* row pitch)))
     (let bot-offset (* (- (- height row) 1) pitch))
     (write-bytes buf top-offset (substr pixels bot-offset pitch))
     (let row (+ row 1))))

   ;; swapping image data from LE to BE (required for 16-bit images)
   (let i 0)
   (while (lt i pixels-size)
    (do
     (swap buf (+ data-offset i))
     (let i (+ i 2))))

   (send (open path) buf))))

(bmp-screenshot "/sd/demos/fb.bmp")
