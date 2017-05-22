(def fb (mmap "/framebuffer"))
(def f (open "/framebuffer"))

(def width (recv (open "/framebuffer/width")))
(def height (recv (open "/framebuffer/height")))
(def depth (recv (open "/framebuffer/depth")))
(def pitch (* depth width))

(def goa-main
 (fn
  (do
   (let c 0)
   (let tick 0)
   (while 1
    (do
     (let c (+ 1 c))
     (let b height)
     (while b
      (do
       (let b (- b 1))
       (let a width)
       (while a
        (do
         (let a (- a 1))
         (put32 fb (+ a (+ a (* b pitch))) (* 0x1000 (* a (+ c b))))))
       (gc)))
     (let tick (+ tick 1))
     (send f 0))))))

(goa-main)
