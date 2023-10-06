import { useState, useRef, useEffect } from "react";
import DOMPurify from "dompurify";
import axios from "../../helpers/axios-instance";

import Container from "../../UI/Container";
import styleInp from "../../UI/Input.module.css";

const Contact = () => {
  const [contact, setContact] = useState({ __html: "" });
  const [docEmail, setDocEmail] = useState("");
  const docEmailRef = useRef();

  useEffect(() => {
    axios.get("/users/contact").then((response) => {
      let cleanHTML = DOMPurify.sanitize(response.data, {
        USE_PROFILES: { html: true },
      });
      setContact({ __html: cleanHTML });
    });

    axios
      .get("/users/params/doc_email")
      .then((response) => setDocEmail(response.data));
  }, []);

  const submitHandler = (e) => {
    e.preventDefault();
    let cleanHTML = DOMPurify.sanitize(contact.__html, {
      USE_PROFILES: { html: true },
    });
    axios
      .post("/users/params", { tla: "contact", name: cleanHTML })
      .then((response) => alert(response.data))
      .catch((error) => alert(error.message.data));
  };

  const formSubmitHandler = (e) => {
    submitHandler(e);
  };

  const textChangeHandler = (e) => {
    let cleanHTML = DOMPurify.sanitize(e.target.value, {
      USE_PROFILES: { html: true },
    });
    setContact({ __html: cleanHTML });
  };

  const emailUpdateHandler = () => {
    console.log(docEmailRef.current.value);
    axios
      .post("/users/params", {
        tla: "doc_email",
        name: docEmailRef.current.value,
      })
      .then((response) => alert(response.data))
      .catch((error) => alert(error.message.data));
  };

  return (
    <Container>
      <h3>Contact Us</h3>
      <p dangerouslySetInnerHTML={contact}></p>
      <form onSubmit={submitHandler}>
        <textarea
          rows="10"
          cols="50"
          defaultValue={contact.__html}
          onChange={textChangeHandler}
        ></textarea>
        <br />
        <button onClick={formSubmitHandler} className={styleInp.btn}>
          Update Contact Info
        </button>
      </form>
      <p style={{ color: "red" }}>
        * Accepting HTML here. Sanitising entry to prevent XSS attacks.
      </p>
      <hr />
      <p>
        Documentation Email:
        <br />
        <input
          type="text"
          ref={docEmailRef}
          className={styleInp.inp + " " + styleInp.inline}
          defaultValue={docEmail}
        />{" "}
        <button className={styleInp.btn} onClick={emailUpdateHandler}>
          Update
        </button>
      </p>
    </Container>
  );
};

export default Contact;
