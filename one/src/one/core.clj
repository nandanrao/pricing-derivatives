(ns one.core
 (:require [incanter.core :refer :all]
            [incanter.stats :refer :all]
            [incanter.charts :refer :all]
            [clojure.math.numeric-tower :refer [expt]]))

(defn show [chart]
  "Renders a chart and saves the result in a temp file"
  (save chart "/tmp/chart.png" :width 700 :height 500))

;; (reduce #(assoc %1 :last %2 :sum (+ (:sum %1) (* (:last %1) (- %2 (:last %1))))) {:last 0 :sum 0} (psuedo-brownian 1000 1))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exercise 2.1
(defn make-walk
  ([steps] (make-walk steps 0))
  ([steps i] (reduce #(conj %1 (+ %2 (last %1))) [i] steps)))

(defn coin-flip [n] (map #(pow -1 %1) (sample-binomial n)))
(defn psuedo-brownian [n t] (make-walk (mult (sqrt ($= t / n)) (coin-flip n))))
(defn save-chart [filename chart] (save chart filename :width 960 :height 720))

(defn plot-walk
  ([n title] (plot-walk n title 5))
  ([n title t]
   (xy-plot (range 0 t (/ t n)) (psuedo-brownian n t)
            :x-label "Time" :y-label "Value" :title title)))

(defn save-walks [n-values]
  (map #(save-chart
         (str "walk_" %1 ".png")
         (plot-walk %1 (str "Random Walk with T = 5 & n = " %1)))
       n-values))

(save-walks [10 50 100 1000])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exercise 2.2

(defn make-time [n t] (range 0 t (/ 1 n)))
(defn plot-stochastic [time mu sigma n fn] (fn (psuedo-brownian n 1) time mu sigma))

(defn plot-single [mu sigma n fn]
  (let [time (make-time 1000 1)]
    (show (xy-plot time (plot-stochastic time mu sigma n fn)))))

(defn geometric [brownian time mu sigma] (map #(exp ($= sigma * %1 + mu * %2)) brownian time))
(defn drift [brownian time mu sigma] (map #($= sigma * %1 + mu * %2) brownian time))
(defn bridge [brownian time mu sigma] (map #($= %1 - %2 * (first brownian)) brownian time))
(defn squared [brownian time mu sigma] (map #($= (expt %1 2) - %2) brownian time))

(save-chart "geometric_05.png"
`            (let [time (make-time 1000 1)]
              (xy-plot time (plot-stochastic time 0.5 1 1000 geometric)
                       :legend true :x-label "Time" :y-label "Value"
                       :series-label "Geometric: mu = 0.5, sigma = 1")))

(defn multi-chart []
  (let [time (make-time 1000 1)]
    {:geometric-05 (plot-stochastic time 0.5 1 1000 geometric)
     :geometric-neg (plot-stochastic time -0.5 1 1000 geometric)
     :drift-small (plot-stochastic time 1.0 0.1 1000 drift)
     :drift-big (plot-stochastic time 0.1 1 1000 drift)
     :bridge (plot-stochastic time 0 0 1000 bridge)
     :squared (plot-stochastic time 0 0 1000 squared)}))

(defn chart-together [mc fn]
  (let [time (make-time 1000 1)]
    (fn (->
         (xy-plot time (:geometric-05 mc) :legend true :x-label "Time" :y-label "Value"
                  :series-label "Geometric: mu = 0.5, sigma = 1")
         (add-lines time (:geometric-neg mc)
                    :series-label "Geometric: mu = -0.5, sigma = 1 ")
         (add-lines time (:drift-small mc)
                    :series-label "Drift: mu = 1, sigma = 0.1")
         (add-lines time (:drift-big mc)
                    :series-label "Drift: mu = 0.1, sigma = 1        ")
         (add-lines time (:bridge mc)
                    :series-label "Brownian Bridge                      ")
         (add-lines time (:squared mc)
                    :series-label "Martingale - Squared Brownian")))))

(defn save-separate [mc]
  (let [time (make-time 1000 1)]
    (save-chart "geometric_05.png" (xy-plot time (:geometric-05 mc)
                                            :legend true :x-label "Time" :y-label "Value"
                                            :series-label "Geometric: mu = 0.5, sigma = 1"))
    (save-chart "geometric_neg.png" (xy-plot time (:geometric-neg mc)
                                             :legend true :x-label "Time" :y-label "Value"
                                             :series-label "Geometric: mu = -0.5, sigma = 1"))
    (save-chart "drift_small.png" (xy-plot time (:drift-small mc)
                                           :legend true :x-label "Time" :y-label "Value"
                                           :series-label "Drift: mu = 1, sigma = 0.1"))
    (save-chart "drift_big.png" (xy-plot time (:drift-big mc)
                                         :legend true :x-label "Time" :y-label "Value"
                                         :series-label "Drift: mu = 0.1, sigma = 1"))
    (save-chart "bridge.png" (xy-plot time (:bridge mc)
                                         :legend true :x-label "Time" :y-label "Value"
                                         :series-label "Brownian Bridge"))
    (save-chart "squared.png" (xy-plot time (:squared mc)
                                          :legend true :x-label "Time" :y-label "Value"
                                          :series-label "Martingale - Squared Brownian"))))

;; Save separate and together the charts!
(let [mul (multi-chart)]
  (chart-together mul #(save-chart "multichart.png" %1))
  (save-separate mul))
