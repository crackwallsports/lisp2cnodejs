(in-package :cl-user)
(defpackage :xt3.web.bootstrap
  (:use :cl)
  (:export :bs-container
           :bs-btn
           :bs-icon-input
           :bs-input-btn
           :bs-row-col
           :bs-glyphicon
           :bs-carousel
           :bs-panel
           :bs-navbar
           :bs-nav
           :bs-nav-collapse
           :bs-breadcrumb))
(in-package :xt3.web.bootstrap)

(defun join-class (cll)
  "cll:str-list"
  `(:class ,(join-string-list
             (remove-if #'empty-str-p 
                        cll))))

(defun empty-str-p (str)
  (string= str ""))

(defun empty-str-or (str &key restr (add "") (prefix t))
  (cond
    ((string= str "") "")
    ((not (null restr)) restr)
    ((null prefix) (concat str add))
    (t (concat add str))))

(defun to-list (item)
  (if (listp item) item (list item)))

(defun bs-container (items &key fluid (class "") atts)
  `(div (,@(join-class `(,(if fluid
                              "container-fluid"
                              "container")
                          ,class))
           ,@atts)
        ,@(to-list items)))

(defun bs-btn (items &key (class "") atts (style "") (size "") (type "button"))
  "style:(default primary success info warning danger link)
   size:(lg md sm xs)
   type:(button submit)"
  `(button
    (:type ,type
           ,@(join-class `("btn"
                           ,(empty-str-or style :add "btn-")
                           ,(empty-str-or size :add "btn-")
                           ,class))
           ,@atts)
    ,@(to-list items)))

(defun bs-icon-input (icon id name &key (type "text") (ph name) reverse
(isize "30"))
  (let ((content `((span (:class "input-group-addon")
                         (i (:class ,#?"glyphicon glyphicon-${icon}")))
                   (input (:class "form-control" :id ,id :type ,type :name ,name :placeholder ,ph :size ,isize)))))
    (if reverse (setf content (nreverse content)))
    `(div (:class "input-group")
          ,@content)))

(defun bs-input-btn (id name title &key (type "text") (ph name) reverse (btn-style "") (isize "50"))
  (let ((content `((input (:class "form-control" :id ,id :type ,type :name ,name :placeholder ,ph :required "required" :size ,isize))
                   (div (:class "input-group-btn")
                        (button (:type "button"
                                       ,@(join-class `("btn"
                                                       ,(empty-str-or btn-style :add "btn-"))))
                                ,title)))))
    (if reverse (setf content (nreverse content)))
    `(div (:class "input-group")
          ,@content)))

(defun bs-row-col (items &key (class "") atts (w '("md" "xs" "sm" "lg")) )
  `(div (,@(join-class `("row" ,class)) ,@atts)
        ,@(loop for i in items
             collect (destructuring-bind (size content &key (class "") atts) i
                       (let ((att
                              (join-string-list
                               (mapcar (lambda (w s)
                                         (format nil "col-~A-~A" w s))
                                       w
                                       (to-list size)))))
                         `(div (,@(join-class `(,att ,class)) ,@atts)
                               ,@(to-list content)))))))

(defun bs-glyphicon (style &key (class "") atts)
  `(span (,@(join-class `(,#?"glyphicon glyphicon-${style}"
                             ,class))
            ,@atts)))

(defun bs-carousel (id items &key (class "") atts )
  (let ((ooo) (slides) (count 0))
    (loop for i in items
       do (destructuring-bind (item &key (class "") atts active caption) i
            (push `(li (:data-target ,#?"#${id}"
                                     :class ,(if active "active" "")
                                     :data-slide-to ,count))
                  ooo)
            (incf count)
            (push `(div (,@(join-class `("item"
                                         ,(if active "active" "")
                                         ,class))
                           ,@atts)
                        ,item
                        ,(if caption
                             `(div (:class "carousel-caption") ,@caption)))
                  slides)))
    `(div (,@(join-class `("carousel" ,class))
             :data-ride "carousel"
             :id ,id
             ,@atts)
          ;; ooo 
          (ol (:class "carousel-indicators") ,@(nreverse ooo))
          ;; Slides
          (div (:class "carousel-inner")
               ,@(nreverse slides))
          ;; < >
          ,@(flet ((ctr (side slide title)
                   `(a (:href ,#?"#${id}" 
                              :class ,(concat side " " "carousel-control")
                              :data-slide ,slide)
                       (span (:class ,#?"glyphicon glyphicon-chevron-${side}"))
                       (span (:class "sr-only") ,title))))
            (list (ctr "left" "prev" "Previous")
                  (ctr "right" "next" "Next"))))))

(defun bs-panel (&key header body footer (class "") atts (style ""))
  (flet ((fn (part str)
           (destructuring-bind
                 (item &key (class "") atts) part
             `(div (,@(join-class `(,(concat "panel-" str) ,class)) ,@atts)
                   ,@(to-list item)))))
    `(div (,@(join-class `("panel"
                           ,(empty-str-or style :add "panel-")
                           ,class))
             ,@atts)
          ,(if header (fn header "heading"))
          ,(fn body "body")
          ,(if footer (fn footer "footer")))))

(defun bs-navbar (navs &key brand (class "") atts (style "default") fluid (fixed ""))
  "style:(default inverse) fixed:(top bottom)"
  `(div (,@(join-class `("navbar"
                         ,(empty-str-or style :add "navbar-")
                         ,(empty-str-or fixed :add "navbar-fixed-")
                         ,class))
           ,@atts)
        (div (:class ,(concat "container" (if fluid "-fluid" "")))
             (div (:class "navbar-header")
                  ,@(to-list brand))
             ,@navs)))

(defun bs-nav (items &key (class "") atts (align ""))
  "align:(right left)"
  `(ul (,@(join-class `("nav navbar-nav"
                         ,(empty-str-or align :add "navbar-")
                         ,class)))
        ,@(loop for i in items
             collect
               (destructuring-bind
                     (item &key (class "") atts (href "#") sp) i
                 (if sp
                     item
                     `(li (:class ,class ,@atts)
                          (a (:href ,href)
                             ,@(to-list item))))))))

(defun bs-nav-collapse (target &key (icons 3))
  `(button (:class "navbar-toggle"
                   :type "button"
                   :data-toggle "collapse"
                   :data-target ,target)
        ,@(loop repeat icons
             collect '(span (:class "icon-bar")))))

(defun bs-breadcrumb (pages &key (class "") atts)
  `(ul (,@(join-class `("breadcrumb" ,class))
          ,@atts)
       ,@(loop for i in pages
            collect (destructuring-bind (page &key href (class "") atts) i
                      (if href 
                          `(li (:class ,class ,@atts)
                               (a (:href ,href) ,@(to-list page)))
                          `(li (:class ,class ,@atts)
                               ,@(to-list page)))))))
