;; Package
(in-package :cl-user)
(defpackage lisp2cnodejs.js
  (:use :cl :xt3.web.base :parenscript)
  (:import-from :lisp2cnodejs.config
                :*static-directory*)
  ;; (:import-from 
  ;;               :ps
  ;;               :ps*
  ;;               :chain
  ;;               :create
  ;;               :var
  ;;               :)
  )
(in-package :lisp2cnodejs.js)

(->file
 (merge-pathnames "js/main.js" *static-directory*)
 (lambda (ag) (ps* ag))
 '(var x 3))
