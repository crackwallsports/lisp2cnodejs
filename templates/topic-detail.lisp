(in-package :lisp2cnodejs.view)
(my-load "shared")

(defun reply-add-form (action id)
  `(form (:action ,action :method "post"
                  :class "form-horizontal"
                  :id "reply-add-form")
         (div (:class "form-group")
              (input (:name "tid" :type "hidden"
                            :value ,(format nil "~A" id) 
                            :class "form-control input-sm")))
         (div (:class "form-group")
              (div (:class "markdown_editor in_editor")
                   (div (:class "markdown_in_editor")
                        (textarea (:class "editor"
                                          :name "content"
                                          :id "md-editor"
                                          :cols "30"
                                          :rows "10")))))
         (div (:class "form-group editor_buttons")
              ,(bs-btn `("回复")
                       :type "submit"
                       :style "primary"))))

(defun reply-panel (topic)
  (bs-panel
   :style "default"
   :header `(((span () "添加回复")))
   :body `(( ;; Form + Editor
            ,(reply-add-form
              "/reply/add"
              (gethash "id" topic))))))

(defun reply-list (args)
  (bs-panel
   :style "default"
   :header `((span ()
                   ,(getf args :count)
                   "个回复"))
   :body `((,@(loop for reply in (getf args :replys) 
                 collect
                   `(div (:class "cell")
                         (span (:class "reply-author pull-left")
                               ,(gethash "username" reply))
                         (span (:class "reply-time pull-right")
                               ,(human-date (gethash "insertTime" reply)))
                         (div (:class "reply-content")
                              ;; ? markdown
                              ,(markdown:parse (gethash "content" reply)))))))))

(defun detail-main-content (topic)
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `(((span (:class "topic-full-title")
                           ,(gethash "title" topic))
                     (div (:class "changes")
                          (span ()
                                "作者: "
                                ,(gethash "username" topic))
                          (span ()
                                "发布时间: "
                                ,(human-date (gethash "insertTime" topic))))))
          :body `(( ;; Content
                   (div (:class "topic-content")
                        ;; ? markdown
                        ,(markdown:parse (gethash "content" topic))))))))

(defun detail-html-content (args)
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(detail-main-content (getf args :topic))
                 ;; Reply
                 ,(if (plusp (getf args :count))
                      (reply-list args))
                 ,(if (getf args :user)
                      (reply-panel (getf args :topic)))))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defun topic-detail-page (args)
  (layout-template
   args
   :title
   (or (getf args :title) "主题详情")
   :links
   `(,(getf *web-links* :bs-css)
      ,(getf *web-links* :main-css)
      ,(getf *web-links* :md-editor-css))
   :head-rest
   `()
   :content
   (detail-html-content args)
   :scripts
   `(,(getf *web-links* :jq-js)
      ,(getf *web-links* :bs-js)
      ,(getf *web-links* :md-editor-js)
      (script ()
              "var simplemde = new SimpleMDE({ element: document.getElementById(\"md-editor\") });"))))
