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

(def max-pen (shl 2 (- (* 8 depth) 1)))
(def pen 0)

(def paint-palette
 (fn x y
  (do
   (while (lt pen max-pen)
    (do
     (paint-pixel (+ (% pen 256) x) (+ (/ pen 256) y) pen)
     (if (eq (% pen 256) 0) (gc) 0)
     (def pen (+ pen 1)))))))

(def origin
 (cons
  (/ (- width 256) 2)
  (/ (- height 256) 2)))

(def loop
 (fn
  (do
   (paint-palette (car origin) (cdr origin))
   (gc)
   (while 1
    (refresh)))))

(loop)
