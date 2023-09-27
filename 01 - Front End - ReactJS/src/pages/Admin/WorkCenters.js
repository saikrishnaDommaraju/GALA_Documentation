import { useEffect, useState, useRef } from "react";
import axios from "../../helpers/axios-instance";
import styles from "../../UI/Input.module.css";

import Container from "../../UI/Container";
import Table from "../../UI/Table";
import ScrollDiv from "../../UI/ScrollDiv";

const tHead = ["Work Center", "Name", "Order"];

const WorkCenters = () => {
  const wcRef = useRef();
  const wcNameRef = useRef();
  const [wc, setWc] = useState([]);

  useEffect(() => {
    axios.get("/wc").then((response) => setWc(response.data));
  }, []);

  const wcAddHandler = () => {
    //Validate the WorkCenter
    if (wcRef.current.value === "" || wcNameRef.current.value === "") {
      alert("Please enter the work center details");
      return false;
    }

    //Add in the new Project
    const newWc = {
      tla: wcRef.current.value.toUpperCase(),
      name: wcNameRef.current.value,
    };

    axios
      .post("/wc", newWc)
      .then(() => {
        setWc((prevWc) => prevWc.concat(newWc));
        wcRef.current.value = "";
        wcNameRef.current.value = "";
      })
      .catch((error) => {
        alert("Could not add Work Center : " + error.response.data);
      });
  };

  const tFoot = [
    <input ref={wcRef} className={styles.inp} placeholder="Work Center" />,
    <input ref={wcNameRef} className={styles.inp} placeholder="Name" />,
    <button onClick={wcAddHandler} className={styles.btn}>
      <span className="icon-ok"></span>
    </button>,
  ];

  let tableContent = "";

  if (wc.length > 0) {
    tableContent = wc.map((rows) => {
      return [rows.tla, rows.name, rows.order];
    });
  } else {
    tableContent = [["No Work Centers found", "", ""]];
  }

  return (
    <ScrollDiv scrollheight="90px">
      <Container>
        <h3>Work Centers</h3>
        <em>
          * The order is for reference only and must be updated from the DB.
          <br />* Admin should have order &gt; 1000.
        </em>
        <br />
        <br />
        <Table header={tHead} footer={tFoot}>
          {tableContent}
        </Table>
      </Container>
    </ScrollDiv>
  );
};

export default WorkCenters;
