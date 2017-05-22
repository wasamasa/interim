(def fb (open "/framebuffer"))
(def refresh (fn (send fb 0)))
(def load (fn path (recv (open path))))

(def width (load "/framebuffer/width"))
(def height (load "/framebuffer/height"))
(def depth (load "/framebuffer/depth"))

(def pixels (mmap "/framebuffer"))
(def pitch (* width depth))

(def black 0x0000)
(def white 0xffff)

(def paint-pixel
 (fn x y color
  (do
   (let offset (+ (* y pitch) (* x depth)))
   (put16 pixels offset color))))

(def munching-square
 (fn x y size scale n
  (do
   (let i 0)
   (let full-size (* size scale))
   (let max (* full-size full-size))
   (while (lt i max)
    (do
     (let row (/ (/ i scale) full-size))
     (let col (% (/ i scale) size))
     (let color (if (lt (bitxor row col) n) black white))
     (paint-pixel (+ x (% i full-size)) (+ y (/ i full-size)) color)
     (let i (+ i 1)))))))

(def loop
 (fn
  (do
   (let i 1)
   (while 1
    (do
     (munching-square 100 100 16 4 i)
     (gc)
     (refresh)
     (if (lt i 16)
      (let i (+ i 1))
      (let i 1)))))))

(loop)
