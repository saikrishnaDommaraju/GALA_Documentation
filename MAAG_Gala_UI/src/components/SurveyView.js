import React, { useCallback, useContext, useRef } from "react";
import { StylesManager, Model } from "survey-core";
import { Survey } from "survey-react-ui";
import DOMPurify from "dompurify";

import "survey-core/modern.min.css";
import "./SurveyView.css";
import stylePDF from "./PdfView.module.css";

import ScrollDiv from "../UI/ScrollDiv";
import axios from "../helpers/axios-instance";
import AuthContext from "../store/auth-context";

const SurveyView = (props) => {
  const authCtx = useContext(AuthContext);
  const prevPageRef = useRef();
  const nextPageRef = useRef();

  var survey = new Model();
  StylesManager.applyTheme("modern");

  if (typeof props.survey === "object") {
    survey = new Model(props.survey.questions);

    if (props.survey.response !== undefined && props.survey.response !== "") {
      const sResp = JSON.parse(props.survey.response);
      const rData = {};
      for (let i = 0; i < sResp.length; i++) {
        rData[sResp[i].name] = sResp[i].value;
      }
      survey.data = rData;
    }
  }

  if (authCtx.userData.readOnly) {
    survey.mode = "display";
  }

  survey.completeText = "Save";

  const storeResults = useCallback(
    (sender) => {
      nextPageRef.current.classList.add("sv-hidden");
      prevPageRef.current.classList.add("sv-hidden");

      const results = sender.getPlainData({
        includeEmpty: true,
        includeQuestionTypes: true,
      });

      axios
        .post("/checklist/response", {
          Id: props.survey.id,
          ProjNo: props.projNo,
          AllData: JSON.stringify(results),
          Answers: JSON.stringify(survey.data),
        })
        .catch(() => {
          alert(
            "An error occured while saving the response. Please tell the admin what you were doing before submitting."
          );
        });
    },
    [survey.data, props.survey.id, props.projNo]
  );

  survey.onComplete.add(storeResults);

  survey.onTextMarkdown.add((_, options) => {
    options.html = DOMPurify.sanitize(options.text, {
      USE_PROFILES: { html: true },
    });
  });

  const completePageFunc = () => survey.completeLastPage();
  const prevPageFunc = () => survey.prevPage();
  const nextPageFunc = () => survey.nextPage();

  survey.onCurrentPageChanged.add(() => {
    prevPageRef.current.classList.remove("sv-hidden");
    if (survey.isFirstPage) {
      prevPageRef.current.classList.add("sv-hidden");
    }

    nextPageRef.current.classList.remove("sv-hidden");
    if (survey.isLastPage) {
      nextPageRef.current.classList.add("sv-hidden");
    }
  });

  const renderExternalNavigation = () => {
    if (survey.state !== "running") return undefined;

    if (nextPageRef.current) nextPageRef.current.classList.remove("sv-hidden");
    if (prevPageRef.current) prevPageRef.current.classList.add("sv-hidden");

    return (
      <div className="sv--navigation-block">
        <button
          className="sv-btn sv-btn--navigation"
          style={{ background: "#1e90ff" }}
          onClick={completePageFunc}
        >
          <span className="icon-ok"></span>
          {survey.completeText}
        </button>
        <button
          className="sv-btn sv-btn--navigation"
          onClick={nextPageFunc}
          ref={nextPageRef}
        >
          {survey.pageNextText}
        </button>
        <button
          className="sv-btn sv-btn--navigation sv-hidden"
          onClick={prevPageFunc}
          ref={prevPageRef}
        >
          {survey.pagePrevText}
        </button>
        <div className="clear"></div>
      </div>
    );
  };

  var myCss = {
    question: {
      description:
        "sd-description sd-question__description sd-question_description_custom",
    },
    panel: {
      description:
        "sd-description sd-panel__description sd-panel_description_custom",
    },
  };

  return (
    <div className={stylePDF.pdfview}>
      {renderExternalNavigation()}
      <ScrollDiv scrollheight="130px">
        <Survey model={survey} css={myCss} />
      </ScrollDiv>
    </div>
  );
};

export default React.memo(SurveyView);
