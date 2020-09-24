

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

(define-resource reservation ()
  :class (s-prefix "schema:ReserveAction")
  :has-one `(
             (initiative :via ,(s-prefix "ext:initiative") :as "initiative")
             (item :via ,(s-prefix "schema:object") :as "item")
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "reservations"
  )

(define-resource dispatch ()
  :class (s-prefix "schema:SendAction")
  :properties `(
             (:quantity :number ,(s-prefix "ext:itemQuantity"))
                )
  :has-one `(
             (initiative :via ,(s-prefix "ext:initiative") :as "initiative")
             (receipt :via ,(s-prefix "schema:result") :as "receipt")
             (item :via ,(s-prefix "schema:object") :as "item")
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "dispatches"
  )

(define-resource receipt ()
  :class (s-prefix "schema:ReturnAction")
  :properties `(
             (:quantity :number ,(s-prefix "ext:itemQuantity"))
                )

  :has-one `(
             (dispatch :via ,(s-prefix "schema:result") :inverse t :as "dispatch")
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "receipts"
  )

(define-resource transfer ()
  :class (s-prefix "schema:TransferAction")
  :properties `(
                (:on :datetime ,(s-prefix "schema:endTime"))
                (:quantity :number ,(s-prefix "ext:itemQuantity"))
                )
  :has-one `(
             (location :via ,(s-prefix "schema:fromLocation") :as "from")
             (location :via ,(s-prefix "schema:toLocation") :as "to")
             (item :via ,(s-prefix "schema:object") :as "item")
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "transfers"
  )

(define-resource item ()
  :class (s-prefix "ext:Item")
  :properties `(
                (:name :string ,(s-prefix "rdfs:label"))
                (:description :string ,(s-prefix "rdfs:comment"))
                (:container :boolean ,(s-prefix "ext:isContainer"))
                (:max-quantity :number ,(s-prefix "ext:itemQuantity"))
                (:infinite :boolean ,(s-prefix "ext:isInfinite"))
               )
  :has-one `(
             (item :via ,(s-prefix "ext:parent") :as "parent")
             (location :via ,(s-prefix "ext:warehouse") :as "warehouse")
             )
  :has-many `(
              (item :via ,(s-prefix "ext:parent") :inverse t :as "children")
              (transfer :via ,(s-prefix "schema:object") :inverse t :as "transfers")
              (dispatch :via ,(s-prefix "schema:object") :inverse t :as "dispatches")
              (reservation :via ,(s-prefix "schema:object") :inverse t :as "reservations")
              )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "items"
  )


(define-resource initiative ()
  :class (s-prefix "schema:Event")
  :properties `(
                (:name :string ,(s-prefix "rdfs:label"))
                (:description :string ,(s-prefix "rdfs:comment"))
                (:start-date :date ,(s-prefix "schema:startDate"))
                (:end-date :date ,(s-prefix "schema:endDate"))
                )
  :has-one `(
             (location :via ,(s-prefix "schema:location") :as "location")
             )
  :has-many `(
              (reservation :via ,(s-prefix "ext:initiative") :inverse t :as "reservations")
              (dispatch :via ,(s-prefix "ext:initiative") :inverse t :as "dispatches")
              )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "initiatives"
  )

(define-resource location ()
  :class (s-prefix "schema:Place")
  :properties `(
                (:name :string ,(s-prefix "rdfs:label"))
                (:description :string ,(s-prefix "rdfs:comment"))
                (:latitude :number ,(s-prefix "schema:latitude"))
                (:longitude :number ,(s-prefix "schema:longitude"))
                )
  :has-one `(
             (address :via ,(s-prefix "schema:address") :as "address")
             )
  :has-many `(
              (transfer :via ,(s-prefix "schema:fromLocation") :inverse t :as "outbox")
              (transfer :via ,(s-prefix "schema:toLocation") :inverse t :as "inbox")
              (item :via ,(s-prefix "ext:warehouse") :inverse t :as "items")
              (initiative :via ,(s-prefix "schema:location") :inverse t :as "initiatives")
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
  :has-one `(
             (location :via ,(s-prefix "schema:address") :as "location")
             )
  :resource-base (s-url "http://mu.semte.ch/vocabularies/ext/redti")
  :on-path "addresses"
  )

;;
