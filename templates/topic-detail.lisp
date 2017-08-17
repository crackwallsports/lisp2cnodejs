(in-package :lisp2cnodejs.view)
(load "shared")

(defparameter *topics* (getf *args* :topics))

(defun detail-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `(((span (:class "topic-full-title")
                           ,(gethash "title" *topics*))
                     (div (:class "changes")
                          (span ()
                                "作者: "
                                ,(gethash "username" *topics*))
                          (span ()
                                "发布时间: "
                                ,(human-date (gethash "insertTime" *topics*))))))
          :body `((;; Content
                   (div (:class "topic-content")
                        ;; Maybe markdown
                        ,(gethash "content" *topics*))
                   
                   ;; Reply
                   )))))

(defun detail-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(detail-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defmacro topic-detail-page-mac ()
  `(html-template
    (layout-template)
    ,(merge-args
      *args*
      `(:title
        "Login"
        :links
        `(,(getf *web-links* :bs-css)
           ,(getf *web-links* :main-css))
        :head-rest
        `()
        :content `(,@(detail-html-content))
        :scripts
        `(,(getf *web-links* :jq-js)
           ,(getf *web-links* :bs-js))))))

(defun topic-detail-page ()
  (topic-detail-page-mac))
