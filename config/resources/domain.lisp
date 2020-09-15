

(in-package :mu-cl-resources)

;;;;
;; NOTE
;; docker-compose stop; docker-compose rm; docker-compose up
;; after altering this file.

;; Describe your resources here

;; The general structure could be described like this:
;;
;; (define-resource <name-used-in-this-file> ()
;;   :class <class-of-resource-in-triplestore>
;;   :properties `((<json-property-name-one> <type-one> ,<triplestore-relation-one>)
;;                 (<json-property-name-two> <type-two> ,<triplestore-relation-two>>))
;;   :has-many `((<name-of-an-object> :via ,<triplestore-relation-to-objects>
;;                                    :as "<json-relation-property>")
;;               (<name-of-an-object> :via ,<triplestore-relation-from-objects>
;;                                    :inverse t ; follow relation in other direction
;;                                    :as "<json-relation-property>"))
;;   :has-one `((<name-of-an-object :via ,<triplestore-relation-to-object>
;;                                  :as "<json-relation-property>")
;;              (<name-of-an-object :via ,<triplestore-relation-from-object>
;;                                  :as "<json-relation-property>"))
;;   :resource-base (s-url "<string-to-which-uuid-will-be-appended-for-uri-of-new-items-in-triplestore>")
;;   :on-path "<url-path-on-which-this-resource-is-available>")


;; An example setup with a catalog, dataset, themes would be:
;;
;; (define-resource catalog ()
;;   :class (s-prefix "dcat:Catalog")
;;   :properties `((:title :string ,(s-prefix "dct:title")))
;;   :has-many `((dataset :via ,(s-prefix "dcat:dataset")
;;                        :as "datasets"))
;;   :resource-base (s-url "http://webcat.tmp.semte.ch/catalogs/")
;;   :on-path "catalogs")

;; (define-resource dataset ()
;;   :class (s-prefix "dcat:Dataset")
;;   :properties `((:title :string ,(s-prefix "dct:title"))
;;                 (:description :string ,(s-prefix "dct:description")))
;;   :has-one `((catalog :via ,(s-prefix "dcat:dataset")
;;                       :inverse t
;;                       :as "catalog"))
;;   :has-many `((theme :via ,(s-prefix "dcat:theme")
;;                      :as "themes"))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/datasets/")
;;   :on-path "datasets")

;; (define-resource distribution ()
;;   :class (s-prefix "dcat:Distribution")
;;   :properties `((:title :string ,(s-prefix "dct:title"))
;;                 (:access-url :url ,(s-prefix "dcat:accessURL")))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/distributions/")
;;   :on-path "distributions")

;; (define-resource theme ()
;;   :class (s-prefix "tfdcat:Theme")
;;   :properties `((:pref-label :string ,(s-prefix "skos:prefLabel")))
;;   :has-many `((dataset :via ,(s-prefix "dcat:theme")
;;                        :inverse t
;;                        :as "datasets"))
;;   :resource-base (s-url "http://webcat.tmp.tenforce.com/themes/")
;;   :on-path "themes")
(define-resource item ()
  :class (s-prefix "ext:Item")
  :properties `(
                (:name :string ,(s-prefix "rdfs:label"))
                (:description :string ,(s-prefix "rdfs:comment"))
                (:unit :string ,(s-prefix "ext:unit"))
                (:quantity :number ,(s-prefix "ext:quantity"))
                (:container :boolean ,(s-prefix "ext:isContainer"))
               )
  :has-one `(
             (item :via ,(s-prefix "ext:parent") :as "parent")
             (last-transfer :via ,(s-prefix "ext:lastTransfer"))
             )
  :has-many `(
              (item :via ,(s-prefix "ext:parent") :inverse t :as "children")
              (transfer :via ,(s-prefix "schema:object") :inverse t :as "transfers")
              )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "items"
  )
(define-resource transfer ()
  :class (s-prefix "schema:TransferAction")
  :properties `((:on :datetime ,(s-prefix "schema:endTime")))
  :has-one `(
             (location :via ,(s-prefix "schema:fromLocation") :as "from")
             (location :via ,(s-prefix "schema:toLocation") :as "to")
             (item :via ,(s-prefix "schema:object"))
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "transfers"
  )
(define-resource location ()
  :class (s-prefix "schema:Place")
  :properties `(
                (:name :string ,(s-prefix "rdfs:label"))
                (:description :string ,(s-prefix "rdfs:comment"))
                )
  :has-one `(
             (address :via ,(s-prefix "schema:address"))
             )
  :has-many `(
              (transfer :via ,(s-prefix "schema:fromLocation") :inverse t :as "outbox")
              (transfer :via ,(s-prefix "schema:toLocation") :inverse t :as "inbox")
              )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "locations"
  )
(define-resource address ()
  :class (s-prefix "schema:PostalAddress")
  :properties `(
                (:country :string ,(s-prefix "schema:addressCountry"))
                (:region :string ,(s-prefix "schema:addressRegion"))
                (:postal-code :string ,(s-prefix "schema:postalCode"))
                (:city :string ,(s-prefix "schema:addressLocality"))
                (:street :string ,(s-prefix "schema:streetAddress"))
                )
  :has-many `(
              (location :via ,(s-prefix "schema:address" :inverse t :as "locations"))
              )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "addresses"
  )

;;
