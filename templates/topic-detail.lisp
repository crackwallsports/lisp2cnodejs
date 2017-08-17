(in-package :lisp2cnodejs.view)
(load "shared")

(defparameter *topic* (getf *args* :topic))
(defparameter *replys* (getf *args* :replys))

(defun reply-add-form (action)
  `(form (:action ,action :method "post"
                  :class "form-horizontal"
                  :id "reply-add-form")
         (div (:class "form-group")
              (input (:name "tid" :type "hidden"
                            :value ,(format nil "~A" (gethash "id" *topic*)) 
                            :class "form-control input-sm")))
         (div (:class "form-group")
              (div (:class "markdown_editor in_editor")
                   (div (:class "markdown_in_editor")
                        (textarea (:class "editor"
                                          :name "content"
                                          :id ""
                                          :cols "30"
                                          :rows "10")))))
         (div (:class "form-group editor_buttons")
              ,(bs-btn `("回复")
                       :type "submit"
                       :style "primary"))))

(defun reply-panel ()
  (bs-panel
   :style "default"
   :header `(((span () "添加回复")))
   :body `(( ;; Form + Editor
            ,(reply-add-form
              "/reply/add")))))

(defun reply-list ()
  (bs-panel
   :style "default"
   :header `((span ()
                   ,(getf *args* :count)
                   "个回复"))
   :body `((,@(loop for reply in *replys*
                 collect
                   `(div (:class "cell")
                         (span (:class "reply-author pull-left")
                               ,(gethash "username" reply))
                         (span (:class "reply-time pull-right")
                               ,(human-date (gethash "insertTime" reply)))
                         (div (:class "reply-content")
                              ;; ? markdown
                              ,(gethash "content" reply))))))))

(defun detail-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `(((span (:class "topic-full-title")
                           ,(gethash "title" *topic*))
                     (div (:class "changes")
                          (span ()
                                "作者: "
                                ,(gethash "username" *topic*))
                          (span ()
                                "发布时间: "
                                ,(human-date (gethash "insertTime" *topic*))))))
          :body `(( ;; Content
                   (div (:class "topic-content")
                        ;; ? markdown
                        ,(gethash "content" *topic*)))))))

(defun detail-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(detail-main-content)
                 ;; Reply
                 ,(if (plusp (getf *args* :count))
                      (reply-list))
                 ,(if (getf *args* :user)
                      (reply-panel))))
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
