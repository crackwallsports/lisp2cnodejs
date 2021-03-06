;; Package
(in-package :cl-user)
(defpackage lisp2cnodejs.css
  (:use :cl :xt3.web.base)
  (:import-from :lisp2cnodejs.config
                :*static-directory*))
(in-package :lisp2cnodejs.css)

(->file
 (merge-pathnames #P"css/main.css" *static-directory*)
 #'->css
 `((* ( ;; :border "1px dashed red"
       :box-sizing "border-box"
       :padding 0 :margin 0))
   (html (:font-size "62.5%"))
   (body (:line-height "1.8"))
   (a (:text-decoration "none"))
   ("ul, li" (:list-style "none"))
   
   ;; 
   (".navbar" (:border-radius "0")
              (".navbar-brand" (:padding "0px 20px")
                               (img (:width "120px"
                                            :height "100%"))))
   (".breadcrumb" (:padding 0
                            :margin 0))
   ;; Site Footer
   (".site-footer" (:padding "3rem 0" :height "130px" :width "100%"
                             :text-align "center"
                             :color "#bbc7cc" :background-color "#f9f9f9"
                             :font-size "1.6rem" :line-height "1.6em"))
   ))
