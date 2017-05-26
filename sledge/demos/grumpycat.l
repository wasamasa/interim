(def fb (open "/framebuffer"))
(def refresh (fn (send fb 0)))
(def load (fn path (recv (open path))))

(def width (load "/framebuffer/width"))
(def height (load "/framebuffer/height"))
(def depth (load "/framebuffer/depth"))

(def pixels (mmap "/framebuffer"))
(def pitch (* width depth))

(def paint-pixel
 (fn x y color
  (do
   (let offset (+ (* y pitch) (* x depth)))
   (put16 pixels offset color))))

(def paint-image
 (fn x y w h buf
  (do
   (let p (* w depth))
   (let i 0)
   (let max (size buf))
   (while (lt i max)
    (do
     (paint-pixel (/ (+ x (% i p)) 2) (+ y (/ i p)) (get16 buf i))
     (let i (+ i 2)))))))

(def image (load "/sd/demos/grumpycat.565"))
(def dimensions (cons 418 567))

(paint-image 20 20 (car dimensions) (cdr dimensions) image)
(gc)
(refresh)
