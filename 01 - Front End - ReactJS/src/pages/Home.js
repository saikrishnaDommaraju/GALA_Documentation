import { useState, useEffect, useCallback } from "react";
import axios, { BASE_URL } from "../helpers/axios-instance";

import SideBar from "../components/SideBar";
import SideBar1 from "../components/SideBar1";
import SideBar3 from "../components/SideBar3";

import styleSB from "../components/SideBar.module.css";
import PDFView from "../components/PdfView";
import Survey from "../components/SurveyView";

import styleInp from "../UI/Input.module.css";
import ScrollDiv from "../UI/ScrollDiv";
import DrawingNo from "../UI/DrawingNo";

const Home = (props) => {
  const [sidebar1Open, setSidebar1Open] = useState("-open");
  const [sidebar2Open, setSidebar2Open] = useState("-closed");
  const [sidebar2Title, setSidebar2Title] = useState("");
  const [sidebar3Open, setSidebar3Open] = useState("-closed");
  const [sidebar3Title, setSidebar3Title] = useState("");
  const [activeChain, setActiveChain] = useState([-1, ""]);
  const [showPDF, setShowPDF] = useState(true);

  const [projData, setProjData] = useState(false);
  const [sb2Data, setSb2Data] = useState([]);
  const [sb2Holds, setSb2Holds] = useState("");
  const [drawFilter, setDrawFilter] = useState("");
  const [pdfFile, setPdfFile] = useState("");
  const [surveyFile, setSurveyFile] = useState({});
  const [notesPaneParent, setNotesPaneParent] = useState(false);
  const [notesPaneChildren, setNotesPaneChildren] = useState(false);

  const toggleSideBar1Handler = () => {
    setSidebar1Open((prevState) => {
      if (prevState === "-open") {
        return "-closed";
      } else if (prevState === "-closed") {
        return "-open";
      }
    });
    return false;
  };

  const toggleSideBar2Handler = () => {
    setSidebar2Open((prevState) => {
      if (prevState === "-open") {
        return "-closed";
      } else if (prevState === "-closed") {
        return "-open";
      }
    });
  };

  const toggleSideBar3Handler = () => {
    setSidebar3Open((prevState) => {
      if (prevState === "-open") {
        return "-closed";
      } else if (prevState === "-closed") {
        return "-open";
      }
    });
  };

  useEffect(() => {
    setProjData(false);
    setSb2Data([]);
    setSb2Holds("");
    setSidebar2Title("");
    setSidebar3Title("");
    setDrawFilter("");
    setPdfFile("");
    setNotesPaneParent(false);
    setNotesPaneChildren(false);

    if (props.projNo !== "") {
      axios
        .get("/projects/" + props.projNo)
        .then((response) => setProjData(response.data));
    }
  }, [props.projNo]);

  const loadList = useCallback(
    (type, id) => {
      setActiveChain([id, ""]);
      setShowPDF(true);
      setPdfFile(BASE_URL + "/pdf/view/" + id);
      if (type !== null) {
        localStorage.removeItem("activePage");
      }

      //Get the Title
      let listTitle = undefined;
      if (type === null) {
        projData.every((el) => {
          listTitle = el.pdfList.filter((item) => item.id === id)[0];
          if (listTitle !== undefined) {
            return false;
          }
          return true;
        });
      } else {
        listTitle = projData
          .filter((item) => item.type === type)[0]
          .pdfList.filter((item) => item.id === id)[0];
      }

      setSidebar2Title(listTitle.type + " - " + listTitle.jobNumber);
      setSidebar3Title(listTitle.type + " - " + listTitle.jobNumber);
      setNotesPaneParent(listTitle);
      setNotesPaneChildren(false);

      //Load the drawing list from the server
      axios
        .get("/pdf/" + id)
        .then((response) => {
          setSb2Holds("drw");
          setSb2Data(response.data);

          //Show SideBar 2
          setSidebar2Open("-open");
        })
        .catch((error) => alert(error.response.data));
    },
    [projData]
  );

  const searchChangeHandler = (e) => setDrawFilter(e.target.value);

  const loadDraw = (drawId) => {
    setActiveChain((prev) => [prev[0], drawId]);

    //Fetch the data from the database
    if (projData) {
      axios
        .get("/drw/" + drawId)
        .then((response) => {
          let dwg = response.data.parent;
          setNotesPaneParent(dwg);
          setSidebar3Title(sidebar2Title + " - " + dwg.drawNo);
          setPdfFile(BASE_URL + "/drw/view/" + props.projNo + "/" + dwg.drawNo);

          if (response.data.children.length > 0) {
            setNotesPaneChildren(response.data.children);
          } else {
            setNotesPaneChildren(false);
          }

          //Show SideBar 3
          setSidebar3Open("-open");
        })
        .catch((error) => {
          alert(error.message);
        });
    }
  };

  const viewDrwHandler = (e, child) => {
    e.stopPropagation();
    setPdfFile(BASE_URL + "/drw/view/" + props.projNo + "/" + child);
  };

  //Update the count of the notes on the Manage Notes ButtonF
  const noteCountUpdateHandler = (newCnt) => {
    if (
      notesPaneParent.type !== "Drawing" &&
      notesPaneParent.type !== "Checklist"
    ) {
      setProjData((prevProj) => {
        var newProj = [...prevProj];
        const objInd1 = newProj.findIndex(
          (o) => o.type === notesPaneParent.type
        );
        const objInd2 = newProj[objInd1].pdfList.findIndex(
          (o) => o.id === notesPaneParent.id
        );
        newProj[objInd1].pdfList[objInd2].noteCount = newCnt;
        return newProj;
      });
    }

    setNotesPaneParent((prevObj) => {
      return { ...prevObj, noteCount: newCnt };
    });
  };

  const selectUpdateHandler = (opt) => {
    //Update the drawing state
    if (opt.draw.length > 0) {
      setSb2Data((prevDrw) => {
        var newDrw = [...prevDrw];
        opt.draw.forEach((el) => {
          const objInd = newDrw.findIndex((o) => o.id === el[0]);
          if (objInd > -1) {
            newDrw[objInd].isComplete = el[1] === 1 ? true : false;
          }
        });
        return newDrw;
      });
    }

    //Update the list
    if (opt.list.length > 0) {
      setProjData((prevProj) => {
        var newProj = [...prevProj];

        opt.list.forEach((el) => {
          newProj.forEach((pType, i) => {
            const objInd = pType.pdfList.findIndex((o) => o.id === el[0]);
            if (objInd > -1) {
              newProj[i].pdfList[objInd].isComplete =
                el[1] === 1 ? true : false;
            }
          });
        });

        return newProj;
      });
    }
  };

  const markUpdateHandler = () => {
    var url =
      notesPaneParent.type === "Drawing"
        ? "drw/mark-update"
        : "/pdf/mark-update";
    var selected = notesPaneParent.toUpdate === 1 ? false : true;

    axios
      .put(url, {
        drawId: notesPaneParent.id,
        selected: selected,
      })
      .then(() => {
        //Make updates at the project level
        if (notesPaneParent.type !== "Drawing") {
          setProjData((prevProj) => {
            var newProj = [...prevProj];
            const objInd = newProj.findIndex(
              (o) => o.id === notesPaneParent.id
            );
            newProj[objInd].toUpdate = selected ? 1 : 0;
            return newProj;
          });
        }

        setNotesPaneParent((prevObj) => {
          return { ...prevObj, toUpdate: selected ? 1 : 0 };
        });
      });
  };

  const loadCheckFileList = useCallback(
    (type) => {
      setSidebar2Open("-open");
      setSidebar3Open("-closed");
      setSidebar3Title("");
      setNotesPaneParent(false);
      setNotesPaneChildren(false);

      var url = "";
      if (type === "check") {
        setSidebar2Title("Check Sheets");
        setActiveChain([-99, ""]);
        url = "/checklist/list/" + props.projNo;
      }

      if (type === "docs") {
        setSidebar2Title("Documents");
        setActiveChain([-100, ""]);
        url = "/pdf/doclist/" + props.projNo;
      }

      axios.get(url).then((response) => {
        setSb2Holds(type);
        setSb2Data(response.data);
      });
    },
    [props.projNo]
  );

  const loadCheckSheet = (id) => {
    setShowPDF(false);
    setActiveChain((prev) => [prev[0], id]);
    axios.get("/checklist/" + props.projNo + "/" + id).then((response) => {
      setSurveyFile(response.data);
      setSidebar3Title(response.data.name);
      setNotesPaneParent({
        type: "Checklist",
        projNo: props.projNo,
        id: id,
        noteCount: response.data.noteCount,
      });
    });
  };

  const printCheckSheetHandler = (names) => {
    setShowPDF(true);
    setPdfFile(
      BASE_URL +
        "/checklist/print/" +
        props.projNo +
        "/" +
        notesPaneParent.id +
        "/" +
        names +
        "?" +
        Math.floor(Math.random() * 1001)
    );
  };

  const loadFileDoc = (name) => {
    setShowPDF(true);
    setActiveChain((prev) => [prev[0], name]);
    setPdfFile(BASE_URL + "/pdf/viewdoc/" + props.projNo + "/" + name);
  };

  const gotoParentOfHandler = (drawId) => {
    axios
      .get("/drw/parent/" + drawId)
      .then((response) => {
        console.log(response.data);
        loadList(response.data.listType, response.data.listId);
        loadDraw(response.data.drawId);
      })
      .catch((error) => alert(error.response.data));
  };

  return (
    <main style={{ display: "flex" }}>
      <SideBar
        sbType="sidebar1"
        sbState={sidebar1Open}
        sideBarHandler={toggleSideBar1Handler}
        title={projData ? props.projNo : ""}
      >
        <ScrollDiv scrollheight="120px">
          <SideBar1
            list={projData}
            active={activeChain[0]}
            loadList={loadList}
            loadCFList={loadCheckFileList}
          />
        </ScrollDiv>
      </SideBar>
      <SideBar
        sbType="sidebar2"
        sbState={sidebar2Open}
        sideBarHandler={toggleSideBar2Handler}
        title={sidebar2Title}
      >
        <input
          type="search"
          placeholder="Search"
          className={`${styleInp.inp} ${styleInp.inline}`}
          style={{ marginBottom: "10px", marginTop: "10px", width: "90%" }}
          onChange={searchChangeHandler}
        />
        <ScrollDiv scrollheight="175px">
          {projData && sb2Holds === "drw" && (
            <span
              id="report-lnk"
              className={`${styleSB["nav-link"]} ${styleSB["nav-link-drw"]} 
              ${activeChain[1] === "" ? styleSB.active : ""}`}
              onClick={() => loadList(null, activeChain[0])}
            >
              Report
            </span>
          )}
          {projData &&
            sb2Holds === "drw" &&
            sb2Data.length > 0 &&
            sb2Data
              .filter(
                (d) =>
                  (d.suffix < 0
                    ? d.drawNo
                    : ("0000" + d.suffix).slice(-3) + " - " + d.drawNo
                  ).indexOf(drawFilter) > -1
              )
              .map((drawing) => (
                <DrawingNo
                  key={"draw-" + drawing.id}
                  drawing={drawing}
                  activeChain={activeChain}
                  loadDraw={loadDraw}
                />
              ))}
          {projData &&
            sb2Holds === "check" &&
            sb2Data.length > 0 &&
            sb2Data
              .filter((cl) => cl.name.indexOf(drawFilter) > -1)
              .map((cl) => (
                <span
                  className={`${styleSB["nav-link"]} ${styleSB["nav-link-drw"]}
                  ${activeChain[1] === cl.id ? styleSB.active : ""}`}
                  key={"cl-" + cl.id}
                  id={"cl-" + cl.id}
                  onClick={() => loadCheckSheet(cl.id)}
                >
                  {cl.name}
                </span>
              ))}
          {projData && sb2Holds === "check" && (
            <div className={styleSB.sideNote}>
              Please hit the <strong style={{ color: "#fff" }}>Save</strong>{" "}
              button to make sure that the Check Sheets are saved.
            </div>
          )}
          {projData &&
            sb2Holds === "docs" &&
            sb2Data.length > 0 &&
            sb2Data
              .filter((dc) => dc.indexOf(drawFilter) > -1)
              .map((dc) => (
                <span
                  className={`${styleSB["nav-link"]} ${styleSB["nav-link-drw"]}
                ${activeChain[1] === dc ? styleSB.active : ""}`}
                  key={"doc-" + dc}
                  id={"doc-" + dc}
                  onClick={() => loadFileDoc(dc)}
                >
                  {dc}
                </span>
              ))}
        </ScrollDiv>
      </SideBar>
      <PDFView docLink={pdfFile} visible={showPDF} />
      {!showPDF && <Survey survey={surveyFile} projNo={props.projNo} />}
      <SideBar
        sbType="sidebar3"
        sbState={sidebar3Open}
        sideBarHandler={toggleSideBar3Handler}
        title={sidebar3Title}
      >
        <ScrollDiv scrollheight="125px">
          {projData && (
            <SideBar3
              notesPaneParent={notesPaneParent}
              notesPaneChildren={notesPaneChildren}
              selUpdateHandler={selectUpdateHandler}
              markUpdateHandler={markUpdateHandler}
              noteCountUpdateHandler={noteCountUpdateHandler}
              viewHandler={viewDrwHandler}
              printCheckSheetHandler={printCheckSheetHandler}
              gotoParentOf={gotoParentOfHandler}
            />
          )}
        </ScrollDiv>
      </SideBar>
    </main>
  );
};

export default Home;
