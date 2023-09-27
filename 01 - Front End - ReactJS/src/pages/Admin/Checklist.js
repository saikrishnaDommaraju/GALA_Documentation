import { SurveyCreatorComponent, SurveyCreator } from "survey-creator-react";
import { Serializer } from "survey-core";
import { useState, useEffect } from "react";
import axios from "../../helpers/axios-instance";

import ScrollDiv from "../../UI/ScrollDiv";
import Container from "../../UI/Container";
import styleInp from "../../UI/Input.module.css";
import styles from "./Roles.module.css";
import "./Checklist.css";

import "survey-core/defaultV2.min.css";
import "survey-creator-core/survey-creator-core.min.css";

const creatorOptions = {
  questionTypes: [
    "text",
    "multipletext",
    "checkbox",
    "radiogroup",
    "dropdown",
    "comment",
    "boolean",
    "html",
    "image",
    "rating",
    "ranking",
    "panel",
    "matrix",
    "matrixdropdown",
    "signaturepad",
    "Checkmark",
  ],
  themeForPreview: "modern",
  showSidebar: false,
  isAutoSave: true,
  haveCommercialLicense: true,
};

const defaultJSON = {
  logoPosition: "right",
};

const CheckList = () => {
  const [cList, setCList] = useState([]);
  const [activeCL, setActiveCL] = useState(-1);

  useEffect(() => {
    window.localStorage.removeItem("survey-json");
    axios.get("/checklist/latest").then((response) => {
      setCList(response.data);
    });
  }, []);

  const creator = new SurveyCreator(creatorOptions);
  creator.text =
    window.localStorage.getItem("survey-json") || JSON.stringify(defaultJSON);
  Serializer.findProperty("survey", "logo").visible = false;
  creator.toolbox.forceCompact = true;

  creator.saveSurveyFunc = (saveNo, callback) => {
    window.localStorage.setItem("survey-json", creator.text);
    callback(saveNo, true);
  };

  const saveChecklist = () => {
    if (creator.survey.title === "") {
      alert("Please create the CheckSheet");
      return false;
    }

    let verBump = false;
    if (activeCL > -1) {
      const cL = cList.filter((p) => p.id === activeCL);
      verBump = cL[0].respExists;
      if (verBump) {
        if (
          !window.confirm(
            "This checksheet already has a response. Do you want to update the version?\n\nIt is recommended to update the version for large changes or changes to the names of the questions\n\nOk - Yes, update version\nCancel - No, Use same version"
          )
        ) {
          verBump = false;
        }
      }
    }

    axios
      .post("/checklist", {
        Id: activeCL,
        Name: creator.survey.title,
        verChange: verBump,
        jsonData: creator.text,
      })
      .then((response) => {
        if (activeCL === -1) {
          setCList((prevCL) => {
            let newCL = [...prevCL];
            newCL.push(response.data);
            return newCL;
          });
          setActiveCL(response.data.id);
          alert("Check Sheet Added");
        } else {
          setCList((prevCL) => {
            let newCL = [...prevCL];
            const cIndex = newCL.findIndex((p) => p.id === response.data.oldId);
            newCL[cIndex] = response.data;
            return newCL;
          });
          setActiveCL(response.data.id);
          alert("Check Sheet Updated");
        }
      })
      .catch((error) => {
        alert("Could NOT create or update checksheet");
      });
  };

  const loadChecklistData = (id) => {
    axios.get("/checklist/survey/" + id).then((response) => {
      window.localStorage.setItem("survey-json", JSON.stringify(response.data));
      setActiveCL(id);
    });
  };

  const resetForm = () => {
    window.localStorage.setItem("survey-json", JSON.stringify(defaultJSON));
    setActiveCL(-1);
    creator.text = JSON.stringify(defaultJSON);
  };

  const handleNoteMsg = () => {
    alert(
      "Specific Question Names required for proper functioning of certain features:\n\n" +
        "For the role selection - role\n" +
        "For the model name - model\n" +
        "For Not Applicable Questions - Should start with na_ and reference the panel\n" +
        "For Coordinator Signoff - coordinator_signoff\n\n" +
        "Accessed from the properties panel of that question"
    );
  };

  return (
    <ScrollDiv scrollheight="90px">
      <Container>
        <div className="left" style={{ width: "15%", padding: "10px" }}>
          <h3>Check Sheets</h3>
          <span
            onClick={handleNoteMsg}
            style={{ color: "red", cursor: "pointer", fontWeight: "bold" }}
          >
            !! Important Note !!
          </span>
          <br />
          <br />
          <ul className={styles.roleList}>
            {cList.length > 0 &&
              cList.map((cL) => (
                <li
                  key={"cl-" + cL.id}
                  onClick={() => loadChecklistData(cL.id)}
                >
                  {cL.id === activeCL && <span className="icon-edit"></span>}
                  {cL.name} <em style={{ color: "#757575" }}>v{cL.ver}</em>
                </li>
              ))}
          </ul>
          <button className={styleInp.btn} onClick={saveChecklist}>
            {activeCL === -1 ? "+ Add" : <span> &#10003; Update</span>}
          </button>
          <br />
          <br />
          <span onClick={resetForm} className="link">
            Reset
          </span>
        </div>
        <div className="left" style={{ width: "85%", paddingTop: "20px" }}>
          <SurveyCreatorComponent creator={creator} />
        </div>
        <div className="clear"></div>
      </Container>
    </ScrollDiv>
  );
};

export default CheckList;
