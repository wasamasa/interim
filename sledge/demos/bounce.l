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
(def red   0xf800)
(def green 0x07e0)
(def blue  0x001f)

(def keyboard (open "/keyboard"))

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

(def size 50)
(def color black)

(def x 0)
(def y 0)
(def dx 10)
(def dy 5)

(def or (fn a b (if a a b)))
(def <= (fn a b (if (or (lt a b) (eq a b)) 1 0)))
(def >= (fn a b (if (or (gt a b) (eq a b)) 1 0)))
(def min (fn a b (if (lt a b) a b)))
(def max (fn a b (if (gt a b) a b)))

(def loop
 (fn
  (do
   (while 1
    (do
     (fill-square x y size white)
     (def x (+ x dx))
     (def y (+ y dy))

     (if (>= (+ x size) width) (do (def x (- width size)) (def dx (* dx -1))) 0)
     (if (>= (+ y size) height) (do (def y (- height size)) (def dy (* dy -1))) 0)
     (if (<= x 0) (do (def x 0) (def dx (* dx -1))) 0)
     (if (<= y 0) (do (def y 0) (def dy (* dy -1))) 0)

     (fill-square x y size color)

     (let c (get8 (recv keyboard) 0))
     (if (eq c 114) ; r
      (def color red)
      (if (eq c 103) ; g
       (def color green)
       (if (eq c 98) ; b
        (def color blue)
        (if (eq c 27) ; escape
         (def color black)
         0))))

     (gc)
     (refresh))))))

(loop)
