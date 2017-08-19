(in-package :cl-user)
(defpackage lisp2cnodejs.view
  (:use :cl :xt3.web.base :xt3.web.bootstrap)
  (:import-from :lisp2cnodejs.config
                :*template-directory*)
  (:import-from :caveman2
                :*response*
                :response-headers)
  (:import-from :parenscript
                :ps
                :chain
                :@
                :create
                :var)
  (:import-from :datafly
                :encode-json)
  (:export :lisp-render
           :render-json
           :*current-user*))
(in-package :lisp2cnodejs.view)

(interpol:enable-interpol-syntax)
(cl-syntax:use-syntax :interpol)  

(defparameter *template-registry* (make-hash-table :test 'equal))

;; (defun render (template-path &optional env)
;;   (let ((template (gethash template-path *template-registry*)))
;;     (unless template
;;       (setf template (djula:compile-template* (princ-to-string template-path)))
;;       (setf (gethash template-path *template-registry*) template))
;;     (apply #'djula:render-template*
;;            template nil
;;            env)))
   
(defun render-json (object)
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (encode-json object))
  


(defparameter *args* ())
(defun merge-args (us them)
  (loop for (k v) on us by #'cddr
     do (let ((p (position k them)))
          (unless (null p)
            (setf (elt them (1+ p)) v))))
  them)
(defun my-load (path)
  (unless (gethash path *template-registry*)
    (let ((*default-pathname-defaults* *template-directory*))
      (load path))
    (setf (gethash path *template-registry*) t)))

;; (defun lisp-render (path &optional args)
;;   (setf *args* args)
;;   (my-load path)
;;   (->html
;;    (funcall (intern (string-upcase #?"${path}-page") :lisp2cnodejs.view))))

(defun lisp-render (path &optional args)
  (my-load path)
  (->html
   (funcall (intern (string-upcase #?"${path}-page")
                    :lisp2cnodejs.view)
            args)))
