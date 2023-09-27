import React, { useEffect, useRef } from "react";

import WebViewer from "@pdftron/pdfjs-express-viewer";
import stylePDF from "./PdfView.module.css";

const PDFView = (props) => {
  const viewer = useRef(null);
  const instance = useRef(null);

  useEffect(() => {
    WebViewer(
      {
        path: process.env.PUBLIC_URL + "/pdfjsexpress",
        licenseKey: process.env.REACT_APP_PDFEXPRESS_KEY,
        disabledElements: ["contextMenuPopup"],
      },
      viewer.current
    ).then((inst) => {
      instance.current = inst;

      const docViewer = inst.Core.documentViewer;

      // you must have a document loaded when calling this api
      docViewer.addEventListener("documentLoaded", function () {
        var FitMode = inst.UI.FitMode;
        inst.UI.setFitMode(FitMode.FitWidth);
        //inst.UI.setZoomLevel(1.5); // or setZoomLevel(1.5)
        
        //Update the page number to what was stored earlier
        if (docViewer.getDocument()) {
          let activePage = localStorage.getItem("activePage");
          if (activePage !== "" && activePage !== null) {
            activePage = JSON.parse(activePage);
            const lnk = docViewer.getDocument().getFilename();
            if (activePage[lnk]) docViewer.setCurrentPage(activePage[lnk]);
          }
        }
      });
    });
  }, []);

  // load the doc when filePath changes
  useEffect(() => {
    if (instance.current) {
      //Store the page
      if (
        instance.current.docViewer.getDocument() &&
        instance.current.docViewer.getDocument().getFilename() !== ""
      ) {
        const lnk = instance.current.docViewer.getDocument().getFilename();
        let activePage = localStorage.getItem("activePage");
        if (activePage) {
          activePage = JSON.parse(activePage);
          activePage[lnk] =
            instance.current.Core.documentViewer.getCurrentPage();
          localStorage.setItem("activePage", JSON.stringify(activePage));
        } else {
          localStorage.setItem(
            "activePage",
            JSON.stringify({
              [lnk]: instance.current.Core.documentViewer.getCurrentPage(),
            })
          );
        }
      }

      if (props.docLink !== "") {
        instance.current.loadDocument(props.docLink, { extension: "pdf" });
      } else {
        const docViewer = instance.current.Core.documentViewer;
        docViewer.removeContent(true, true, true);
      }
    }
  }, [props.docLink]);

  return (
    <div
      className={stylePDF.pdfview}
      style={{ display: props.visible ? "block" : "none" }}
    >
      <div className="webviewer" ref={viewer} style={{ height: "100%" }}></div>
    </div>
  );
};

export default React.memo(PDFView);
