(in-package :cl-user)
(defpackage xt3.web.base
  (:use :cl)
  (:export :concat
           :join-string-list
           :make-keyword
           :->file
           :html-template
           :->html
           :->css
           :layout-template
           :doctype))
(in-package :xt3.web.base)


;; Help
(defmacro ppmace (macro)
  (pprint (macroexpand-1 macro)))

(defun concat (&rest rest)
  (join-string-list rest :join ""))

(defun join-string-list (ls &key (join " "))
  "list -(Concat by str)-> strings"
  (let ((str (concatenate 'string "~{~A~^" join "~}")))
    (format nil str ls)))

(defmacro case-str (str &body body)
  `(cond
     ,@(loop for pair in body
          collect
            (let ((s (car pair))
                  (e (cadr pair)))
              (cond
                ((stringp s)
                 (list `(string-equal ,str ,s) e))
                ((listp s)
                 (list
                  `(or ,@(loop for i in s
                            collect `(string-equal ,str ,i)))
                  e))
                ((eql s 't)
                 (list 't e))
                (t (error "is not a string or list")))))))

(defun make-keyword (name)
  (values (intern (string-upcase name) "KEYWORD")))  

(defun ->file (path f2str obj)
  (with-open-file (stream path
                          :direction :output
                          :if-exists :supersede
                          :external-format :utf-8)
    (format stream (funcall f2str obj))))

(defmacro html-template (html &optional args)
  `(let* ,(loop for (key value) on args by #'cddr
            collect (list (intern (symbol-name key)) value))
     ,html))



;; Format
(defun attribute-format
    (att &key result (att-val "~(~A~)=\"~A\"") (separator ""))
  (cond
    ((null att) "")
    ((listp att)
     (format nil result (join-string-list
                         (loop for (name value) on att by #'cddr
                            collect (format nil att-val name value))
                         :join separator)))
    (t (error "Attribute argument isn't a list"))))

(defun html-format (tag att)
  (let ((fatt (attribute-format att
                                :result " ~A"
                                :att-val "~(~A~)=\"~A\""
                                :separator " ")))
    (case-str (symbol-name tag)
      (("meta" "br" "link" "input")
       (format nil "<~(~A~)~A>~A~%" tag fatt "~A"))
      (t
       (format nil "<~(~A~)~A>~A</~(~A~)>~%" tag fatt "~A" tag)))))

(defun css-format (sel att)
  (if (null att)
      ""
      (let ((fatt (attribute-format att
                                    :result "~A"
                                    :att-val "~%  ~(~A~): ~A"
                                    :separator ";")))
        (format nil "~(~A~) {~A~%}" sel fatt))))

(defun pc-sel (sel parent)
  (if parent
      (format nil "~A ~A" parent sel)
      sel))

;; -> HTML5 
(defun doctype (&key (type 'html5))
  (case type
    (html5 "<!DOCTYPE html>")
    (t "???")))

(defun ->html (exp)
  (cond
    ((null exp) "")
    ((listp exp)
     (if (symbolp (car exp))
         (destructuring-bind (tag &optional att &rest child) exp
           (format nil (html-format tag att)
                   (->html child)))
         (join-string-list (loop for c in exp collect (->html c)) :join "")))
    (t (format nil "~A" exp))))

;; ->CSS3
(defun ->css (exp)
  (join-string-list (l-css exp) :join "~%"))

(defun l-css (exp &optional parent)
  (cond
    ((null exp) nil)
    ((listp exp)
     (let ((head (car exp)))
       (if (or (listp head) (and (stringp head) (search "{" head)))
           (let ((ls))
             (loop for c in exp do (setf ls (nconc ls (l-css c parent))))
             ls)
           (destructuring-bind (sel &optional att &rest child) exp
             (let* ((sels (pc-sel sel parent))
                    (str (css-format sels att)))
               (if (equal str "")
                   (l-css child sels)
                   (cons str (l-css child sels))))))))
    (t (list (format nil "~A" exp)))))



;; ->Lisp
(defun html->lisp (str)
  (let ((*print-case* :downcase))
    (pprint (loop for i across (plump:children (plump:strip (plump:parse str)))
               unless (plump:comment-p i)
               collect (hl-help i)))))

(defun hl-help (node)
  (cond ((plump:text-node-p node)
         (plump:text node))
        ((plump:element-p node)
         (nconc (list (intern (string-upcase (plump:tag-name node))))
                (let ((atts))
                  (maphash #'(lambda (k v)
                               (push v atts)
                               (push (make-keyword k) atts))
                           (plump:attributes node))
                  (list atts))
                (loop for i across (plump:children node)
                   unless (plump:comment-p i)
                   collect (hl-help i))))))

;; Color
(defun random-color ()
  (concat "rgb(" (random 255) ", " (random 255) ", " (random 255) ")"))

(defparameter *css-palette*
  '((:red "#f44336") (:pink "#ff4081")
    (:purple "#aa00ff") (:indigo "#3f51b5") (:blue "#4481ff") (:lblue "#40c4ff")
    (:teal "#00897b") (:green "#00c853") (:lgreen "#b2ff59")
    (:lime "#cddc39") (:yellow "#ffea00") (:orange "#ff9100")
    (:brown "#5d4037") (:grey "#bdbdbd")))

(defun css-color (color-key)
  (second (assoc color-key *css-palette*)))

  

