(in-package :lisp2cnodejs.view)
(load "shared")

(defparameter *topics* (getf *args* :topics))

(defun to-n (d &optional (n 0)) (if (< d n) n d))

(defun topic-list ()
  (loop for i in *topics*
     collect
       `(div (:class "cell")
             (span (:class "user-name pull-left")
                   ,(gethash "username" i))
             (div (:class "last-time pull-right")
                (span (:class "last-active-time")
                      ,(human-date (gethash "insertTime" i))))
             (div (:class "topic-title-wrapper")
                  (a (:class "topic-title"
                             :href ,(format nil "/topic/~A"
                                            (gethash "id" i)))
                     ,(gethash "title" i))))))

(defun index-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header
          `((,(bs-breadcrumb
               '((("全部")
                  :href "/"
                  :class "topic-tab current-tab")
                 (("精华")
                  :href "/?tab=tab1"
                  :class "topic-tab")
                 (("分享")
                  :href "/?tab=tab2"
                  :class "topic-tab")))))
          :body
          `((
             ;; Topic List
             (div (:class "topic-list")
                  ,@(topic-list))

             ;; Pagination
             ,(let* ((tab (getf *args* :tab))
                     (page (getf *args* :page))
                     (pc (getf *args* :pcount))
                     (pn (remove-if
                          #'null
                          `(,(if (> page 10)
                                 `(("<<")
                                   :href ,(format nil "/?tab=~A&page=1" tab)))
                             ,(if (> page 4)
                                  `(("...")
                                    :href ,(format nil "/?tab=~A&page=1" tab)))
                             ,@(loop for i from (to-n (- page 3) 1) below page
                                  collect 
                                    `((,i)
                                      :href ,(format nil "/?tab=~A&page=~A" tab i)))
                             ((,page) :class "disabled active")
                             ,@(loop for i from (1+ page) to (min (+ page 3) pc )
                                  collect
                                    `((,i)
                                      :href ,(format nil "/?tab=~A&page=~A" tab i)))
                             ,(if (< (+ page 3) pc)
                                  `(("...")
                                    :href ,(format nil "/?tab=~A&page=~A" tab pc)))
                             ,(if (> page 10)
                                  `((">>")
                                    :href ,(format nil "/?tab=~A&page=~A" tab pc)))))))
                
                (bs-pagination
                 `(,@pn))
                ;; (format nil "tab=~a page=~a pc=~a" tab page pc )
                ))))))

(defun index-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(index-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defmacro index-page-mac ()
  `(html-template
    (layout-template)
    ,(merge-args
      *args*
      `(:title
        "首页"
        :links
        `(,(getf *web-links* :bs-css)
           ,(getf *web-links* :main-css))
        :head-rest
        `((style ()
                 ,(->css
                   '((".navbar" (:border-radius "0")
                      (".navbar-brand" (:padding "0px 20px")
                       (img (:width "120px"
                                    :height "100%"))))
                     (".breadcrumb" (:padding 0
                                     :margin 0))))))
        :content `(,@(index-html-content))
        :scripts
        `(,(getf *web-links* :jq-js)
           ,(getf *web-links* :bs-js))))))

(defun index-page ()
  (index-page-mac))
