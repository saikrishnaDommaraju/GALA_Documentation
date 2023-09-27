import styles from "./Help.module.css";

const Admin = () => {
  return (
    <div className={styles.docdiv}>
      <h3>Admin Documentation</h3>
      <p>
        The Technical Documentation viewer has a detailed administration
        section. This document provide a help reference to the usage of the
        Admin Section.
      </p>
      <p>
        The Administrator can provide access to the users who need to be able to
        access the individual items of the Admin Panel. Roles who have Admin
        right must start with the word "Admin".
      </p>
      <p className={styles.subheading}>Users</p>
      <p>
        The Users section is where the users who need to access the application
        are setup. In order to create a User enter the Username, Full Name,
        email and role. The email address of the user needs to be their Dover
        email address as the system is linked into the Active Directory and
        users can use their Dover email and password to login.
      </p>
      <p>
        The roles for the Admin page are configurable from the roles section.
      </p>
      <p>
        The Actions Column on the Users table provides ways to edit or delete
        users. Clicking on the edit <span className="icon-edit"></span> brings
        up a dialog box where the information can be modified. The delete{" "}
        <span className="icon-trash"></span> icon deletes the user after
        confirmation.
      </p>
      <p className={styles.subheading}>Roles</p>
      <p>
        User roles will need to be set up to grant access to the end users who
        will use the application. The user roles can be set up dynamically
        through the Roles section.
      </p>
      <p>
        To Create a Role, select the items that the users under that role would
        need to have access to. The First items are those on the CutList while
        the ending Items are the Reports section that the user will need to
        access. Those corresponding selected items will only show up for the
        users under those roles.
      </p>
      <p>
        Clicking on the role that was previously created, the roles can be
        modified as well.
      </p>
      <p>
        The Work Centers section of the Admin Panel can be used to Add Work
        centers into this list if required at a later date.
      </p>
      <p className={styles.subheading}>Projects</p>
      <p>
        Projects can be added into the system using this section. To Add a
        project enter the Project No and click on the Checkmark. This will add
        in the project for processing. The processing of the project to pull the
        required drawings and reports happens on a backend queue. When the
        project is under process, the status will change to
        <span className="icon-wait" style={{ color: "orange" }}>
          In-Progress
        </span>
        , and once the process has completed, the status changes to{" "}
        <span className="icon-compproj" style={{ color: "green" }}>
          Ready
        </span>
        . Once once the status is{" "}
        <span className="icon-compproj" style={{ color: "green" }}>
          Ready
        </span>{" "}
        will it show up for selection and viewing by the user.
      </p>
      <p>
        If an Error occurs during processing, the Status will change to{" "}
        <span className="icon-noproj" style={{ color: "red" }}>
          Error
        </span>{" "}
        and the cause of the error will come up in the Name column.
      </p>
      <p>
        The Actions column provides various actions that can be done on the
        project.
        <ul>
          <li>
            <span className="icon-waitproj" style={{ color: "orange" }}></span>{" "}
            Update Project - Mark the project for update. The backend queue will
            pick up this project and reprocess it to pull all the reports once
            again. Only the new drawings are pulled, any existing drawings are
            maintained.
          </li>
          <li>
            <span className="icon-noproj" style={{ color: "blue" }}></span>{" "}
            Close Project - Once the project is closed, it will no longer show
            up on the project selection drop down
          </li>
          <li>
            <span className="icon-compproj" style={{ color: "green" }}></span>{" "}
            Move to Ready - If the project is closed, this icon can move the
            project back to the ready state.
          </li>
          <li>
            <span className="icon-trash" style={{ color: "blue" }}></span>{" "}
            Delete Project - If the project is New or has an error, then the
            user an delete the project, before it gets processed.
          </li>
          <li>
            <span className="icon-box" style={{ color: "red" }}></span> Archive
            Project - After completion, to completely remove the project from
            the page, the project can be archived. Clicking this icon will move
            the project to the archive section and delete all the project
            reports and drawings to save space on the server. The information
            can be retrevied again from the Project Archive section.
          </li>
          <li>
            <span
              className="icon-checklist"
              style={{ color: "blue", fontSize: "15px" }}
            ></span>
            Select Checklist
          </li>
          <li>
            <span
              className="icon-projinfo"
              style={{ color: "green", fontSize: "15px" }}
            ></span>
            Update Project Information
          </li>
        </ul>
      </p>
      <p>
        The Project Information dialog provides a way for the Admin to set the
        Project Cover Note as well the email address of the people who should be
        notified on workflow changes.
        <br />
        <strong>Notify Project Processing</strong> - Comma Separated Email of
        the person who would need to be notified when the project is ready to
        view
        <br />
        <strong>Mechanical Designer Email</strong> - Comma Separated Email
        addresses of the Mechanical Design Engineer or any other people who need
        to be notified when the Coordinater has finished submitting the
        Checksheet
        <br />
        <strong>Electrical Designer Email</strong> - Comma Separated Email
        addresses of the Electrical Design Engineer or any other people who need
        to be notified when the Coordinater has finished submitting the
        Checksheet
      </p>
      <p className={styles.subheading}>Project Archive</p>
      <p>
        The Project Archive is used to see and retrive the project that have
        been archived. Click on the{" "}
        <span className="icon-waitproj" style={{ color: "orange" }}></span>
        restore icon will move the project back to the active projects page and
        into the update state. This will allow the backend process to being
        retrieving the reports and drawings for the project again. Once the
        processing has been completed, it will move to the ready state for
        viewing.
      </p>
      <p>
        The project can also be permanently deleted from here using the{" "}
        <span className="icon-trash" style={{ color: "red" }}></span>. This will
        no longer show up on the front end of the application. In order to
        restore a deleted project, the Admin will need to update the state to{" "}
        <b>update</b> in the database.
      </p>
      <p className={styles.subheading}>Work Centers</p>
      <p>
        The Work Centers section allows the Admin to add in new Cut List Work
        Centers to the application. These Work centers map the Acronym of the
        Work centers from CSI Syteline to the Full Form as shown on the Cut List
        of this application to the end user. It is also used to provide role
        based access to the users as well, from the roles and Users section.
      </p>
      <p className={styles.subheading}>Check Sheets</p>
      <p>This section allows the Admin to create or modify checksheets.</p>
      <p>
        To Create a CheckSheet, start adding questions. Add in the Title of the
        Checksheet, the description and add or modify the questions as required
        to check items on that particular process.
      </p>
      <p>
        The User Documentation for the CheckSheet creation tool can be found at{" "}
        <a href="https://www.surveyjs.io/Documentation/Survey-Creator?id=End-User-Guide">
          https://www.surveyjs.io/Documentation/Survey-Creator?id=End-User-Guide
        </a>
      </p>
      <p>Clicking the Add button after entering the Checksheet will save it.</p>
      <p>
        To Modify the checksheet, click on the name of the checksheet in the
        left pane. This will mark the Checksheet that is going to be modifed
        with a pencil icon and change the Button to Update. Clicking on the
        update button updates the sheet.
      </p>
      <p>
        Creation of the Checksheets are version controlled. Once a CheckSheet
        has been responded to, then in order to keep a consistant question
        response connection, a new version of the Checksheet will need to be
        created. If the Admin modifies the Checksheet after a user response is
        submitted, the application will notify the admin that the checksheet has
        already been responded to and if they need to bump up the version.
        Clicking Ok will bump the version while clicking Cancel will save it on
        the same version. Small changes such as spelling changes can be saved on
        the same version, while larger changes such as adding in a question or
        changing a question type, the version should be updated.
      </p>
      <p>
        If the Checksheet has already been responded to for a project, it will
        remain on that version for that project. Other projects for which the
        checksheet has not been responded to at the time of the version update
        will get the new version of the Checksheet.
      </p>
      <p>
        The version numbers are given on the left names section. These version
        numbers are printed on the checksheet as well.
      </p>
      <p>
        While creating the Checksheets there are a few things the author needs
        to be aware of:
        <ol>
          <li>
            Check the important note on the Admin Panel for naming conventions
            to be followed on a couple of questions: model, role,
            coordinater_signoff and not applicable.
          </li>
          <li>
            In order to get the printing correctly, the Boolean Values on Check
            Sheet questions need be in a Panel. Space has been provided for upto
            3 Boolean Values to stack horizonatally on the print before it wraps
            to the next line.
          </li>
          <li>
            The logic section on questions can be used to show and hide
            questions based on the responses from other questions. However, this
            does not impact the printing of the checksheets.
          </li>
          <li>
            The logic section on pages, can be used to show and hide pages based
            on responses from questions. This impacts the printing of the
            checksheets as those pages which do not need to be shown are not
            printed.
          </li>
        </ol>
      </p>
      <p className={styles.subheading}>Contact Us</p>
      <p>
        The Contact us section allows the Admin to update the Contact
        information that the end users sees when they click on the Contact us
        link in the footer. This text box allows HTML inputs and what the user
        sees is populated on the top half.
      </p>
      <p>
        Clicking on Save updates the information. A page refresh is needed to
        update the contact information into the application.
      </p>
    </div>
  );
};

export default Admin;
