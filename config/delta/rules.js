module.exports = [
  {
    match: {
      // form of element is {subject,predicate,object}
      // predicate: { type: "uri", value: "http://www.semanticdesktop.org/ontologies/2007/03/22/nmo#isPartOf" }
      // predicate: {
      //   type: "uri",
      //   value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
      // },
      // object: {
      //   type: "uri",
      //   value: "http://schema.org/ReserveAction",
      // },
      subject: {},
    },
    callback: {
      url: "http://reservations:8000/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
];
