(in-package :lisp2cnodejs.view)

(defun layout-template (args &key (title "标题") links head-rest content scripts)
  `(,(doctype)
     (html (:lang "en")
           (head ()
                 (meta (:charset "utf-8"))
                 (meta (:name "viewport"
                              :content "width=device-width, initial-scale=1, shrink-to-fit=no"))
                 (meta (:name "description" :content "?"))
                 (meta (:name "author" :content "Xt3"))
                 (title nil ,title)
                 ,@links
                 ,@head-rest)
           (body ()
                 ,(header-navbar args)
                 ,@content
                 ,(site-footer)
                 ,@scripts))))

(defun get-resource (str) 
  str 
  "/images/cnodejs_light.svg")

(defparameter *web-links*
  (list
   ;; Main
   :main-css '(link (:rel "stylesheet" :href "/css/main.css"))
   :main-js '(script (:src "/js/main.js"))
   ;; jQuery
   :jq-js '(script (:src "https://code.jquery.com/jquery-3.2.1.js"
                    :integrity "sha256-DZAnKJ/6XZ9si04Hgrsxu/8s717jcIzLy3oi35EouyE="
                    :crossorigin "anonymous"))
   ;; Bootstrap
   :bs-css '(link (:crossorigin "anonymous"
                   :rel "stylesheet"
                   :integrity "sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
                   :href "https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css"))
   :bs-js '(script (:crossorigin "anonymous"
                    :src "https://cdn.bootcss.com/bootstrap/3.3.7/js/bootstrap.min.js"
                    :integrity "sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa"))
   ;; Font
   :goo-ft '((link (:rel "stylesheet" :type "text/css"
                    :href "https://fonts.googleapis.com/css?family=Montserrat"))
             (link (:rel "stylesheet" :type "text/css"
                    :href "https://fonts.googleapis.com/css?family=Lato")))
   ;; Markdown Editor
   :md-editor-css '(link (:rel "stylesheet" :href "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css"))
   :md-editor-js '(script (:src "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"))))

;; Header - Navbar
(defun search-frame ()
  '(form (:class "search-form")
        (div (:class "input-group")
             ;; ,(bs-glyphicon "search")
             (span (:class "input-group-addon")
                   (i (:class "glyphicon glyphicon-search")))
         (input (:class "form-control" :id "search" :type "text" :name "search")))))

(defun header-navbar (args)
  (bs-navbar
   `((div (:class "collapse navbar-collapse" :id "myNavbar")
          ,(bs-nav
            `(("首页" :href "/")
              ("新手入门" :href "/getstart")
              ("API" :href "/api")
              ("关于" :href "/about")
              ,@(if (getf args :user)
                    '(("注销" :href "/logout"))
                    '(("注册" :href "/register")
                      ("登录" :href "/login"))))
            :align "right")))
   :style "inverse"
   ;; :fixed "top"
   :brand `(,(bs-nav-collapse "#myNavbar")
             (a (:class "navbar-brand" :href "/")
                (img (:src ,(get-resource "site-logo")
                           :alt "logo"))))))

(defun main-sidebar ()
  (bs-panel
   :style "default"
   :header '((span () "关于"))
   :body '((span () "这是一个论坛"))))

(defun reg-or-login-panel (action form-data buttons)
  `(form (:action ,action :method "post" :class "form-horizontal")
         ,@(loop for i in form-data
              collect
                (destructuring-bind (label id type &optional (name id)) i
                  `(div (:class "form-group")
                        (label (:class "col-sm-offset-2 col-sm-2 control-label") ,label)
                        (div (:class "col-sm-5")
                             (input (:name ,name :type ,type
                                           :id ,id
                                           :class "form-control input-sm"
                                           ;; :size "20"
                                           ))))))
         (div (:class "form-group")
              (div (:class "col-sm-offset-4 col-sm-6")
                   ,@buttons))))

(defun site-footer ()
  `(footer (:class "site-footer")
           (p () "学习测试 纯粹娱乐")
           (p () "Copyright (c) 2017 Xt3")))

;; Error | Success
(defun error-or-success (err suc)
  (cond
    (err `(div (:class "alert alert-danger")
               (strong () ,err)))
    (suc `(div (:class "alert alert-success")
               (strong () ,suc)))
    ;; (format nil "~A" *args*)
    (t "")))

(defun human-date (date)
  (and date
       (multiple-value-bind
             (second minute hour day month year)
           (decode-universal-time date)
         (format nil "~4D.~2,'0D.~2,'0D ~2,'0D:~2,'0D:~2,'0D"
                 year month day hour minute second))))
