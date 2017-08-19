(in-package :lisp2cnodejs.view)
(my-load "shared")

(defun to-n (d &optional (n 0) (side #'<)) (if (funcall side d n) n d))

(defun topic-list (topics)
  (loop for i in topics
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

(defun index-main-content (args)
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
                  :class "topic-tab")
                 (("我要发话")
                  :href "/topic/create"
                  :class "topic-tab pull-right")))))
          :body
          `((
             ;; Topic List
             (div (:class "topic-list")
                  ,@(topic-list (getf args :topics)))

             ;; Pagination
             ,(let* ((tab (getf args :tab))
                     (page (getf args :page))
                     (pc (getf args :pcount))
                     (pn (remove-if
                          #'null
                          `(,(if (> page 4)
                                 `(("<<")
                                   :href ,(format nil "/?tab=~A&page=1" tab)))
                             ,(if (> page 4)
                                  `(("...")
                                    :href ,(format nil "/?tab=~A&page=~A" tab (to-n (- page 3) 1))))
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
                                    :href ,(format nil "/?tab=~A&page=~A" tab (to-n (+ page 3) pc #'>))))
                             ,(if (and (> page 5) (/= page pc))
                                  `((">>")
                                    :href ,(format nil "/?tab=~A&page=~A" tab pc)))))))
                ;; (format nil "tab=~a page=~a pc=~a" tab page pc )
                (bs-pagination
                 `(,@pn))))))))

(defun index-html-content (args)
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(index-main-content args)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defun index-page (args)
  (layout-template
   args
   :title
   (or (getf args :title) "首页")
   :links
   `(,(getf *web-links* :bs-css)
      ,(getf *web-links* :main-css))
   :head-rest
   `()
   :content
   (index-html-content args)
   :scripts
   `(,(getf *web-links* :jq-js)
      ,(getf *web-links* :bs-js))))
