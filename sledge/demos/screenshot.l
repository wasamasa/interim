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
