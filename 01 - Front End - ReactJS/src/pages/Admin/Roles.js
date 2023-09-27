import { useState, useEffect, useRef } from "react";
import axios from "../../helpers/axios-instance";

import ScrollDiv from "../../UI/ScrollDiv";
import Container from "../../UI/Container";
import styleInp from "../../UI/Input.module.css";
import styles from "./Roles.module.css";

const Roles = () => {
  const [roles, setRoles] = useState([]);
  const [wc, setWc] = useState([]);
  const [toAdd, setToAdd] = useState(true);
  const roleNameRef = useRef();
  const wcCBRef = useRef([]);
  const adCBRef = useRef([]);
  const roRef = useRef();
  const cbAllRef = useRef();

  useEffect(() => {
    axios.get("/role").then((response) => {
      setRoles(response.data);
    });

    axios.get("/wc").then((response) => {
      setWc(response.data);
    });
  }, []);

  useEffect(() => {
    wcCBRef.current = wcCBRef.current.slice(
      0,
      wc.filter((w) => w.order < 1000).length
    );

    adCBRef.current = adCBRef.current.slice(
      0,
      wc.filter((w) => w.order > 1000).length
    );
  }, [wc]);

  const roleSubmitHandler = (e) => {
    e.preventDefault();
    const rName = roleNameRef.current.value;
    if (rName === "") {
      alert("Please enter the role name");
      return false;
    }

    let strSel = "";
    for (let i = 0; i < wcCBRef.current.length; i++) {
      if (wcCBRef.current[i].checked) {
        if (strSel === "") {
          strSel = wcCBRef.current[i].value;
        } else {
          strSel += "," + wcCBRef.current[i].value;
        }
      }
    }
    for (let i = 0; i < adCBRef.current.length; i++) {
      if (adCBRef.current[i].checked) {
        if (strSel === "") {
          strSel = adCBRef.current[i].value;
        } else {
          strSel += "," + adCBRef.current[i].value;
        }
      }
    }
    if (strSel === "") {
      alert("Please select the list this role can access");
      return false;
    }

    axios
      .post("/role", {
        Name: rName,
        WcList: strSel,
        ReadOnly: roRef.current.checked,
      })
      .then((response) => {
        if (toAdd) {
          setRoles((prevRoles) => {
            let newRoles = [...prevRoles];
            newRoles.push(response.data);
            return newRoles;
          });
          alert("User Role Created");
        } else {
          setRoles((prevRoles) => {
            const roleIndex = roles.findIndex(
              (prevRoles) => prevRoles.id === response.data.id
            );
            prevRoles[roleIndex] = response.data;
            return prevRoles;
          });
          alert("User Role Updated");
        }
      })
      .catch((error) => {
        alert(error.message);
      });
  };

  const submitRoleForm = (e) => {
    roleSubmitHandler(e);
  };

  const loadRoleData = (id) => {
    let aR = roles.filter((r) => r.id === id)[0];
    roleNameRef.current.value = aR.name;
    setToAdd(false);
    roRef.current.checked = aR.readOnly;
    if (aR.listItems !== "" && aR.listItems !== null) {
      const toCheck = aR.listItems.split(",");
      for (let i = 0; i < wcCBRef.current.length; i++) {
        if (toCheck.includes(wcCBRef.current[i].value)) {
          wcCBRef.current[i].checked = true;
        } else {
          wcCBRef.current[i].checked = false;
        }
      }
      for (let i = 0; i < adCBRef.current.length; i++) {
        if (toCheck.includes(adCBRef.current[i].value)) {
          adCBRef.current[i].checked = true;
        } else {
          adCBRef.current[i].checked = false;
        }
      }
    } else {
      for (let i = 0; i < wcCBRef.current.length; i++) {
        wcCBRef.current[i].checked = false;
      }
      for (let i = 0; i < adCBRef.current.length; i++) {
        adCBRef.current[i].checked = false;
      }
    }
  };

  const roleNameChangeHandler = (e) => {
    if (roles.some((r) => r.name === e.target.value)) {
      setToAdd(false);
      let aR = roles.filter((r) => r.name === e.target.value)[0];
      roRef.current.checked = aR.readOnly;
      if (aR.listItems !== "" && aR.listItems !== null) {
        const toCheck = aR.listItems.split(",");
        for (let i = 0; i < wcCBRef.current.length; i++) {
          if (toCheck.includes(wcCBRef.current[i].value)) {
            wcCBRef.current[i].checked = true;
          } else {
            wcCBRef.current[i].checked = false;
          }
        }
        for (let i = 0; i < adCBRef.current.length; i++) {
          if (toCheck.includes(adCBRef.current[i].value)) {
            adCBRef.current[i].checked = true;
          } else {
            adCBRef.current[i].checked = false;
          }
        }
      } else {
        for (let i = 0; i < wcCBRef.current.length; i++) {
          wcCBRef.current[i].checked = false;
        }
        for (let i = 0; i < adCBRef.current.length; i++) {
          adCBRef.current[i].checked = false;
        }
      }
    } else {
      setToAdd(true);
    }
  };

  const selAllHandler = () => {
    for (let i = 0; i < wcCBRef.current.length; i++) {
      wcCBRef.current[i].checked = cbAllRef.current.checked;
    }
  };

  return (
    <ScrollDiv scrollheight="90px">
      <Container>
        <h3>Roles</h3>
        <div className="left" style={{ width: "20%", padding: "10px" }}>
          <div
            style={{
              borderTop: "1px dashed #ccc",
              borderBottom: "1px dashed #ccc",
              padding: "5px",
              textAlign: "center",
            }}
          >
            Admin roles must start with word <strong>Admin</strong>
          </div>
          <br />
          <ul className={styles.roleList}>
            {roles.length > 0 &&
              roles.map((role) => (
                <li
                  key={"role-" + role.id}
                  onClick={() => loadRoleData(role.id)}
                >
                  {role.name}
                </li>
              ))}
          </ul>
          <button onClick={submitRoleForm} className={styleInp.btn}>
            {toAdd ? "+ Add Role" : "Update Role"}
          </button>
        </div>
        <form name="newRole" onSubmit={roleSubmitHandler}>
          <div className="left" style={{ width: "30%", padding: "10px" }}>
            Role Name :{" "}
            <input
              type="text"
              placeholder="Role"
              className={styleInp.inp}
              style={{ width: "200px" }}
              ref={roleNameRef}
              onChange={roleNameChangeHandler}
            />
            <br />
            <br />
            <input type="checkbox" ref={roRef} /> Read Only Role
            <br />
            <hr style={{ float: "left", width: "50%" }} />
            <br />
            <input
              type="checkbox"
              ref={cbAllRef}
              onChange={selAllHandler}
            />{" "}
            <em>Select All</em>
            <br />
            <br />
            <ul className={styles.wcList}>
              {wc.length > 0 &&
                wc
                  .filter((w) => w.order < 1000)
                  .map((w, i) => (
                    <li key={"wc-" + w.id}>
                      <input
                        type="checkbox"
                        name="wc[]"
                        value={w.id}
                        ref={(el) => (wcCBRef.current[i] = el)}
                      />{" "}
                      {w.tla + " - " + w.name}
                    </li>
                  ))}
            </ul>
          </div>
          <div
            className="left"
            style={{ width: "30%", padding: "10px", marginTop: "50px" }}
          >
            <br />
            <strong>Admin Roles</strong>
            <br />
            <br />
            <ul className={styles.wcList}>
              {wc.length > 0 &&
                wc
                  .filter((w) => w.order > 1000)
                  .map((w, i) => (
                    <li key={"wc-" + w.id}>
                      <input
                        type="checkbox"
                        name="wc[]"
                        value={w.id}
                        ref={(el) => (adCBRef.current[i] = el)}
                      />{" "}
                      {w.name}
                    </li>
                  ))}
            </ul>
          </div>
        </form>
        <div className="clear"></div>
      </Container>
    </ScrollDiv>
  );
};

export default Roles;
